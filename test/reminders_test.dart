import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/recurring_rule.dart';
import 'package:monthly_expense_app/models/reminders.dart';

import 'helpers.dart';

void main() {
  // A Tuesday, mid-morning, after the hour a due entry is announced at.
  final now = DateTime(2026, 9, 22, 10, 30);
  final today = DateTime(2026, 9, 22);
  DateTime day(int offset) => DateTime(2026, 9, 22 + offset);

  ScheduledOccurrence occurrence(String id, int offset) =>
      ScheduledOccurrence(testRule(id, 100, day(offset)), day(offset));

  List<PlannedReminder> plan({
    DateTime? at,
    List<ScheduledOccurrence> due = const [],
    List<ScheduledOccurrence> upcoming = const [],
    bool emptyDayOn = false,
    int hour = 21,
    int minute = 0,
    bool recordedToday = false,
  }) => planReminders(
    now: at ?? now,
    due: due,
    upcoming: upcoming,
    emptyDayOn: emptyDayOn,
    emptyDayHour: hour,
    emptyDayMinute: minute,
    recordedToday: recordedToday,
  );

  group('the entry that was due (NUDGE-2)', () {
    test('nothing is said when nothing is waiting', () {
      expect(plan(), isEmpty);
    });

    test('one falling due tomorrow is named, on the morning it falls', () {
      final reminders = plan(upcoming: [occurrence('Salary', 1)]);

      expect(reminders, [
        PlannedReminder(
          kind: ReminderKind.dueEntry,
          at: DateTime(2026, 9, 23, dueEntryHour),
          title: 'Salary',
        ),
      ]);
    });

    test('two on the same day are one reminder, counted not listed', () {
      final reminders = plan(
        upcoming: [occurrence('Salary', 1), occurrence('Rent', 1)],
      );

      expect(reminders, hasLength(1));
      expect(reminders.single.count, 2);
      expect(reminders.single.title, isNull, reason: 'a count, not a list');
    });

    test('one already waiting is announced tomorrow morning, since this '
        'morning has gone', () {
      final reminders = plan(due: [occurrence('Salary', -3)]);

      expect(reminders.single.at, DateTime(2026, 9, 23, dueEntryHour));
    });

    test('and this morning when it has not', () {
      final reminders = plan(
        at: DateTime(2026, 9, 22, 7),
        due: [occurrence('Salary', -3)],
      );

      expect(reminders.single.at, DateTime(2026, 9, 22, dueEntryHour));
    });

    test('it is announced once, not on every day of the horizon', () {
      final reminders = plan(due: [occurrence('Salary', -3)]);

      expect(reminders, hasLength(1));
    });

    test('what is waiting joins what falls due that morning', () {
      final reminders = plan(
        due: [occurrence('Salary', -3)],
        upcoming: [occurrence('Rent', 1)],
      );

      expect(reminders.single.count, 2);
    });

    test('nothing beyond the horizon', () {
      final reminders = plan(upcoming: [occurrence('Salary', 5)]);

      expect(reminders, isEmpty);
    });
  });

  group('the day with nothing in it (NUDGE-4)', () {
    test('it says nothing until it is turned on', () {
      expect(plan(), isEmpty);
    });

    test('tonight, and the two nights after it', () {
      final reminders = plan(emptyDayOn: true);

      expect(reminders.map((r) => r.at), [
        DateTime(2026, 9, 22, 21),
        DateTime(2026, 9, 23, 21),
        DateTime(2026, 9, 24, 21),
      ]);
      expect(reminders.every((r) => r.kind == ReminderKind.emptyDay), isTrue);
    });

    test('a day already recorded on is not told it is empty', () {
      final reminders = plan(emptyDayOn: true, recordedToday: true);

      expect(reminders.first.at, DateTime(2026, 9, 23, 21));
      expect(reminders, hasLength(2));
    });

    test('a time that has gone by tonight waits for tomorrow', () {
      final reminders = plan(
        at: DateTime(2026, 9, 22, 22, 30),
        emptyDayOn: true,
        hour: 21,
      );

      expect(reminders.first.at, DateTime(2026, 9, 23, 21));
    });

    test('three at a time, so an app never opened again falls silent '
        '(NUDGE-5)', () {
      expect(plan(emptyDayOn: true), hasLength(reminderHorizonDays));
    });
  });

  group('one thing a day, and not at night (NUDGE-6)', () {
    test('a day with something due is not also told it is empty', () {
      final reminders = plan(
        upcoming: [occurrence('Salary', 1)],
        emptyDayOn: true,
      );

      final onTheDay = reminders.where((r) => r.at.day == 23);
      expect(onTheDay, hasLength(1));
      expect(onTheDay.single.kind, ReminderKind.dueEntry);
    });

    test('but the other nights still get theirs', () {
      final reminders = plan(
        upcoming: [occurrence('Salary', 1)],
        emptyDayOn: true,
      );

      expect(reminders.map((r) => r.at), [
        DateTime(2026, 9, 23, dueEntryHour),
        DateTime(2026, 9, 22, 21),
        DateTime(2026, 9, 24, 21),
      ]);
    });

    test('nothing is scheduled for ten at night', () {
      expect(plan(emptyDayOn: true, hour: quietFromHour), isEmpty);
    });

    test('nor for seven in the morning', () {
      expect(plan(emptyDayOn: true, hour: 7), isEmpty);
    });

    test('eight is the earliest it may speak', () {
      expect(plan(emptyDayOn: true, hour: quietUntilHour), isNotEmpty);
    });
  });

  group('three ignored in a row and it stops (NUDGE-5)', () {
    int ignored({
      required DateTime since,
      required DateTime at,
      Set<DateTime> recorded = const {},
    }) => countIgnoredNudges(
      now: at,
      since: since,
      hour: 21,
      minute: 0,
      daysWithEntries: recorded,
    );

    test('a nudge that has not fired yet counts for nothing', () {
      expect(
        ignored(since: DateTime(2026, 9, 22, 8), at: DateTime(2026, 9, 22, 20)),
        0,
      );
    });

    test('one that has, with nothing recorded, counts', () {
      expect(
        ignored(since: DateTime(2026, 9, 22, 8), at: DateTime(2026, 9, 22, 22)),
        1,
      );
    });

    test('three days away from the app is three', () {
      expect(
        ignored(since: DateTime(2026, 9, 22, 8), at: DateTime(2026, 9, 24, 22)),
        3,
      );
    });

    test('a day recorded on starts the count again', () {
      expect(
        ignored(
          since: DateTime(2026, 9, 22, 8),
          at: DateTime(2026, 9, 24, 22),
          recorded: {today.add(const Duration(days: 1))},
        ),
        1,
      );
    });

    test('recording on the last of them clears it', () {
      expect(
        ignored(
          since: DateTime(2026, 9, 22, 8),
          at: DateTime(2026, 9, 24, 22),
          recorded: {DateTime(2026, 9, 24)},
        ),
        0,
      );
    });

    test('a count already running carries across the days away', () {
      expect(
        countIgnoredNudges(
          now: DateTime(2026, 9, 23, 22),
          since: DateTime(2026, 9, 23, 8),
          hour: 21,
          minute: 0,
          daysWithEntries: const {},
          ignoredSoFar: 2,
        ),
        3,
        reason: 'two before, one more tonight',
      );
    });

    test('and an entry on the day clears what was carried', () {
      expect(
        countIgnoredNudges(
          now: DateTime(2026, 9, 23, 22),
          since: DateTime(2026, 9, 23, 8),
          hour: 21,
          minute: 0,
          daysWithEntries: {DateTime(2026, 9, 23)},
          ignoredSoFar: 2,
        ),
        0,
      );
    });
  });
}
