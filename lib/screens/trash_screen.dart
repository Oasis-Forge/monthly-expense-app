import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/money.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';

/// Everything waiting to be deleted for good: transactions and transfers
/// alike, most recently deleted first, each with its way back (DEL-3, DEL-4,
/// DEL-5).
class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final entries = <({DateTime at, Widget tile})>[
      for (final tx in provider.deletedTransactions)
        (
          at: tx.deletedAt!,
          tile: _TrashedTransaction(transaction: tx, currency: currency),
        ),
      for (final transfer in provider.deletedTransfers)
        (
          at: transfer.deletedAt!,
          tile: _TrashedTransfer(transfer: transfer, currency: currency),
        ),
    ]..sort((a, b) => b.at.compareTo(a.at));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trashTitle)),
      body: entries.isEmpty
          ? Center(child: Text(l10n.trashEmpty))
          : ListView(children: [for (final entry in entries) entry.tile]),
    );
  }
}

/// The restore button both kinds of row carry (DEL-4).
class _RestoreButton extends StatelessWidget {
  const _RestoreButton({required this.onRestore, required this.failedMessage});

  final Future<void> Function() onRestore;
  final String failedMessage;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.restore),
      tooltip: AppLocalizations.of(context).restoreTooltip,
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await onRestore();
        } catch (_) {
          messenger.showSnackBar(SnackBar(content: Text(failedMessage)));
        }
      },
    );
  }
}

class _TrashedTransaction extends StatelessWidget {
  const _TrashedTransaction({
    required this.transaction,
    required this.currency,
  });

  final ExpenseTransaction transaction;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<TransactionProvider>();
    final category = provider.categoryById(transaction.categoryId);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: categoryTint(category),
        child: Text(category?.icon ?? '📦'),
      ),
      title: Text(transaction.label(category, l10n)),
      subtitle: Text(
        l10n.trashItemSubtitle(
          currency.money(transaction.amount),
          provider.trashDaysLeft(transaction),
        ),
      ),
      trailing: _RestoreButton(
        onRestore: () => provider.restoreTransaction(transaction.id),
        failedMessage: l10n.restoreFailed,
      ),
    );
  }
}

/// A trashed transfer: it has no category, so it reads as its route (ACC-3).
class _TrashedTransfer extends StatelessWidget {
  const _TrashedTransfer({required this.transfer, required this.currency});

  final Transfer transfer;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<TransactionProvider>();
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
      title: Text(
        l10n.transferRoute(
          provider.accountById(transfer.fromAccountId)?.label(l10n) ?? '',
          provider.accountById(transfer.toAccountId)?.label(l10n) ?? '',
        ),
      ),
      subtitle: Text(
        l10n.trashItemSubtitle(
          currency.money(transfer.amount),
          provider.trashDaysLeftForTransfer(transfer),
        ),
      ),
      trailing: _RestoreButton(
        onRestore: () => provider.restoreTransfer(transfer.id),
        failedMessage: l10n.restoreTransferFailed,
      ),
    );
  }
}
