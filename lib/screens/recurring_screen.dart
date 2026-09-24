import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import 'empty_state.dart';
import '../l10n/labels.dart';
import '../models/money.dart';
import '../models/recurring_rule.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'amount_style.dart';
import 'form_fields.dart';
import 'haptics.dart';
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
      // EMPTY-1: with no rules at all there is nothing to head, so the
      // screen says what it is for and offers the one action that fills it.
      body: rules.isEmpty
          ? EmptyState(
              icon: Icons.event_repeat_outlined,
              title: l10n.noRules,
              message: l10n.recurringEmptyMessage,
              actionLabel: l10n.addRecurringButton,
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecurringRuleScreen()),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                // RCR-8: what the rules come to, and what falls next.
                const _BillsHeader(),
                if (due.isNotEmpty) ...[
                  _Header(l10n.dueHeader),
                  for (final occurrence in due)
                    _DueTile(occurrence: occurrence),
                ],
                _Header(l10n.upcomingHeader),
                if (upcoming.isEmpty)
                  _Empty(l10n.nothingUpcoming)
                else
                  for (final occurrence in upcoming)
                    _OccurrenceTile(occurrence: occurrence),
                _Header(l10n.rulesHeader),
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

/// When the next entry falls (RCR-8). Today and tomorrow are messages of
/// their own rather than `=0` and `=1` cases of the plural: gen_l10n compiles
/// an explicit case into the CLDR category of the same name, and Russian's
/// "one" category also holds 21 and 31 — which had a bill three weeks off
/// announcing itself as "tomorrow".
String _nextLine(AppLocalizations l10n, int days, String title) =>
    switch (days) {
      <= 0 => l10n.nextBillToday(title),
      1 => l10n.nextBillTomorrow(title),
      _ => l10n.nextBill(days, title),
    };

/// What the expense rules come to in a month, and what falls next (RCR-8).
class _BillsHeader extends StatelessWidget {
  const _BillsHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final bills = provider.monthlyBills;
    final next = provider.nextScheduled;
    // Rules that are all income, with nothing scheduled, leave nothing to say.
    if (!bills.isPositive && next == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bills.isPositive)
            Text(
              l10n.billsPerMonth(currency.money(bills)),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          if (next != null)
            Text(
              _nextLine(
                l10n,
                provider.daysUntil(next.date),
                next.rule.label(
                  provider.categoryById(next.rule.categoryId),
                  l10n,
                ),
              ),
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

/// The signed amount of a rule, like a transaction row.
String _signedAmount(
  RecurringRule rule,
  NumberFormat currency, [
  Money? amount,
]) {
  return signedAmount(
    currency,
    amount ?? rule.amount,
    isIncome: rule.type == TransactionType.income,
  );
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
    await _run(context, () async {
      await provider.postOccurrence(occurrence, amount: amount);
      // HAP-2: a due entry posted with a tap is a record written.
      saveFeedback();
    });
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

    // The buttons sit under the row rather than inside its subtitle. Inside,
    // the tile ran three lines deep and ListTile centred the mark against
    // all of them, so the mark, the name, the amount and the buttons each
    // landed at a different height and the row read as a staircase. Out
    // here the row is the same two lines as every other row on the screen,
    // and the buttons line up under the text they belong to.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: categoryTint(category),
            child: Text(category?.icon ?? '📦'),
          ),
          title: Text(name),
          subtitle: Text(
            l10n.categoryAndDate(
              isolateLeftToRight(
                _signedAmount(rule, currency),
                Directionality.of(context),
              ),
              DateFormat.yMMMd(l10n.localeName).format(occurrence.date),
            ),
          ),
          onTap: () => _postWithAmount(context, name),
        ),
        // Under the text rather than trailing, so they fit at any text size
        // and in every language (LANG-6), and indented to the text's own
        // margin rather than the screen's.
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 8),
          child: OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                onPressed: () =>
                    _run(context, () => provider.skipOccurrence(occurrence)),
                child: Text(l10n.skipButton),
              ),
              FilledButton.tonal(
                onPressed: () => _run(context, () async {
                  await provider.postOccurrence(occurrence);
                  // HAP-2: the same knock as the entry form.
                  saveFeedback();
                }),
                child: Text(l10n.postButton),
              ),
            ],
          ),
        ),
      ],
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
      // The same circle the due rows and Home use, so the three lists on
      // this screen share one left edge and a category is recognised by its
      // colour wherever it appears (CAT-6). A bare icon here sat narrower
      // than the circles below it and pulled the titles out of line.
      leading: CircleAvatar(
        backgroundColor: categoryTint(category),
        child: Text(category?.icon ?? '📦'),
      ),
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
      // The category's own colour and mark, as everywhere else (CAT-6); a
      // paused rule keeps the pause in its place, because that is the one
      // thing about a rule worth seeing before its name.
      leading: CircleAvatar(
        backgroundColor: categoryTint(category),
        child: rule.isPaused
            ? const Icon(Icons.pause)
            : Text(category?.icon ?? '📦'),
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
