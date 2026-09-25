import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/money.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'form_fields.dart';

/// Sets the overall and per-category budgets for the current period on
/// (BUD-1, BUD-5).
class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.budgetsTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.budgetsHint(periodLabel(provider.currentPeriod, l10n)),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          _BudgetTile(
            categoryId: null,
            name: l10n.overallBudget,
            leading: const Icon(Icons.account_balance_wallet_outlined),
          ),
          const Divider(),
          for (final category in provider.categoriesFor(
            TransactionType.expense,
          ))
            _BudgetTile(
              categoryId: category.id,
              name: category.label(l10n),
              leading: CircleAvatar(
                backgroundColor: categoryTint(category),
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The overall budget's own dialog, opened straight from Home's summary card
/// so the first budget can be set where the want for one is felt (BUD-11).
///
/// [prefill] is what the box starts with — last period's spending, so the
/// first budget is a correction rather than a guess. It saves through the
/// provider and reports a failure the way the budgets screen does.
Future<void> showOverallBudgetDialog(
  BuildContext context, {
  required Money? prefill,
}) async {
  final l10n = AppLocalizations.of(context);
  final provider = context.read<TransactionProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final currency = context.read<SettingsProvider>().currencyFormat(
    l10n.localeName,
  );
  final change = await showDialog<({Money? limit})>(
    context: context,
    builder: (_) => _BudgetDialog(
      name: l10n.overallBudget,
      current: prefill,
      currency: currency,
    ),
  );
  if (change == null) return;
  try {
    // BUD-5: it starts from the current period, whichever period Home was
    // showing when it was asked for.
    await provider.setBudget(null, change.limit);
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.budgetSaveFailed)));
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.categoryId,
    required this.name,
    required this.leading,
  });

  /// Null for the overall budget.
  final String? categoryId;
  final String name;
  final Widget leading;

  Future<void> _edit(BuildContext context, Money? current) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final currency = context.read<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final change = await showDialog<({Money? limit})>(
      context: context,
      builder: (_) =>
          _BudgetDialog(name: name, current: current, currency: currency),
    );
    if (change == null) return;
    try {
      await provider.setBudget(categoryId, change.limit);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.budgetSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final limit = provider.budgetLimit(categoryId, provider.currentPeriod);

    return ListTile(
      leading: leading,
      title: Text(name),
      trailing: Text(limit == null ? l10n.noBudget : currency.money(limit)),
      onTap: () => _edit(context, limit),
    );
  }
}

/// Pops `(limit: amount)` to save, `(limit: null)` to remove, or nothing to
/// cancel.
class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({
    required this.name,
    required this.current,
    required this.currency,
  });

  final String name;
  final Money? current;
  final NumberFormat currency;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(
    text: widget.current?.toInputString() ?? '',
  );

  @override
  void initState() {
    super.initState();
    // Live preview of the parsed amount (CUR-2): the system decimal keyboard
    // reads '.' as a thousands separator in some languages, so a mistyped
    // amount is shown back rather than saved silently wrong.
    _controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Money? _parse() => Money.tryParse(
    _controller.text,
    maxDecimals: widget.currency.maximumFractionDigits,
    decimalMark: widget.currency.symbols.DECIMAL_SEP,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final limit = _controller.text.trim().isEmpty ? null : _parse();
    return AlertDialog(
      title: Text(widget.name),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textDirection: TextDirection.ltr,
          textAlign: amountTextAlign(context),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.budgetLimitLabel,
            prefixText: '${widget.currency.currencySymbol} ',
            helperText: limit != null
                ? l10n.amountResult(widget.currency.money(limit))
                : null,
          ),
          validator: (_) {
            final limit = _parse();
            return limit == null || !limit.isPositive
                ? l10n.amountInvalid
                : null;
          },
        ),
      ),
      actions: [
        if (widget.current != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop((limit: null)),
            child: Text(l10n.removeButton),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop((limit: _parse()));
            }
          },
          child: Text(l10n.saveButton),
        ),
      ],
    );
  }
}
