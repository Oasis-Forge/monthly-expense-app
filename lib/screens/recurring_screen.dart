import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/money.dart';
import '../models/recurring_rule.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'form_fields.dart';
import 'recurring_rule_screen.dart';

/// Recurring transactions: what's due and waiting for a tap (RCR-2), the
/// next 30 days (RCR-7), and the rules.
class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final due = provider.dueOccurrences;
    final upcoming = provider.upcomingOccurrences;
    final rules = provider.recurringRules;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurringTitle)),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addRecurringTooltip,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const RecurringRuleScreen())),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          if (due.isNotEmpty) ...[
            _Header(l10n.dueHeader),
            for (final occurrence in due) _DueTile(occurrence: occurrence),
          ],
          _Header(l10n.upcomingHeader),
          if (upcoming.isEmpty)
            _Empty(l10n.nothingUpcoming)
          else
            for (final occurrence in upcoming)
              _OccurrenceTile(occurrence: occurrence),
          _Header(l10n.rulesHeader),
          if (rules.isEmpty)
            _Empty(l10n.noRules)
          else
            for (final rule in rules) _RuleTile(rule: rule),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      ListTile(title: Text(text, style: Theme.of(context).textTheme.bodySmall));
}

/// The signed amount of a rule, like a transaction row.
String _signedAmount(
  RecurringRule rule,
  NumberFormat currency, [
  Money? amount,
]) {
  final sign = rule.type == TransactionType.income ? '+' : '-';
  return '$sign${currency.format((amount ?? rule.amount).toDouble())}';
}

class _DueTile extends StatelessWidget {
  const _DueTile({required this.occurrence});

  final ScheduledOccurrence occurrence;

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await action();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.postFailed)));
    }
  }

  /// Lets the user change the amount before posting (RCR-2).
  Future<void> _postWithAmount(BuildContext context, String name) async {
    final provider = context.read<TransactionProvider>();
    final currency = context.read<SettingsProvider>().currencyFormat(
      AppLocalizations.of(context).localeName,
    );
    final amount = await showDialog<Money>(
      context: context,
      builder: (_) => _PostDialog(
        name: name,
        amount: occurrence.rule.amount,
        currency: currency,
      ),
    );
    if (amount == null || !context.mounted) return;
    await _run(
      context,
      () => provider.postOccurrence(occurrence, amount: amount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final rule = occurrence.rule;
    final category = provider.categoryById(rule.categoryId);
    final name = rule.label(category, l10n);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: categoryTint(category),
        child: Text(category?.icon ?? '📦'),
      ),
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categoryAndDate(
              isolateLeftToRight(
                _signedAmount(rule, currency),
                Directionality.of(context),
              ),
              DateFormat.yMMMd(l10n.localeName).format(occurrence.date),
            ),
          ),
          // Under the text rather than trailing, so the buttons fit at any
          // text size and in every language (LANG-6).
          OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                onPressed: () =>
                    _run(context, () => provider.skipOccurrence(occurrence)),
                child: Text(l10n.skipButton),
              ),
              FilledButton.tonal(
                onPressed: () =>
                    _run(context, () => provider.postOccurrence(occurrence)),
                child: Text(l10n.postButton),
              ),
            ],
          ),
        ],
      ),
      onTap: () => _postWithAmount(context, name),
    );
  }
}

class _OccurrenceTile extends StatelessWidget {
  const _OccurrenceTile({required this.occurrence});

  final ScheduledOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final rule = occurrence.rule;
    final category = provider.categoryById(rule.categoryId);

    return ListTile(
      leading: const Icon(Icons.event_outlined),
      title: Text(rule.label(category, l10n)),
      subtitle: Text(
        DateFormat.yMMMEd(l10n.localeName).format(occurrence.date),
      ),
      trailing: Text(
        _signedAmount(rule, currency),
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({required this.rule});

  final RecurringRule rule;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final category = provider.categoryById(rule.categoryId);

    return ListTile(
      leading: CircleAvatar(
        child: Icon(rule.isPaused ? Icons.pause : Icons.repeat),
      ),
      title: Text(rule.label(category, l10n)),
      subtitle: Text(scheduleLabel(rule, l10n)),
      trailing: Text(
        _signedAmount(rule, currency),
        textDirection: TextDirection.ltr,
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RecurringRuleScreen(editing: rule)),
      ),
    );
  }
}

/// Pops the amount to post, or nothing to cancel.
class _PostDialog extends StatefulWidget {
  const _PostDialog({
    required this.name,
    required this.amount,
    required this.currency,
  });

  final String name;
  final Money amount;
  final NumberFormat currency;

  @override
  State<_PostDialog> createState() => _PostDialogState();
}

class _PostDialogState extends State<_PostDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(
    text: widget.amount.toInputString(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Money? _parse() => Money.tryParse(
    _controller.text,
    maxDecimals: widget.currency.maximumFractionDigits,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            labelText: l10n.amountLabel,
            prefixText: '${widget.currency.currencySymbol} ',
          ),
          validator: (_) {
            final amount = _parse();
            return amount == null || !amount.isPositive
                ? l10n.amountInvalid
                : null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_parse());
            }
          },
          child: Text(l10n.postButton),
        ),
      ],
    );
  }
}
