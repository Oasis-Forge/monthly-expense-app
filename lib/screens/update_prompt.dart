import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/app_update.dart';
import '../providers/ads_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/update_service.dart';

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

    // UPD-4: spent here, before Play is given the chance to decline.
    await settings.markUpdateAsked(transactions.today);
    // Declined, failed or cancelled are all the same to the app, and all of
    // them still count as having asked today (UPD-1).
    if (!alreadyDownloaded && !await updates.download()) return true;

    messenger?.showSnackBar(
      SnackBar(
        content: Text(l10n.updateDownloadedMessage),
        // Snack bars with an action stay open by default, which would
        // otherwise block every later message behind this one for good
        // (UPD-1). An explicit duration -- matching the undo bar's -- keeps
        // it up long enough to notice instead of falling back to the
        // default 4 seconds.
        persist: false,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: l10n.updateRestartButton,
          onPressed: updates.install,
        ),
      ),
    );
    return true;
  };
}
