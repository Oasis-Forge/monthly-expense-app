import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/money.dart';
import '../models/note.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/reminder_service.dart';
import 'add_transaction_screen.dart';
import 'delete_snack_bar.dart';
import 'form_fields.dart';
import 'transaction_detail_screen.dart';

/// Adds or edits a note: text, and an optional due date, reminder, amount,
/// and category (NOTE-1).
class NoteFormScreen extends StatefulWidget {
  const NoteFormScreen({super.key, this.editing});

  final Note? editing;

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _amountController = TextEditingController();
  String? _categoryId;
  DateTime? _dueDate;
  TimeOfDay? _reminderTime;

  /// True while a save is in progress, so repeated taps don't save twice.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final note = widget.editing;
    if (note != null) {
      _textController.text = note.text;
      if (note.amount != null) {
        _amountController.text = note.amount!.toInputString();
      }
      _categoryId = note.categoryId;
      _dueDate = note.dueDate;
      final reminderAt = note.reminderAt;
      if (reminderAt != null) {
        _reminderTime = TimeOfDay.fromDateTime(reminderAt);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// The reminder date and time, combining [_dueDate] with [_reminderTime]
  /// (NOTE-6).
  DateTime? get _reminderAt {
    final due = _dueDate;
    final time = _reminderTime;
    if (due == null || time == null) return null;
    return DateTime(due.year, due.month, due.day, time.hour, time.minute);
  }

  void _toggleDueDate(bool on) => setState(() {
    _dueDate = on ? DateTime.now() : null;
    if (!on) _reminderTime = null;
  });

  Future<void> _toggleReminder(bool on) async {
    if (!on) {
      setState(() => _reminderTime = null);
      return;
    }
    // NOTE-6: asked only the first time a reminder is set; everything else
    // still works if it's refused.
    final granted = await context.read<ReminderService>().requestPermission();
    if (!mounted) return;
    setState(() => _reminderTime ??= const TimeOfDay(hour: 9, minute: 0));
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).noteReminderPermissionDenied,
          ),
        ),
      );
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final provider = context.read<TransactionProvider>();
    final settings = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final currency = settings.currencyFormat(l10n.localeName);
    final locale = Localizations.localeOf(context);
    final text = _textController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = amountText.isEmpty
        ? null
        : Money.tryParse(
            amountText,
            maxDecimals: currency.maximumFractionDigits,
          );

    _saving = true;
    try {
      final editing = widget.editing;
      if (editing != null) {
        await provider.updateNote(
          editing.copyWith(
            text: text,
            dueDate: _dueDate,
            reminderAt: _reminderAt,
            amount: amount,
            categoryId: _categoryId,
          ),
          appLockOn: settings.appLock,
          locale: locale,
        );
      } else {
        await provider.addNote(
          Note(
            id: const Uuid().v4(),
            text: text,
            dueDate: _dueDate,
            reminderAt: _reminderAt,
            amount: amount,
            categoryId: _categoryId,
          ),
          appLockOn: settings.appLock,
          locale: locale,
        );
      }
    } catch (_) {
      _saving = false;
      messenger.showSnackBar(SnackBar(content: Text(l10n.noteSaveFailed)));
      return;
    }
    _saving = false;
    if (mounted) Navigator.of(context).pop();
  }

  /// Moves the note to the trash, with Undo on the next screen (NOTE-7).
  Future<void> _delete() async {
    final provider = context.read<TransactionProvider>();
    final settings = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final id = widget.editing!.id;
    try {
      await provider.deleteNote(id);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.noteDeleteFailed)));
      return;
    }
    showUndoSnackBar(
      messenger,
      message: l10n.noteDeleted,
      undoLabel: l10n.undoButton,
      failedMessage: l10n.noteRestoreFailed,
      onUndo: () =>
          provider.restoreNote(id, appLockOn: settings.appLock, locale: locale),
    );
    if (mounted) Navigator.of(context).pop();
  }

  /// Opens the add form prefilled from the note (NOTE-4).
  void _record() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(recordingNote: widget.editing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final isEditing = widget.editing != null;
    final note = widget.editing;

    // Archived categories stay selectable for a note that uses one.
    final sourceCategory = note?.categoryId == null
        ? null
        : provider.categoryById(note!.categoryId!);
    final categories = [
      ...provider.categoriesFor(TransactionType.expense),
      ...provider.categoriesFor(TransactionType.income),
      if (sourceCategory != null && sourceCategory.archivedAt != null)
        sourceCategory,
    ];
    final linkedTransactionId = note?.transactionId;
    final dueDate = _dueDate;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editNoteTitle : l10n.addNoteTitle),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.deleteTooltip,
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _textController,
              autofocus: !isEditing,
              maxLines: null,
              minLines: 2,
              decoration: InputDecoration(
                labelText: l10n.noteTextLabel,
                border: const OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.noteTextRequired
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              textDirection: TextDirection.ltr,
              textAlign: amountTextAlign(context),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.noteAmountOptionalLabel,
                border: const OutlineInputBorder(),
                prefixText: '${currency.currencySymbol} ',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final amount = Money.tryParse(
                  value,
                  maxDecimals: currency.maximumFractionDigits,
                );
                return amount == null || !amount.isPositive
                    ? l10n.amountInvalid
                    : null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: categories.any((c) => c.id == _categoryId)
                  ? _categoryId
                  : null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.noteCategoryOptionalLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(child: Text(l10n.noteCategoryNone)),
                for (final category in categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text('${category.icon} ${category.label(l10n)}'),
                  ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.noteDueDateToggle),
              value: dueDate != null,
              onChanged: _toggleDueDate,
            ),
            if (dueDate != null) ...[
              const SizedBox(height: 8),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.noteDueDateLabel,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: InkWell(
                  onTap: _pickDueDate,
                  child: Text(
                    DateFormat.yMMMEd(l10n.localeName).format(dueDate),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.noteReminderToggle),
                value: _reminderTime != null,
                onChanged: _toggleReminder,
              ),
              if (_reminderTime != null) ...[
                const SizedBox(height: 8),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.noteReminderTimeLabel,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: InkWell(
                    onTap: _pickReminderTime,
                    child: Text(
                      MaterialLocalizations.of(context)
                          .formatTimeOfDay(_reminderTime!),
                    ),
                  ),
                ),
              ],
            ],
            if (linkedTransactionId != null) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text(l10n.noteLinkedTransactionLabel),
                  onTap: () {
                    final tx = provider.transactionById(linkedTransactionId);
                    if (tx == null) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TransactionDetailScreen(id: tx.id),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: Text(
                isEditing ? l10n.saveChangesButton : l10n.addNoteButton,
              ),
            ),
            if (isEditing && note!.isDone == false) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _record,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(l10n.recordNoteButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
