/// Whether the app may offer an update in this moment (UPD-2, UPD-4).
///
/// Pure, so the whole decision can be tested without Play, a clock or a
/// screen. Whether the moment itself is a good one -- an entry has just been
/// saved, and nothing failed -- is the caller's to know (UPD-2).
bool updateIsDue({
  required DateTime now,
  required DateTime? askedOn,
  required bool locked,
}) {
  // LOCK-1: nothing is put in front of a locked app.
  if (locked) return false;
  final asked = askedOn?.toLocal();
  if (asked == null) return true;
  // Once a day, whatever came of it (UPD-4).
  return asked.year != now.year ||
      asked.month != now.month ||
      asked.day != now.day;
}
