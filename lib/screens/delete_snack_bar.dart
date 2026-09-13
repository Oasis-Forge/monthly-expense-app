import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';

/// Says the transaction moved to the trash and offers Undo for five seconds
/// (DEL-2).
void showDeletedSnackBar(
  ScaffoldMessengerState messenger,
  TransactionProvider provider,
  AppLocalizations l10n,
  String id,
) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.transactionDeleted),
        duration: const Duration(seconds: 5),
        // Snack bars with an action stay open by default.
        persist: false,
        action: SnackBarAction(
          label: l10n.undoButton,
          onPressed: () async {
            try {
              await provider.restoreTransaction(id);
            } catch (_) {
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.restoreFailed)),
              );
            }
          },
        ),
      ),
    );
}
