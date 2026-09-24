import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/account.dart';
import '../models/note.dart';
import '../models/transaction.dart';
import '../providers/ads_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'attachment_field.dart';
import 'delete_snack_bar.dart';
import 'form_fields.dart';
import 'haptics.dart';
import 'note_form_screen.dart';
import 'rating_prompt.dart';

class AddTransactionScreen extends StatefulWidget {
  /// Edits [editing] when set. Otherwise adds a new transaction, prefilled
  /// from [template] when duplicating one (ADD-7), or from [recordingNote]'s
  /// amount, category, and text as the title, dated today (NOTE-4). Saving
  /// then marks that note done and links the two.
  ///
  /// [startAs] opens on income instead of expense, for the home-screen
  /// widget's Add income button (WID-3). The other prefills win over it.
  const AddTransactionScreen({
    super.key,
    this.editing,
    this.template,
    this.recordingNote,
    this.startAs,
  });

  final ExpenseTransaction? editing;
  final ExpenseTransaction? template;
  final Note? recordingNote;
  final TransactionType? startAs;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with AmountEntry, UnsavedGuard {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  String? _photoFile;
  String? _voiceFile;

  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  String? _accountId;
  late DateTime _date;

  /// True while a save is in progress, so repeated taps don't save twice.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TransactionProvider>();
    final source = widget.editing ?? widget.template;
    final note = widget.recordingNote;
    if (source != null) {
      _titleController.text = source.title ?? '';
      amountController.text = source.amount.toInputString();
      _noteController.text = source.note ?? '';
      _type = source.type;
      _categoryId = source.categoryId;
      _accountId = source.accountId;
      // A duplicate starts without the original's attachments: two records
      // must never share one file (ADD-7, ATT-5).
      _photoFile = widget.editing?.photoFile;
      _voiceFile = widget.editing?.voiceFile;
    } else if (note != null) {
      // NOTE-4: the note's amount, category, and text as the title.
      _titleController.text = note.text;
      if (note.amount != null) {
        amountController.text = note.amount!.toInputString();
      }
      final category = note.categoryId == null
          ? null
          : provider.categoryById(note.categoryId!);
      _type = category?.type ?? _type;
      _categoryId = category?.id ?? provider.defaultCategoryId(_type);
      _accountId = provider.defaultAccountId();
    } else {
      _type = widget.startAs ?? _type;
      // ADD-3: the last category and account used.
      _categoryId = provider.defaultCategoryId(_type);
      _accountId = provider.defaultAccountId();
    }
    // A new transaction starts on the day Home is showing, which is today
    // unless the strip says otherwise (ADD-3, DAY-9). A duplicate or a
    // recorded note is dated now either way (ADD-7, NOTE-4).
    _date =
        widget.editing?.date ??
        (source == null && note == null
            ? provider.newEntryDate
            : DateTime.now());
    // ADD-9: what a later Back compares against.
    snapshotForm();
  }

  /// Everything the user can change here, for the Back guard (ADD-9).
  @override
  String formSnapshot() => [
    amountController.text,
    _titleController.text,
    _noteController.text,
    _type.name,
    _categoryId ?? '',
    _accountId ?? '',
    _date.toIso8601String(),
    _photoFile ?? '',
    _voiceFile ?? '',
  ].join('\u0000');

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectType(TransactionType type) {
    final provider = context.read<TransactionProvider>();
    setState(() {
      _type = type;
      if (!provider.categoriesFor(type).any((c) => c.id == _categoryId)) {
        _categoryId = provider.defaultCategoryId(type);
      }
    });
  }

  Future<void> _submit({bool addAnother = false}) async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final provider = context.read<TransactionProvider>();
    final settings = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ads = context.read<AdsProvider>();
    final currency = settings.currencyFormat(l10n.localeName);
    final locale = Localizations.localeOf(context);
    final amount = parsedAmount(currency)!;
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();
    final recordingNote = widget.recordingNote;

    _saving = true;
    try {
      final editing = widget.editing;
      if (editing != null) {
        await provider.updateTransaction(
          editing.copyWith(
            title: title.isEmpty ? null : title,
            amount: amount,
            categoryId: _categoryId,
            accountId: _accountId,
            type: _type,
            date: _date,
            note: note.isEmpty ? null : note,
            photoFile: _photoFile,
            voiceFile: _voiceFile,
          ),
        );
      } else {
        final tx = ExpenseTransaction(
          id: const Uuid().v4(),
          title: title.isEmpty ? null : title,
          amount: amount,
          categoryId: _categoryId!,
          accountId: _accountId ?? Account.cashId,
          type: _type,
          date: _date,
          note: note.isEmpty ? null : note,
          photoFile: _photoFile,
          voiceFile: _voiceFile,
        );
        await provider.addTransaction(tx);
        if (recordingNote != null) {
          await provider.recordNote(
            recordingNote.id,
            tx.id,
            appLockOn: settings.appLock,
            locale: locale,
          );
        }
      }
    } catch (_) {
      _saving = false;
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      return;
    }
    _saving = false;
    // HAP-2: one knock, and only once the record is written.
    saveFeedback();
    // ADD-4 or not, a saved entry is a thing done (ADS-12).
    unawaited(ads.noteActivity());
    if (!mounted) return;
    // RATE-3: the app has just done the thing it is for, which is the only
    // moment worth asking in. It comes to nothing unless the lines in
    // RATE-1 have been crossed, and it never asks twice for a version.
    unawaited(askForRatingIfDue(context));

