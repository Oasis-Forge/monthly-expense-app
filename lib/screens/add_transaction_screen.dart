import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'delete_snack_bar.dart';
import 'form_fields.dart';

class AddTransactionScreen extends StatefulWidget {
  /// Edits [editing] when set. Otherwise adds a new transaction, prefilled
  /// from [template] when duplicating one (ADD-7).
  const AddTransactionScreen({super.key, this.editing, this.template});

  final ExpenseTransaction? editing;
  final ExpenseTransaction? template;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with AmountEntry {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

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
    if (source != null) {
      _titleController.text = source.title ?? '';
      amountController.text = source.amount.toInputString();
      _noteController.text = source.note ?? '';
      _type = source.type;
      _categoryId = source.categoryId;
      _accountId = source.accountId;
    } else {
      // ADD-3: the last category and account used.
      _categoryId = provider.defaultCategoryId(_type);
      _accountId = provider.defaultAccountId();
    }
    // A new transaction or a duplicate is dated now (ADD-3, ADD-7).
    _date = widget.editing?.date ?? DateTime.now();
  }

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
    final messenger = ScaffoldMessenger.of(context);
    final currency = context.read<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final amount = parsedAmount(currency)!;
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();

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
          ),
        );
      } else {
        await provider.addTransaction(
          ExpenseTransaction(
            id: const Uuid().v4(),
            title: title.isEmpty ? null : title,
            amount: amount,
            categoryId: _categoryId!,
            accountId: _accountId ?? Account.cashId,
            type: _type,
            date: _date,
            note: note.isEmpty ? null : note,
          ),
        );
      }
    } catch (_) {
      _saving = false;
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      return;
    }
    _saving = false;
    if (!mounted) return;

    if (addAnother) {
      // ADD-4: keep the type, category, account, and date.
      amountController.clear();
      _titleController.clear();
      _noteController.clear();
      amountFocus.requestFocus();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editTransactionTitle : l10n.addTransactionTitle,
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
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: Text(
                isEditing ? l10n.saveChangesButton : l10n.addTransactionButton,
              ),
            ),
            if (!isEditing) ...[
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
    );
  }
}
