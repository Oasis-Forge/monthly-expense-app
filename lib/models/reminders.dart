import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, immutable;

import 'money.dart';
import 'recurring_rule.dart';
import 'transaction.dart';

/// Whether this build can schedule the app's own reminders at all: phones
/// only, so the desktop builds offer nothing they cannot do (NUDGE-10).
bool get remindersSupported =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// What a reminder the app sends is about (NUDGE-1). There are two, and no
/// screen adds a third without a rule.
enum ReminderKind {
  /// A recurring entry was due and is still waiting for a tap (NUDGE-2).
  dueEntry,

  /// A day is ending with nothing recorded in it (NUDGE-4).
  emptyDay,
}

/// How many days ahead reminders are scheduled.
///
/// Three, and that is not arbitrary: an app that is never opened again can
/// only say three more things before it falls silent, which is the same
/// number NUDGE-5 gives up after. Nothing has to notice the silence for it
/// to happen.
const reminderHorizonDays = 3;

/// The hour a due entry is announced at. Morning, because that is when
/// something dated today can still be dealt with.
const dueEntryHour = 9;

/// Nothing is sent before this hour, or from that one (NUDGE-6).
const quietUntilHour = 8;
const quietFromHour = 22;

/// A reminder the app has decided to send, and when (NUDGE-1).
@immutable
class PlannedReminder {
  const PlannedReminder({
    required this.kind,
    required this.at,
    this.title,
    this.count = 1,
    this.dueDate,
    this.amount,
    this.isIncome = false,
  });

  final ReminderKind kind;

  /// Local time. The device's own clock decides the day (NUDGE-6).
  final DateTime at;

  /// The rule's name, for the one entry a [ReminderKind.dueEntry] can name.
  /// Null when [count] is more than one, or when the app is locked.
  final String? title;

  /// How many entries were due that day. More than one is announced as a
  /// count rather than a list, so the notification stays one line (NUDGE-2).
  final int count;

  /// The single named entry's own due date, for saying "was due {date}"
  /// instead of "was due today" once it is no longer today (NUDGE-2,
  /// rules-23-26-34#9). Null when [count] is more than one -- several due
  /// the same day are announced together and carry no date of their own.
  final DateTime? dueDate;

  /// The single named entry's amount, so the reminder says "for how much"
  /// (NUDGE-2, rules-23-26-34#9). Null when [count] is more than one.
  final Money? amount;

  /// Whether [amount] is income rather than an expense, for the sign it is
  /// shown with (CUR-5). Meaningless when [amount] is null.
  final bool isIncome;

  @override
  bool operator ==(Object other) =>
      other is PlannedReminder &&
      other.kind == kind &&
      other.at == at &&
      other.title == title &&
      other.count == count &&
      other.dueDate == dueDate &&
      other.amount == amount &&
      other.isIncome == isIncome;

  @override
  int get hashCode =>
      Object.hash(kind, at, title, count, dueDate, amount, isIncome);

  @override
  String toString() => 'PlannedReminder($kind, $at, $title, x$count)';
}

/// What the user has said about the empty-day nudge (NUDGE-3, NUDGE-4), as
/// the provider that schedules reminders needs it.
@immutable
class NudgeSettings {
  const NudgeSettings({
    required this.on,
    required this.hour,
    required this.minute,
  });

  /// Nothing said, for a caller that has no settings to hand.
  static const off = NudgeSettings(on: false, hour: 21, minute: 0);

  final bool on;
  final int hour;
  final int minute;

  @override
  bool operator ==(Object other) =>
      other is NudgeSettings &&
      other.on == on &&
      other.hour == hour &&
      other.minute == minute;

  @override
  int get hashCode => Object.hash(on, hour, minute);
}

