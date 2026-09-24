import 'package:flutter/widgets.dart';

import 'rating_prompt.dart';
import 'update_prompt.dart';

/// The one seam after an entry is saved (UPD-2, RATE-3).
///
/// Both asks read what they need from [context] first, before anything is
/// awaited, so a screen closing behind this takes neither decision with it.
/// The update goes first and the rating waits for another day where both
/// come due together: a working app matters more than a star (UPD-3).
Future<void> afterSave(BuildContext context) async {
  final update = updateRequest(context);
  final rating = ratingRequest(context);
  if (await update()) return;
  await rating();
}
