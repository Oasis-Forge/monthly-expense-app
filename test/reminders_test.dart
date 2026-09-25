import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/recurring_rule.dart';
import 'package:monthly_expense_app/models/reminders.dart';
import 'package:monthly_expense_app/models/transaction.dart';

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
          dueDate: DateTime(2026, 9, 23),
          amount: const Money(100000),
        ),
      ]);
    });

    test('the single named entry carries its own due date and amount '
        '(NUDGE-2, rules-23-26-34#9)', () {
      final reminders = plan(upcoming: [occurrence('Salary', 1)]);

      expect(reminders.single.dueDate, DateTime(2026, 9, 23));
      expect(reminders.single.amount, const Money(100000));
      expect(reminders.single.isIncome, isFalse);
    });

    test('an income rule is carried as income, for the sign it is shown with '
        '(CUR-5, rules-23-26-34#9)', () {
      final reminders = plan(
        upcoming: [
          ScheduledOccurrence(
            testRule(
              'Salary',
              100,
              day(1),
            ).copyWith(type: TransactionType.income),
            day(1),
          ),
        ],
      );

      expect(reminders.single.isIncome, isTrue);
    });

    test('one already waiting keeps its own, earlier due date, not the '
        'morning it is finally announced (NUDGE-2, rules-23-26-34#9)', () {
      final reminders = plan(due: [occurrence('Salary', -3)]);

      expect(reminders.single.dueDate, day(-3));
      expect(reminders.single.at, DateTime(2026, 9, 23, dueEntryHour));
    });

    test('several due the same day carry no date or amount of their own '
        '(NUDGE-2)', () {
      final reminders = plan(
        upcoming: [occurrence('Salary', 1), occurrence('Rent', 1)],
      );

      expect(reminders.single.dueDate, isNull);
      expect(reminders.single.amount, isNull);
    });

    test('two on the same day are one reminder, counted not listed', () {
      final reminders = plan(
        upcoming: [occurrence('Salary', 1), occurrence('Rent', 1)],
      );

      expect(reminders, hasLength(1));
      expect(reminders.single.count, 2);
      expect(reminders.single.title, isNull, reason: 'a count, not a list');
    });

    test('two falling due the same day are not carried over, so the group '
        'is not marked overdue (rules-23-26-34#9)', () {
      final reminders = plan(
        upcoming: [occurrence('Salary', 1), occurrence('Rent', 1)],
      );

      expect(reminders.single.anyOverdue, isFalse);
    });

    test('a group with an overdue occurrence carried in from an earlier day '
        'is marked overdue, so it does not claim they were all due today '
        '(rules-23-26-34#9)', () {
      final reminders = plan(
        due: [occurrence('Salary', -2), occurrence('Rent', -2)],
        upcoming: [occurrence('Utilities', 1)],
      );

      expect(reminders.single.count, 3);
      expect(reminders.single.anyOverdue, isTrue);
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

    test('not even on the first day past it (NUDGE-5)', () {
      final reminders = plan(
        upcoming: [occurrence('Salary', reminderHorizonDays)],
      );

      expect(reminders, isEmpty);
    });

    test('one a month out is not announced on this month\'s same date '
        '(NUDGE-2)', () {
      // The upcoming list runs thirty days ahead: 22 and 23 October share
      // their day numbers with today and tomorrow.
      final reminders = plan(
        at: DateTime(2026, 9, 22, 7),
        upcoming: [occurrence('Rent', 30), occurrence('Gym', 31)],
      );

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

    test('at the minute the user chose, not just the hour (NUDGE-4)', () {
      final reminders = plan(emptyDayOn: true, hour: 21, minute: 30);

      expect(reminders.map((r) => r.at), [
        DateTime(2026, 9, 22, 21, 30),
        DateTime(2026, 9, 23, 21, 30),
        DateTime(2026, 9, 24, 21, 30),
      ]);
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

  test('only the phones schedule reminders (NUDGE-10)', () {
    try {
      for (final platform in TargetPlatform.values) {
        debugDefaultTargetPlatformOverride = platform;
        expect(
          remindersSupported,
          platform == TargetPlatform.android || platform == TargetPlatform.iOS,
          reason: '$platform',
        );
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
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

    test('a nudge counted at the last look is not counted again (NUDGE-5)', () {
      // Opened at ten, after tonight's nudge, and again at eleven: still the
      // one nudge, or three launches in an evening would stop it.
      expect(
        countIgnoredNudges(
          now: DateTime(2026, 9, 22, 23),
          since: DateTime(2026, 9, 22, 22),
          hour: 21,
          minute: 0,
          daysWithEntries: const {},
          ignoredSoFar: 1,
        ),
        1,
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