    if (addAnother) {
      // ADD-4: keep the type, category, account, and date.
      amountController.clear();
      _titleController.clear();
      _noteController.clear();
      setState(() {
        _photoFile = null;
        _voiceFile = null;
      });
      amountFocus.requestFocus();
      // ADD-4 emptied the form on purpose, so that is the new starting point.
      snapshotForm();
      messenger.showSnackBar(SnackBar(content: Text(l10n.transactionAdded)));
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Moves the edited transaction to the trash, with Undo on the next screen.
  /// This is also the delete path for mouse users, who can't swipe.
  Future<void> _delete() async {
    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final id = widget.editing!.id;
    try {
      await provider.deleteTransaction(id);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
      return;
    }
    showDeletedSnackBar(messenger, provider, l10n, id);
    if (mounted) Navigator.of(context).pop();
  }

  /// Opens a new, unsaved copy of the edited transaction (ADD-7).
  void _duplicate() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(template: widget.editing),
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
    final source = widget.editing ?? widget.template;
    // NOTE-4: shows the note this transaction was recorded from, if any.
    final linkedNote = widget.editing == null
        ? null
        : provider.noteForTransaction(widget.editing!.id);

    // Archived choices stay selectable for a transaction that uses them.
    final sourceCategory = source == null
        ? null
        : provider.categoryById(source.categoryId);
    final categories = [
      ...provider.categoriesFor(_type),
      if (sourceCategory != null &&
          sourceCategory.archivedAt != null &&
          sourceCategory.type == _type)
        sourceCategory,
    ];
    final sourceAccount = source == null
        ? null
        : provider.accountById(source.accountId);
    final accounts = [
      ...provider.activeAccounts,
      if (sourceAccount != null && sourceAccount.archivedAt != null)
        sourceAccount,
    ];
    final recent = provider.recentCategories(_type);

    return guardBack(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing
                ? l10n.editTransactionTitle
                : widget.recordingNote != null
                ? l10n.recordNoteButton
                : l10n.addTransactionTitle,
          ),
          actions: [
            if (isEditing) ...[
              IconButton(
                icon: const Icon(Icons.copy_outlined),
                tooltip: l10n.duplicateTooltip,
                onPressed: _duplicate,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.deleteTooltip,
                onPressed: _delete,
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
                    icon: const Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text(l10n.incomeLabel),
                    icon: const Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) => _selectType(selection.first),
              ),
              const SizedBox(height: 20),
              amountField(currency, l10n, autofocus: !isEditing),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.titleOptionalLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (recent.isNotEmpty) ...[
                // ADD-5: recently used categories, one tap away.
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final category in recent)
                      ChoiceChip(
                        label: Text('${category.icon} ${category.label(l10n)}'),
                        selected: category.id == _categoryId,
                        onSelected: (_) =>
                            setState(() => _categoryId = category.id),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              DropdownButtonFormField<String>(
                // A new key resets the field when the type or a chip changes it.
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
                  validator: (value) =>
                      value == null ? l10n.accountRequired : null,
                  onChanged: (value) => setState(() => _accountId = value),
                ),
              ],
              const SizedBox(height: 16),
              DateField(
                date: _date,
                onChanged: (date) => setState(() => _date = date),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: l10n.noteOptionalLabel,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              AttachmentField(
                photoFile: _photoFile,
                voiceFile: _voiceFile,
                onPhotoChanged: (name) => setState(() => _photoFile = name),
                onVoiceChanged: (name) => setState(() => _voiceFile = name),
              ),
              if (linkedNote != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.sticky_note_2_outlined),
                    title: Text(l10n.noteLinkedNoteLabel),
                    subtitle: Text(linkedNote.text),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NoteFormScreen(editing: linkedNote),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(
                  isEditing
                      ? l10n.saveChangesButton
                      : widget.recordingNote != null
                      ? l10n.recordNoteButton
                      : l10n.addTransactionButton,
                ),
              ),
              if (!isEditing && widget.recordingNote == null) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _submit(addAnother: true),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(l10n.saveAndAddAnotherButton),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
