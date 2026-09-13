import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';

/// Deleted transactions, kept for 30 days and restorable (DEL-3, DEL-4).
class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final deleted = provider.deletedTransactions;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trashTitle)),
      body: deleted.isEmpty
          ? Center(child: Text(l10n.trashEmpty))
          : ListView(
              children: [
                for (final tx in deleted)
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        provider.categoryById(tx.categoryId)?.icon ?? '📦',
                      ),
                    ),
                    title: Text(
                      tx.label(provider.categoryById(tx.categoryId), l10n),
                    ),
                    subtitle: Text(
                      l10n.trashItemSubtitle(
                        currency.format(tx.amount.toDouble()),
                        provider.trashDaysLeft(tx),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.restore),
                      tooltip: l10n.restoreTooltip,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await provider.restoreTransaction(tx.id);
                        } catch (_) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.restoreFailed)),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
