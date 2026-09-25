import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/app_update.dart';
import '../providers/ads_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/update_service.dart';
import 'form_fields.dart' show activeUnsavedFormGuard;

/// Reads everything the update ask needs from [context] and hands back the
/// asking itself, to be awaited after.
///
/// Split this way because the seam runs as an entry is saved and the screen
/// may close behind it: nothing here may reach for a provider once the first
/// await has passed (UPD-2).
///
/// The returned future answers true when an update was offered, which is
/// what makes the rating wait for another day (UPD-3).
Future<bool> Function() updateRequest(BuildContext context) {
  final updates = context.read<UpdateService>();
  final settings = context.read<SettingsProvider>();
  final transactions = context.read<TransactionProvider>();
  final ads = context.read<AdsProvider>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l10n = AppLocalizations.of(context);
  // The form that is saving and about to close, if any -- it called this
  // from its own _submit, before popping, so it is still `mounted` and
  // still the active guard for a moment yet. Captured here so the checks
  // below can tell that form apart from a genuinely different one opened
  // later, in the gap while this awaits Play (UPD-2, pr58#7).
  final formClosing = activeUnsavedFormGuard;

  /// Whether some other form -- never this closing one -- is on screen now.
  bool anotherFormOpen() =>
      activeUnsavedFormGuard != null && activeUnsavedFormGuard != formClosing;

  return () async {
    if (!updates.supported) return false;
    final due = updateIsDue(
      now: transactions.today,
      askedOn: settings.updateAskedOn,
      locked: ads.locked,
    );
    if (!due) return false;
    // A download Play already finished in the background, from a run whose
    // restart offer never landed or was pushed off by a later message, is
    // offered again straight away rather than started a second time (UPD-1).
    final alreadyDownloaded = await updates.downloaded();
    if (!alreadyDownloaded && !await updates.available()) return false;

    // A different form may have opened while either await above waited on
    // Play: the ask waits for a save that actually closes a form, never
    // mid-entry (UPD-2, pr58#7). Bail before spending today's ask (UPD-4
    // below), so a later closing save tries again instead of the app
    // staying quiet for the rest of the day over a download it never
    // started.
    if (anotherFormOpen()) return false;

    // UPD-4: spent here, before Play is given the chance to decline.
    await settings.markUpdateAsked(transactions.today);
    // Declined, failed or cancelled are all the same to the app, and all of
    // them still count as having asked today (UPD-1).
    if (!alreadyDownloaded && !await updates.download()) return true;

    // The download itself can run 30 to 60 seconds (UPD-1): a form opened
    // while it ran must not have the bar land over it either (UPD-2,
    // pr58#7). UPD-1's own downloaded() branch above offers it again at the
    // next closing save instead of showing it now.
    if (!anotherFormOpen()) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(l10n.updateDownloadedMessage),
          // Snack bars with an action stay open by default, which would
          // otherwise block every later message behind this one for good
          // (UPD-1). An explicit duration -- matching the undo bar's --
          // keeps it up long enough to notice instead of falling back to
          // the default 4 seconds.
          persist: false,
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: l10n.updateRestartButton,
            onPressed: () => _restart(updates),
          ),
        ),
      );
    }
    return true;
  };
}

/// Restarts for the update, unless a form has opened since the bar
/// appeared and there's something on it to lose, in which case it asks the
/// same "Discard changes?" question Back would (ADD-9) rather than take an
/// unsaved entry down with it (UPD-2, pr58#7).
Future<void> _restart(UpdateService updates) async {
  final guard = activeUnsavedFormGuard;
  if (guard != null && guard.hasUnsavedEdits()) {
    if (!await guard.confirmDiscard()) return;
  }
  await updates.install();
}
