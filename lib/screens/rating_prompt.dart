import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/rating.dart';
import '../providers/ads_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/review_service.dart';

/// Reads everything the rating ask needs from [context] and hands back the
/// asking itself, to be awaited after (RATE-1 to RATE-4).
///
/// Split this way because the seam runs as an entry is saved and the screen
/// may close behind it: nothing here may reach for a provider once the first
/// await has passed. The update ask is read the same way and goes first
/// (UPD-3).
Future<void> Function() ratingRequest(BuildContext context) {
  final reviews = context.read<ReviewService>();
  final settings = context.read<SettingsProvider>();
  final transactions = context.read<TransactionProvider>();
  final ads = context.read<AdsProvider>();

  return () async {
    if (!reviews.supported) return;
    final version = await reviews.version();

    final due = ratingIsDue(
      entries: transactions.transactions.length,
      firstOpened: settings.firstOpenedAt,
      now: transactions.today,
      version: version,
      askedVersion: settings.ratingAskedVersion,
      locked: ads.locked,
      adShownThisSession: ads.interstitialShown,
    );
    if (!due) return;

    // RATE-4: the asking is spent here, before the store is given the chance
    // to decide it would rather not.
    await settings.markRatingAsked(version);
    await reviews.ask();
  };
}