/// What the app should have scheduled right now (NUDGE-1 to NUDGE-6).
///
/// [due] is what is already waiting for a tap (dated today or earlier), and
/// [upcoming] what falls due later; both hold only the rules that wait to be
/// confirmed, never the ones that post themselves. [recordedToday] is what
/// keeps a day that already has an entry in it from being told it is empty
/// (NUDGE-4).
///
/// Nothing is planned outside the quiet hours, nothing is planned for a time
/// that has already passed, and a day with something due is never also told
/// that it is empty (NUDGE-6).
List<PlannedReminder> planReminders({
  required DateTime now,
  required List<ScheduledOccurrence> due,
  required List<ScheduledOccurrence> upcoming,
  required bool emptyDayOn,
  required int emptyDayHour,
  required int emptyDayMinute,
  required bool recordedToday,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final plan = <PlannedReminder>[];
  final spokenFor = <DateTime>{};

  // Anything already waiting is announced on the first morning that has not
  // gone by, together with whatever falls due that same day.
  var overdueAnnounced = false;

  for (var offset = 0; offset < reminderHorizonDays; offset++) {
    final day = DateTime(today.year, today.month, today.day + offset);
    final at = DateTime(day.year, day.month, day.day, dueEntryHour);
    if (!at.isAfter(now)) continue;

    final falling = [
      for (final occurrence in upcoming)
        if (_sameDay(occurrence.date, day)) occurrence,
    ];
    final announcing = [...falling, if (!overdueAnnounced) ...due];
    if (announcing.isEmpty) continue;
    overdueAnnounced = true;

    spokenFor.add(day);
    final single = announcing.length == 1 ? announcing.single : null;
    plan.add(
      PlannedReminder(
        kind: ReminderKind.dueEntry,
        at: at,
        title: single?.rule.title,
        count: announcing.length,
        dueDate: single?.date,
        amount: single?.rule.amount,
        isIncome: single?.rule.type == TransactionType.income,
      ),
    );
  }

  if (!emptyDayOn || !_awake(emptyDayHour)) return plan;

  for (var offset = 0; offset < reminderHorizonDays; offset++) {
    final day = DateTime(today.year, today.month, today.day + offset);
    // One thing a day, and a day with something due has already had it.
    if (spokenFor.contains(day)) continue;
    if (offset == 0 && recordedToday) continue;
    final at = DateTime(
      day.year,
      day.month,
      day.day,
      emptyDayHour,
      emptyDayMinute,
    );
    if (!at.isAfter(now)) continue;
    plan.add(PlannedReminder(kind: ReminderKind.emptyDay, at: at));
  }

  return plan;
}

/// How many empty-day nudges went by unanswered between [since] and [now]
/// (NUDGE-5): a day whose nudge time has passed with nothing recorded in it.
///
/// [daysWithEntries] holds local dates at midnight. A day the user recorded
/// on is an answer, so the count starts again from there — it is three in a
/// row that stops the nudge, not three in all.
int countIgnoredNudges({
  required DateTime now,
  required DateTime since,
  required int hour,
  required int minute,
  required Set<DateTime> daysWithEntries,
  int ignoredSoFar = 0,
}) {
  // `since` is read back from storage as UTC (money-time#8); the calendar
  // day it names, and every nudge time built from it below, must be in
  // local time to line up with `now`, `hour`/`minute` (the device's own
  // clock, NUDGE-6) and [daysWithEntries] (local dates).
  final localSince = since.toLocal();
  var ignored = ignoredSoFar;
  var day = DateTime(localSince.year, localSince.month, localSince.day);
  final today = DateTime(now.year, now.month, now.day);
  while (!day.isAfter(today)) {
    final at = DateTime(day.year, day.month, day.day, hour, minute);
    if (at.isAfter(localSince) && !at.isAfter(now)) {
      ignored = daysWithEntries.contains(day) ? 0 : ignored + 1;
    }
    day = DateTime(day.year, day.month, day.day + 1);
  }
  return ignored;
}

/// Whether [hour] is inside the hours the app may speak in (NUDGE-6).
bool _awake(int hour) => hour >= quietUntilHour && hour < quietFromHour;

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
