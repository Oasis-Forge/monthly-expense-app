import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import 'delete_snack_bar.dart';

enum _RowAction { duplicate, delete }

/// The three-dot button at the trailing edge of a transaction row (ROW-1).
/// Duplicate opens the form prefilled and writes nothing until it is saved
/// (ROW-2, ADD-7); Delete asks first, then moves the entry to the trash with
/// the usual Undo (ROW-3, DEL-2, DEL-3). A swipe still deletes without a
/// question (ROW-4).
class TransactionRowMenu extends StatelessWidget {
  const TransactionRowMenu({super.key, required this.transaction});

  final ExpenseTransaction transaction;

  void _duplicate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(template: transaction),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    // ROW-3: a tap in a menu is easy to hit by mistake, so this one asks.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTransactionTitle),
        content: Text(l10n.deleteTransactionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteTooltip),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    try {
      await provider.deleteTransaction(transaction.id);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
      return;
    }
    showDeletedSnackBar(messenger, provider, l10n, transaction.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<_RowAction>(
      tooltip: l10n.rowMenuTooltip,
      // Tight, so the amount beside it keeps its room in every language.
      padding: EdgeInsets.zero,
      iconSize: 20,
      onSelected: (action) {
        switch (action) {
          case _RowAction.duplicate:
            _duplicate(context);
          case _RowAction.delete:
            _delete(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _RowAction.duplicate,
          child: Row(
            children: [
              const Icon(Icons.copy_outlined, size: 20),
              const SizedBox(width: 12),
              Flexible(child: Text(l10n.duplicateTooltip)),
            ],
          ),
        ),
        PopupMenuItem(
          value: _RowAction.delete,
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 20),
              const SizedBox(width: 12),
              Flexible(child: Text(l10n.deleteTooltip)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A row's amount with its menu beside it (ROW-1), for the lists that show
/// transactions: Home, Search, and the calendar.
class TransactionRowTrailing extends StatelessWidget {
  const TransactionRowTrailing({
    super.key,
    required this.amount,
    required this.transaction,
  });

  final Widget amount;
  final ExpenseTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // A long amount shrinks before it pushes the menu off the row.
        Flexible(
          child: FittedBox(fit: BoxFit.scaleDown, child: amount),
        ),
        TransactionRowMenu(transaction: transaction),
      ],
    );
  }
}
