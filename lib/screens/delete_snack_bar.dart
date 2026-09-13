import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';

/// Shows [message] with Undo for five seconds (DEL-2). If [onUndo] fails,
/// shows [failedMessage].
void showUndoSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required String undoLabel,
  required String failedMessage,
  required Future<void> Function() onUndo,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        // Snack bars with an action stay open by default.
        persist: false,
        action: SnackBarAction(
          label: undoLabel,
          onPressed: () async {
            try {
              await onUndo();
            } catch (_) {
              messenger.showSnackBar(SnackBar(content: Text(failedMessage)));
            }
          },
        ),
      ),
    );
}

/// Says the transaction moved to the trash, with Undo.
void showDeletedSnackBar(
  ScaffoldMessengerState messenger,
  TransactionProvider provider,
  AppLocalizations l10n,
  String id,
) => showUndoSnackBar(
  messenger,
  message: l10n.transactionDeleted,
  undoLabel: l10n.undoButton,
  failedMessage: l10n.restoreFailed,
  onUndo: () => provider.restoreTransaction(id),
);

/// Says the transfer was deleted, with Undo.
void showTransferDeletedSnackBar(
  ScaffoldMessengerState messenger,
  TransactionProvider provider,
  AppLocalizations l10n,
  String id,
) => showUndoSnackBar(
  messenger,
  message: l10n.transferDeleted,
  undoLabel: l10n.undoButton,
  failedMessage: l10n.undoFailed,
  onUndo: () => provider.restoreTransfer(id),
);
