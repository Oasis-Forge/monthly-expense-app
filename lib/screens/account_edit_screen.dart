import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/account.dart';
import '../models/money.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'form_fields.dart';

/// Adds or edits an account: name, type, opening balance, and opening date
/// (ACC-1). Editing also offers archive and, for unused accounts, delete
/// (ACC-5).
class AccountEditScreen extends StatefulWidget {
  const AccountEditScreen({super.key, this.editing});

  final Account? editing;

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _openingController = TextEditingController();

  AccountType _type = AccountType.bank;
  late DateTime _openingDate;

  /// The name shown when the screen opened; an unchanged default name stays
  /// translated.
  String _initialName = '';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final editing = widget.editing;
    final now = DateTime.now();
    _openingDate =
        editing?.openingDate ?? DateTime(now.year, now.month, now.day);
    if (editing != null) {
      _initialName = editing.label(AppLocalizations.of(context));
      _nameController.text = _initialName;
      _type = editing.type;
      final opening = editing.openingBalance;
      _openingController.text = opening.isNegative
          ? '-${(-opening).toInputString()}'
          : opening.toInputString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _openingController.dispose();
    super.dispose();
  }

  /// An empty field means zero; a leading `-` means a negative balance.
  static Money? _parseOpening(String input, int maxDecimals) {
    final text = input.trim();
    if (text.isEmpty) return Money.zero;
    final negative = text.startsWith('-');
    final amount = Money.tryParse(
      negative ? text.substring(1) : text,
      maxDecimals: maxDecimals,
    );
    if (amount == null) return null;
    return negative ? -amount : amount;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final currency = context.read<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final name = _nameController.text.trim();
    final opening = _parseOpening(
      _openingController.text,
      currency.maximumFractionDigits,
    )!;

    try {
      final editing = widget.editing;
      if (editing == null) {
        await provider.addAccount(
          name: name,
          type: _type,
          openingBalance: opening,
          openingDate: _openingDate,
        );
      } else {
        await provider.updateAccount(
          editing.copyWith(
            name: name == _initialName ? editing.name : name,
            type: _type,
            openingBalance: opening,
            openingDate: _openingDate,
          ),
        );
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountSaveFailed)));
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  /// Runs archive, unarchive, or delete, then closes the screen.
  Future<void> _run(Future<void> Function() change) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await change();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountSaveFailed)));
      return;
    }
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
    final isArchived = editing?.archivedAt != null;
    final canLeaveActive = isArchived || provider.activeAccounts.length > 1;
    final takenNames = {
      for (final account in provider.accounts)
        if (account.id != editing?.id) account.label(l10n).toLowerCase(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing == null ? l10n.addAccountTitle : l10n.editAccountTitle,
        ),
        actions: [
          if (editing != null && isArchived)
            IconButton(
              icon: const Icon(Icons.unarchive_outlined),
              tooltip: l10n.unarchiveAction,
              onPressed: () =>
                  _run(() => provider.unarchiveAccount(editing.id)),
            ),
          // Keep at least one active account.
          if (editing != null && !isArchived && canLeaveActive)
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              tooltip: l10n.archiveAction,
              onPressed: () => _run(() => provider.archiveAccount(editing.id)),
            ),
          if (editing != null &&
              canLeaveActive &&
              !provider.isAccountUsed(editing.id))
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.deleteTooltip,
              onPressed: () => _run(() => provider.deleteAccount(editing.id)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: editing == null,
              decoration: InputDecoration(
                labelText: l10n.categoryNameLabel,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return l10n.categoryNameRequired;
                if (takenNames.contains(name.toLowerCase())) {
                  return l10n.categoryNameTaken;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AccountType>(
              // Long names shorten instead of overflowing (LANG-6).
              isExpanded: true,
              initialValue: _type,
              decoration: InputDecoration(
                labelText: l10n.accountTypeLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final type in AccountType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(accountTypeIcon(type)),
                        const SizedBox(width: 12),
                        Flexible(child: Text(accountTypeLabel(type, l10n))),
                      ],
                    ),
                  ),
              ],
              onChanged: (type) {
                if (type != null) setState(() => _type = type);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _openingController,
              textDirection: TextDirection.ltr,
              textAlign: amountTextAlign(context),
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.openingBalanceLabel,
                border: const OutlineInputBorder(),
                prefixText: '${currency.currencySymbol} ',
              ),
              validator: (value) =>
                  _parseOpening(value ?? '', currency.maximumFractionDigits) ==
                      null
                  ? l10n.amountInvalid
                  : null,
            ),
            const SizedBox(height: 16),
            DateField(
              label: l10n.openingDateLabel,
              date: _openingDate,
              onChanged: (date) => setState(() => _openingDate = date),
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
