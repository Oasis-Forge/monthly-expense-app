import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/account.dart';
import '../models/money.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final ExpenseTransaction? editing;

  const AddTransactionScreen({super.key, this.editing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  late DateTime _date;

  /// True while a save is in progress, so repeated taps don't save twice.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    if (editing != null) {
      _titleController.text = editing.title ?? '';
      _amountController.text = editing.amount.toInputString();
      _noteController.text = editing.note ?? '';
      _type = editing.type;
      _categoryId = editing.categoryId;
      _date = editing.date;
    } else {
      final options = context.read<TransactionProvider>().categoriesFor(_type);
      _categoryId = options.isEmpty ? null : options.first.id;
      _date = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectType(TransactionType type) {
    final options = context.read<TransactionProvider>().categoriesFor(type);
    setState(() {
      _type = type;
      if (!options.any((c) => c.id == _categoryId)) {
        _categoryId = options.isEmpty ? null : options.first.id;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final provider = context.read<TransactionProvider>();
    final l10n = AppLocalizations.of(context);
    final amount = Money.tryParse(_amountController.text)!;
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
            accountId: Account.cashId,
            type: _type,
            date: _date,
            note: note.isEmpty ? null : note,
          ),
        );
      }
    } catch (_) {
      _saving = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = context.watch<TransactionProvider>().categoriesFor(
      _type,
    );
    final isEditing = widget.editing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editTransactionTitle : l10n.addTransactionTitle,
        ),
      ),
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
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.titleOptionalLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.amountLabel,
                border: const OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.amountRequired;
                }
                final amount = Money.tryParse(value);
                if (amount == null || !amount.isPositive) {
                  return l10n.amountInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              // A new key per type resets the field when the type changes.
              key: ValueKey(_type),
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
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.dateLabel),
              subtitle: Text(DateFormat.yMMMd(l10n.localeName).format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
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
          ],
        ),
      ),
    );
  }
}
