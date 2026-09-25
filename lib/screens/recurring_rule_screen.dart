import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/account.dart';
import '../models/recurring_rule.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'delete_snack_bar.dart';
import 'form_fields.dart';

/// Adds or edits a recurring rule (RCR-1). Editing also offers pause, resume,
/// and delete (RCR-5, RCR-6).
class RecurringRuleScreen extends StatefulWidget {
  const RecurringRuleScreen({super.key, this.editing});

  final RecurringRule? editing;

  @override
  State<RecurringRuleScreen> createState() => _RecurringRuleScreenState();
}

class _RecurringRuleScreenState extends State<RecurringRuleScreen>
    with AmountEntry {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _intervalController = TextEditingController(text: '1');
  final _countController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  String? _accountId;
  RecurrenceFrequency _frequency = RecurrenceFrequency.month;
  late DateTime _startDate;
  RecurrenceEnd _endType = RecurrenceEnd.never;
  DateTime? _endDate;

  /// Off by default: occurrences wait for a tap (RCR-2).
  bool _autoPost = false;

  /// True while a save is in flight, so a double tap or a retry after a
  /// slow or failed save cannot create a second rule (data-integrity#5).
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TransactionProvider>();
    final editing = widget.editing;
    final now = DateTime.now();
    if (editing != null) {
      amountController.text = editing.amount.toInputString();
      _titleController.text = editing.title ?? '';
      _noteController.text = editing.note ?? '';
      _intervalController.text = '${editing.interval}';
      _countController.text = editing.endCount == null
          ? ''
          : '${editing.endCount}';
      _type = editing.type;
      _categoryId = editing.categoryId;
      _accountId = editing.accountId;
      _frequency = editing.frequency;
      _startDate = editing.startDate;
      _endType = editing.endType;
      _endDate = editing.endDate;
      _autoPost = editing.autoPost;
    } else {
      _categoryId = provider.defaultCategoryId(_type);
      _accountId = provider.defaultAccountId();
      _startDate = DateTime(now.year, now.month, now.day);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _intervalController.dispose();
    _countController.dispose();
    super.dispose();
  }

  /// The interval takes a whole number from 1 to [_intervalMax]: high enough
  /// for any real schedule, low enough that the projected date stays well
  /// inside what [DateTime] can represent (money-time#7). A rule saved
  /// before the cap keeps its own interval.
  static const _intervalMax = 999;

  int? _interval(String? text) {
    final value = _wholeNumber(text);
    if (value == null) return null;
    return value <= _intervalMax || value == widget.editing?.interval
        ? value
        : null;
  }

  /// A whole number from 1, with no upper bound: the repeat count needs
  /// none, since a schedule that runs past what [DateTime] can represent
  /// simply ends there (RecurringRule.occurrence, money-time#7).
  static int? _wholeNumber(String? text) {
    final value = int.tryParse(text?.trim() ?? '');
    return value != null && value >= 1 ? value : null;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final currency = context.read<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final endDate = _endType == RecurrenceEnd.onDate ? _endDate : null;
    if (endDate != null && endDate.isBefore(_startDate)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.endDateInvalid)));
      return;
    }

    final editing = widget.editing;
    // The pause/resume button writes straight to the provider and leaves the
    // form open, so `editing` can be a stale snapshot of the rule by the
    // time Save runs; read pausedAt and createdAt from the provider's
    // current copy instead of the one the screen opened with, or Save
    // silently reverts whichever of Pause or Resume was just tapped
    // (rules-6-10#3).
    final live = editing == null
        ? null
        : provider.recurringRuleById(editing.id);
    final now = DateTime.now().toUtc();
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();
    final rule = RecurringRule(
      id: editing?.id ?? const Uuid().v4(),
      title: title.isEmpty ? null : title,
      amount: parsedAmount(currency)!,
      categoryId: _categoryId!,
      accountId: _accountId ?? Account.cashId,
      type: _type,
      note: note.isEmpty ? null : note,
      frequency: _frequency,
      interval: _interval(_intervalController.text)!,
      startDate: _startDate,
      endType: _endType,
      endCount: _endType == RecurrenceEnd.afterCount
          ? _wholeNumber(_countController.text)
          : null,
      endDate: endDate,
      autoPost: _autoPost,
      pausedAt: live?.pausedAt,
      activeFrom: editing?.activeFrom ?? _startDate,
      createdAt: live?.createdAt ?? now,
      updatedAt: now,
    );

    _saving = true;
    try {
      if (editing == null) {
        await provider.addRecurringRule(rule);
      } else {
        await provider.updateRecurringRule(rule);
      }
    } catch (_) {
      _saving = false;
      messenger.showSnackBar(SnackBar(content: Text(l10n.recurringSaveFailed)));
      return;
    }
    _saving = false;
    if (mounted) Navigator.of(context).pop();
  }

  /// Runs pause, resume, or delete; delete also closes the screen.
  Future<void> _run(
    Future<void> Function() change, {
    bool close = false,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await change();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.recurringSaveFailed)));
      return;
    }
    if (close && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final editing = widget.editing;
    final rule = editing == null
        ? null
        : provider.recurringRuleById(editing.id);
    final categories = provider.categoriesFor(_type);
    final accounts = provider.activeAccounts;
    final endDate = _endDate;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing == null ? l10n.addRecurringTitle : l10n.editRecurringTitle,
        ),
        actions: [
          if (rule != null) ...[
            IconButton(
              icon: Icon(rule.isPaused ? Icons.play_arrow : Icons.pause),
              tooltip: rule.isPaused ? l10n.resumeTooltip : l10n.pauseTooltip,
              onPressed: () => _run(
                () => rule.isPaused
                    ? provider.resumeRecurringRule(rule.id)
                    : provider.pauseRecurringRule(rule.id),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.deleteTooltip,
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                _run(() async {
                  final deleted = await provider.deleteRecurringRule(rule.id);
                  // DEL-2: one tap, so Undo for five seconds, as for any
                  // other delete.
                  showUndoSnackBar(
                    messenger,
                    message: l10n.recurringDeleted,
                    undoLabel: l10n.undoButton,
                    failedMessage: l10n.undoFailed,
                    onUndo: () => provider.restoreRecurringRule(deleted),
                  );
                }, close: true);
              },
            ),
          ],
        ],
      ),
      bottomNavigationBar: amountKeypad(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(l10n.expenseLabel),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(l10n.incomeLabel),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() {
                _type = selection.first;
                if (!provider
                    .categoriesFor(_type)
                    .any((c) => c.id == _categoryId)) {
                  _categoryId = provider.defaultCategoryId(_type);
                }
              }),
            ),
            const SizedBox(height: 20),
            amountField(currency, l10n, autofocus: editing == null),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.titleOptionalLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey((_type, _categoryId)),
              // Long names shorten instead of overflowing (LANG-6).
              isExpanded: true,
              initialValue: categories.any((c) => c.id == _categoryId)
                  ? _categoryId
                  : null,
              decoration: InputDecoration(
                labelText: l10n.categoryLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final category in categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text('${category.icon} ${category.label(l10n)}'),
                  ),
              ],
              validator: (value) =>
                  value == null ? l10n.categoryRequired : null,
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            if (accounts.length > 1) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: accounts.any((a) => a.id == _accountId)
                    ? _accountId
                    : null,
                decoration: InputDecoration(
                  labelText: l10n.accountLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final account in accounts)
                    DropdownMenuItem(
                      value: account.id,
                      child: Text(account.label(l10n)),
                    ),
                ],
                onChanged: (value) => setState(() => _accountId = value),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 96,
                  child: TextFormField(
                    controller: _intervalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: l10n.everyLabel,
                      border: const OutlineInputBorder(),
                      // The message names the maximum, which can run past
                      // one line at normal text size or larger (LANG-6).
                      errorMaxLines: 3,
                    ),
                    validator: (value) => _interval(value) == null
                        ? l10n.wholeNumberRange(_intervalMax)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<RecurrenceFrequency>(
                    isExpanded: true,
                    initialValue: _frequency,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final (frequency, label) in [
                        (RecurrenceFrequency.day, l10n.frequencyDays),
                        (RecurrenceFrequency.week, l10n.frequencyWeeks),
                        (RecurrenceFrequency.month, l10n.frequencyMonths),
                        (RecurrenceFrequency.year, l10n.frequencyYears),
                      ])
                        DropdownMenuItem(value: frequency, child: Text(label)),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _frequency = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DateField(
              label: l10n.startsLabel,
              date: _startDate,
              onChanged: (date) => setState(() => _startDate = date),
            ),
            const SizedBox(height: 16),
            Text(l10n.endsLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<RecurrenceEnd>(
              segments: [
                ButtonSegment(
                  value: RecurrenceEnd.never,
                  label: Text(l10n.endNever),
                ),
                ButtonSegment(
                  value: RecurrenceEnd.afterCount,
                  label: Text(l10n.endAfter),
                ),
                ButtonSegment(
                  value: RecurrenceEnd.onDate,
                  label: Text(l10n.endOnDate),
                ),
              ],
              selected: {_endType},
              onSelectionChanged: (selection) => setState(() {
                _endType = selection.first;
                if (_endType == RecurrenceEnd.onDate) {
                  _endDate ??= DateTime(
                    _startDate.year + 1,
                    _startDate.month,
                    _startDate.day,
                  );
                }
              }),
            ),
            if (_endType == RecurrenceEnd.afterCount) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _countController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.timesLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => _wholeNumber(value) == null
                    ? l10n.wholeNumberInvalid
                    : null,
              ),
            ],
            if (_endType == RecurrenceEnd.onDate && endDate != null) ...[
              const SizedBox(height: 12),
              DateField(
                label: l10n.endsOnLabel,
                date: endDate,
                onChanged: (date) => setState(() => _endDate = date),
              ),
            ],
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.autoPostLabel),
              subtitle: Text(l10n.autoPostSubtitle),
              value: _autoPost,
              onChanged: (value) => setState(() => _autoPost = value),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.noteOptionalLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: Text(l10n.saveButton),
            ),
          ],
        ),
      ),
    );
  }
}
