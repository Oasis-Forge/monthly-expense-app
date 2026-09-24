import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/rating.dart';
import '../providers/ads_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/review_service.dart';

/// Asks for a rating if this is a moment for one (RATE-1 to RATE-4).
///
/// Called where an entry has just been saved and nowhere else: that it is a
/// good moment is the one part of RATE-3 no pure function can know. Every
/// provider is read before the first await, so a screen that closes behind
/// this does not take the decision with it.
Future<void> askForRatingIfDue(BuildContext context) async {
  final reviews = context.read<ReviewService>();
  if (!reviews.supported) return;

  final settings = context.read<SettingsProvider>();
  final transactions = context.read<TransactionProvider>();
  final ads = context.read<AdsProvider>();
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
}
