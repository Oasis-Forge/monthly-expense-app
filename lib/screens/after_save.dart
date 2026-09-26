import 'package:flutter/widgets.dart';

import 'rating_prompt.dart';
import 'update_prompt.dart';

/// The one seam after an entry is saved (UPD-2, RATE-3).
///
/// Both asks read what they need from [context] first, before anything is
/// awaited, so a screen closing behind this takes neither decision with it.
/// The update goes first and the rating waits for another day where both
/// come due together: a working app matters more than a star (UPD-3).
///
/// Callers only invoke this for a save that actually closes the form: one
/// kept open on purpose ("Save & add another", ADD-4) must not call this,
/// or the ask would land over the next entry instead of never mid-entry
/// (UPD-2, pr58#7).
Future<void> afterSave(BuildContext context) async {
  final update = updateRequest(context);
  final rating = ratingRequest(context);
  if (await update()) return;
  await rating();
}
