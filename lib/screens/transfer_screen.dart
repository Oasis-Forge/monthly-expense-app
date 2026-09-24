import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/transfer.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'account_edit_screen.dart';
import 'delete_snack_bar.dart';
import 'form_fields.dart';
import 'haptics.dart';

/// Adds or edits a transfer between two accounts (ACC-3).
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, this.editing});

  final Transfer? editing;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen>
    with AmountEntry, UnsavedGuard {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  String? _fromId;
  String? _toId;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    if (editing != null) {
      amountController.text = editing.amount.toInputString();
      _noteController.text = editing.note ?? '';
      _fromId = editing.fromAccountId;
      _toId = editing.toAccountId;
    }
    // A new transfer starts on the day Home is showing, like any other
    // entry (DAY-9).
    _date = editing?.date ?? context.read<TransactionProvider>().newEntryDate;
    // ADD-9: what a later Back compares against.
    snapshotForm();
  }

  /// Everything the user can change here, for the Back guard (ADD-9).
  @override
  String formSnapshot() => [
    amountController.text,
    _noteController.text,
    _fromId ?? '',
    _toId ?? '',
    _date.toIso8601String(),
  ].join('\u0000');

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final currency = context.read<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final amount = parsedAmount(currency)!;
    final note = _noteController.text.trim();

    _saving = true;
    try {
      final editing = widget.editing;
      if (editing != null) {
        await provider.updateTransfer(
          editing.copyWith(
            fromAccountId: _fromId,
            toAccountId: _toId,
            amount: amount,
            date: _date,
            note: note.isEmpty ? null : note,
          ),
        );
      } else {
        await provider.addTransfer(
          Transfer(
            id: const Uuid().v4(),
            fromAccountId: _fromId!,
            toAccountId: _toId!,
            amount: amount,
            date: _date,
            note: note.isEmpty ? null : note,
          ),
        );
      }
    } catch (_) {
      _saving = false;
      messenger.showSnackBar(SnackBar(content: Text(l10n.transferSaveFailed)));
      return;
    }
    _saving = false;
    // HAP-2: the same knock as the entry form, for the same reason.
    saveFeedback();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final id = widget.editing!.id;
    try {
      await provider.deleteTransfer(id);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.transferSaveFailed)));
      return;
    }
    showTransferDeletedSnackBar(messenger, provider, l10n, id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final editing = widget.editing;
    final active = provider.activeAccounts;

    if (editing == null && active.length < 2) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.transferTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.needTwoAccounts, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AccountEditScreen(),
                    ),
                  ),
                  child: Text(l10n.addAccountTitle),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ADD-3: from the last used account, to the next active one.
    _fromId ??= provider.defaultAccountId();
    _toId ??= active.where((a) => a.id != _fromId).firstOrNull?.id;

    final accounts = [
      ...active,
      // Archived accounts stay selectable for a transfer that uses them.
      for (final id in [editing?.fromAccountId, editing?.toAccountId])
        if (id != null && provider.accountById(id)?.archivedAt != null)
          provider.accountById(id)!,
    ];

    Widget accountField(
      String label,
      String? value,
      ValueChanged<String?> onChanged, {
      String? Function(String?)? validator,
    }) {
      return DropdownButtonFormField<String>(
        key: ValueKey((label, value)),
        // Long names shorten instead of overflowing (LANG-6).
        isExpanded: true,
        initialValue: accounts.any((a) => a.id == value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
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
            value == null ? l10n.accountRequired : validator?.call(value),
        onChanged: onChanged,
      );
    }

    return guardBack(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            editing == null ? l10n.transferTitle : l10n.editTransferTitle,
          ),
          actions: [
            if (editing != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.deleteTooltip,
                onPressed: _delete,
              ),
          ],
        ),
        bottomNavigationBar: amountKeypad(),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              amountField(currency, l10n, autofocus: editing == null),
              const SizedBox(height: 16),
              accountField(
                l10n.fromAccountLabel,
                _fromId,
                (value) => setState(() => _fromId = value),
              ),
              const SizedBox(height: 16),
              accountField(
                l10n.toAccountLabel,
                _toId,
                (value) => setState(() => _toId = value),
                validator: (value) =>
                    value == _fromId ? l10n.sameAccountError : null,
              ),
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
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(
                  editing == null
                      ? l10n.addTransferButton
                      : l10n.saveChangesButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
