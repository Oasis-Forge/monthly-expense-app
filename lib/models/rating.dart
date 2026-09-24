/// Fifteen entries, the first of RATE-1's two lines.
const ratingEntries = 15;

/// A week with the app, the second of them.
const ratingAge = Duration(days: 7);

/// Whether this is a moment to ask for a rating (RATE-1, RATE-3).
///
/// Everything the answer rests on is passed in, so the decision can be tried
/// at every one of its boundaries without a store, a device or a clock. The
/// caller asks only where an entry has just been saved, which is the part of
/// RATE-3 that cannot be decided here.
bool ratingIsDue({
  required int entries,
  required DateTime firstOpened,
  required DateTime now,
  required String version,
  required String? askedVersion,
  required bool locked,
  required bool adShownThisSession,
}) {
  // RATE-3: not over a lock screen, and not in a visit that has already been
  // interrupted once.
  if (locked || adShownThisSession) return false;
  // RATE-4: asked is spent, whatever the store did with it.
  if (askedVersion == version) return false;
  // RATE-1: three entries is not an opinion, and a day is not a trial.
  if (entries < ratingEntries) return false;
  return !now.isBefore(firstOpened.add(ratingAge));
}
