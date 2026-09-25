import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/l10n/labels.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/recurring_rule.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 9, 15, 10);

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('RecurringRule (RCR-1, RCR-3)', () {
    RecurringRule rule(
      DateTime start, {
      RecurrenceFrequency frequency = RecurrenceFrequency.month,
      int interval = 1,
      RecurrenceEnd end = RecurrenceEnd.never,
      int? count,
      DateTime? until,
      DateTime? activeFrom,
    }) {
      return testRule('r', 10, start).copyWith(
        frequency: frequency,
        interval: interval,
        endType: end,
        endCount: count,
        endDate: until,
        activeFrom: activeFrom,
      );
    }

    List<DateTime> dates(RecurringRule rule, DateTime from, DateTime to) =>
        rule.occurrencesBetween(from, to);

    test('a monthly rule on the 31st uses the last day of short months', () {
      expect(
        dates(
          rule(DateTime(2026, 1, 31)),
          DateTime(2026),
          DateTime(2026, 4, 30),
        ),
        [
          DateTime(2026, 1, 31),
          DateTime(2026, 2, 28),
          DateTime(2026, 3, 31),
          DateTime(2026, 4, 30),
        ],
      );
    });

    test('intervals work for days, weeks, and years', () {
      final everyThreeDays = rule(
        DateTime(2026, 9, 1),
        frequency: RecurrenceFrequency.day,
        interval: 3,
      );
      expect(
        dates(everyThreeDays, DateTime(2026, 9, 1), DateTime(2026, 9, 10)),
        [
          DateTime(2026, 9, 1),
          DateTime(2026, 9, 4),
          DateTime(2026, 9, 7),
          DateTime(2026, 9, 10),
        ],
      );

      final fortnightly = rule(
        DateTime(2026, 9, 1),
        frequency: RecurrenceFrequency.week,
        interval: 2,
      );
      expect(dates(fortnightly, DateTime(2026, 9, 5), DateTime(2026, 10)), [
        DateTime(2026, 9, 15),
        DateTime(2026, 9, 29),
      ]);

      final leapDay = rule(
        DateTime(2024, 2, 29),
        frequency: RecurrenceFrequency.year,
      );
      expect(dates(leapDay, DateTime(2024), DateTime(2028, 12, 31)), [
        DateTime(2024, 2, 29),
        DateTime(2025, 2, 28),
        DateTime(2026, 2, 28),
        DateTime(2027, 2, 28),
        DateTime(2028, 2, 29),
      ]);
    });

    test('a huge interval or count ends the schedule instead of throwing '
        '(RCR-1, RCR-4, audit money-time#7)', () {
      final hugeYearly = rule(
        DateTime(2026, 9, 1),
        frequency: RecurrenceFrequency.year,
        interval: 300000,
      );
      expect(
        () => dates(hugeYearly, DateTime(2026, 9, 1), DateTime(2026, 9, 30)),
        returnsNormally,
      );
      expect(dates(hugeYearly, DateTime(2026, 9, 1), DateTime(2026, 9, 30)), [
        DateTime(2026, 9, 1),
      ]);

      final hugeCount = rule(
        DateTime(2026, 9, 1),
        frequency: RecurrenceFrequency.year,
        interval: 1,
        end: RecurrenceEnd.afterCount,
        count: 999999999,
      );
      expect(() => hugeCount.isActiveOn(DateTime(2026, 9, 1)), returnsNormally);
    });

    test('a rule ends after a number of times or on a date', () {
      final threeTimes = rule(
        DateTime(2026, 1, 5),
        end: RecurrenceEnd.afterCount,
        count: 3,
      );
      expect(dates(threeTimes, DateTime(2026), DateTime(2026, 12, 31)), [
        DateTime(2026, 1, 5),
        DateTime(2026, 2, 5),
        DateTime(2026, 3, 5),
      ]);

      final untilMarch = rule(
        DateTime(2026, 1, 5),
        end: RecurrenceEnd.onDate,
        until: DateTime(2026, 3),
      );
      expect(dates(untilMarch, DateTime(2026), DateTime(2026, 12, 31)), [
        DateTime(2026, 1, 5),
        DateTime(2026, 2, 5),
      ]);
    });

    test('an occurrence on the end date is the last one, not dropped '
        '(RCR-1)', () {
      final untilTheFifth = rule(
        DateTime(2026, 1, 5),
        end: RecurrenceEnd.onDate,
        until: DateTime(2026, 3, 5),
      );
      expect(dates(untilTheFifth, DateTime(2026), DateTime(2026, 12, 31)), [
        DateTime(2026, 1, 5),
        DateTime(2026, 2, 5),
        DateTime(2026, 3, 5),
      ]);
    });

    test('nothing is dated before the start, even for a rule active from '
        'earlier (RCR-1)', () {
      // The provider keeps activeFrom on or after the start; a rule from
      // anywhere else must still not invent days before it.
      final daily = rule(
        DateTime(2026, 9, 10),
        frequency: RecurrenceFrequency.day,
        activeFrom: DateTime(2026, 9, 1),
      );
      expect(dates(daily, DateTime(2026, 9, 1), DateTime(2026, 9, 12)), [
        DateTime(2026, 9, 10),
        DateTime(2026, 9, 11),
        DateTime(2026, 9, 12),
      ]);

      final weekly = rule(
        DateTime(2026, 9, 10),
        frequency: RecurrenceFrequency.week,
        activeFrom: DateTime(2026, 9, 1),
      );
      expect(dates(weekly, DateTime(2026, 9, 1), DateTime(2026, 9, 30)), [
        DateTime(2026, 9, 10),
        DateTime(2026, 9, 17),
        DateTime(2026, 9, 24),
      ]);
    });

    test('a range that begins on an occurrence includes it (RCR-4)', () {
      final fortnightly = rule(
        DateTime(2026, 9, 1),
        frequency: RecurrenceFrequency.week,
        interval: 2,
      );
      expect(dates(fortnightly, DateTime(2026, 9, 15), DateTime(2026, 9, 30)), [
        DateTime(2026, 9, 15),
        DateTime(2026, 9, 29),
      ]);

      final everyThreeDays = rule(
        DateTime(2026, 9, 1),
        frequency: RecurrenceFrequency.day,
        interval: 3,
      );
      expect(
        dates(everyThreeDays, DateTime(2026, 9, 7), DateTime(2026, 9, 7)),
        [DateTime(2026, 9, 7)],
      );
    });

    test('a rule read back from its map keeps its local days (RCR-3)', () {
      // A local date written as UTC comes back as the day before east of
      // Greenwich, and the rule then falls on the 30th instead of the 31st.
      final saved = rule(
        DateTime(2026, 1, 31),
        end: RecurrenceEnd.onDate,
        until: DateTime(2026, 4, 30),
        activeFrom: DateTime(2026, 1, 31),
      );
      final loaded = RecurringRule.fromMap(saved.toMap());

      expect(loaded.startDate, DateTime(2026, 1, 31));
      expect(loaded.endDate, DateTime(2026, 4, 30));
      expect(loaded.activeFrom, DateTime(2026, 1, 31));
      expect(dates(loaded, DateTime(2026), DateTime(2026, 12, 31)), [
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 31),
        DateTime(2026, 4, 30),
      ]);
    });

    test('occurrences before activeFrom are left out (RCR-5)', () {
      final edited = rule(DateTime(2026, 1, 5), activeFrom: DateTime(2026, 3));
      expect(dates(edited, DateTime(2026), DateTime(2026, 4, 30)), [
        DateTime(2026, 3, 5),
        DateTime(2026, 4, 5),
      ]);
    });

    test('rules and occurrences round-trip through maps', () {
      final full = rule(
        DateTime(2026, 1, 5),
        end: RecurrenceEnd.onDate,
        until: DateTime(2026, 12, 31),
      ).copyWith(note: 'flat', autoPost: true, pausedAt: DateTime.utc(2026, 9));
      expect(RecurringRule.fromMap(full.toMap()).toMap(), full.toMap());

      final occurrence = RecurringOccurrence(
        ruleId: 'r',
        date: DateTime(2026, 9, 5),
        status: OccurrenceStatus.posted,
        transactionId: 't',
        createdAt: DateTime.utc(2026, 9, 5),
      );
      expect(
        RecurringOccurrence.fromMap(occurrence.toMap()).toMap(),
        occurrence.toMap(),
      );
      expect(occurrence.key, occurrenceKey('r', DateTime(2026, 9, 5, 18)));
    });
  });

  test('the database posts an occurrence once, with its transaction', () async {
    final db = DBHelper(path: inMemoryDatabasePath);
    addTearDown(db.close);
    final record = RecurringOccurrence(
      ruleId: 'r',
      date: DateTime(2026, 9, 5),
      status: OccurrenceStatus.posted,
      transactionId: 't1',
      createdAt: DateTime.utc(2026, 9, 5),
    );
    await db.insertRecurringRule(testRule('r', 900, DateTime(2026, 9)));
    await db.postOccurrence(
      testTx('t1', TransactionType.expense, 900, DateTime(2026, 9, 5)),
      record,
    );

    await expectLater(
      db.postOccurrence(
        testTx('t2', TransactionType.expense, 900, DateTime(2026, 9, 5)),
        record,
      ),
      throwsA(isA<DatabaseException>()),
    );
    await db.insertOccurrence(record);

    expect([for (final t in await db.fetchTransactions()) t.id], ['t1']);
    expect(await db.fetchOccurrences(), hasLength(1));
    expect((await db.fetchRecurringRules()).single.id, 'r');
  });

  group('provider recurring (RCR-1–RCR-7)', () {
    late FakeDB fake;
    late DateTime now;
    late TransactionProvider provider;

    Future<void> reload() async {
      provider = TransactionProvider(db: fake, clock: () => now);
      await provider.load();
    }

    List<DateTime> dates(List<ScheduledOccurrence> occurrences) => [
      for (final o in occurrences) o.date,
    ];

    setUp(() async {
      now = today;
      fake = FakeDB();
      await reload();
    });

    test(
      'automatic rules post each due occurrence once, across reloads',
      () async {
        fake.rules.add(
          testRule('Rent', 900, DateTime(2026, 7), autoPost: true),
        );
        await reload();

        expect(
          [for (final t in provider.transactions) t.date],
          [DateTime(2026, 9), DateTime(2026, 8), DateTime(2026, 7)],
        );

        await reload();
        expect(provider.transactions, hasLength(3));
        expect(fake.occurrences, hasLength(3));

        now = DateTime(2026, 10, 2);
        await reload();
        expect(provider.transactions, hasLength(4));
      },
    );

    test('other rules wait in Due until posted or skipped (RCR-2)', () async {
      await provider.addRecurringRule(testRule('Rent', 900, DateTime(2026, 8)));
      expect(dates(provider.dueOccurrences), [
        DateTime(2026, 8),
        DateTime(2026, 9),
      ]);
      expect(provider.transactions, isEmpty);

      await provider.postOccurrence(
        provider.dueOccurrences.first,
        amount: const Money(950000),
      );
      await provider.skipOccurrence(provider.dueOccurrences.single);

      expect(provider.dueOccurrences, isEmpty);
      final posted = provider.transactions.single;
      expect(
        (posted.date, posted.amount, posted.title, posted.categoryId),
        (DateTime(2026, 8), const Money(950000), 'Rent', 'cat-rent'),
      );

      await reload();
      expect(provider.dueOccurrences, isEmpty);
    });

    test(
      'upcoming does not repeat what is already due today (RCR-2, RCR-7)',
      () async {
        await provider.addRecurringRule(
          testRule('Rent', 900, DateTime(2026, 9, 15)),
        );

        expect(dates(provider.dueOccurrences), [DateTime(2026, 9, 15)]);
        expect(dates(provider.upcomingOccurrences), [DateTime(2026, 10, 15)]);
      },
    );

    test('upcoming lists the next 30 days (RCR-7)', () async {
      await provider.addRecurringRule(
        testRule('Rent', 900, DateTime(2026, 9, 20)),
      );

      expect(dates(provider.upcomingOccurrences), [DateTime(2026, 9, 20)]);
      expect(provider.dueOccurrences, isEmpty);
    });

    test('occurrences due while paused are skipped, but one already waiting '
        'before the pause is not (RCR-6, audit rules-6-10#4)', () async {
      await provider.addRecurringRule(testRule('Rent', 900, DateTime(2026, 9)));
      await provider.pauseRecurringRule('Rent');
      expect(provider.dueOccurrences, isEmpty);
      expect(provider.upcomingOccurrences, isEmpty);

      now = DateTime(2026, 11, 10);
      await reload();
      await provider.resumeRecurringRule('Rent');

      // Sep 1 was already due before the pause started (on Sep 15) and
      // was never handled, so it stays due; Oct 1 and Nov 1 fell due
      // while paused and are skipped, not caught up.
      expect(dates(provider.dueOccurrences), [DateTime(2026, 9)]);
      expect(dates(provider.upcomingOccurrences), [DateTime(2026, 12)]);
    });

    test(
      'edits apply from today; deleting keeps posted ones (RCR-5)',
      () async {
        fake.rules.add(
          testRule('Rent', 900, DateTime(2026, 8), autoPost: true),
        );
        await reload();
        expect(provider.transactions, hasLength(2));

        await provider.updateRecurringRule(
          provider.recurringRules.single.copyWith(amount: const Money(1000000)),
        );
        expect(
          {for (final t in provider.transactions) t.amount},
          {const Money(900000)},
        );

        now = DateTime(2026, 10, 1);
        await reload();
        expect(provider.transactions.first.amount, const Money(1000000));

        await provider.deleteRecurringRule('Rent');
        expect(provider.recurringRules, isEmpty);
        expect(provider.transactions, hasLength(3));

        now = DateTime(2026, 11, 1);
        await reload();
        expect(provider.transactions, hasLength(3));
      },
    );

    test('a due-before-today occurrence survives an unrelated edit '
        '(RCR-5, audit rules-6-10#4)', () async {
      await provider.addRecurringRule(testRule('Rent', 900, DateTime(2026, 9)));
      expect(dates(provider.dueOccurrences), [DateTime(2026, 9)]);

      await provider.updateRecurringRule(
        provider.recurringRules.single.copyWith(amount: const Money(1000000)),
      );

      expect(dates(provider.dueOccurrences), [DateTime(2026, 9)]);
      expect(provider.transactions, isEmpty);
    });

    test('every item waiting in Due survives an edit that leaves the '
        'schedule alone (RCR-5, review-state-1)', () async {
      await provider.addRecurringRule(testRule('Rent', 900, DateTime(2026, 8)));
      expect(dates(provider.dueOccurrences), [
        DateTime(2026, 8),
        DateTime(2026, 9),
      ]);

      await provider.updateRecurringRule(
        provider.recurringRules.single.copyWith(
          title: 'Flat',
          categoryId: 'cat-food',
          autoPost: false,
        ),
      );

      expect(dates(provider.dueOccurrences), [
        DateTime(2026, 8),
        DateTime(2026, 9),
      ]);
      expect(provider.dueOccurrences.first.rule.title, 'Flat');
    });

    group('a schedule edit never reaches back before today '
        '(RCR-5, review-state-1)', () {
      test('monthly to weekly on an automatic rule posts nothing '
          'back-dated', () async {
        fake.rules.add(testRule('Gym', 30, DateTime(2026), autoPost: true));
        await reload();
        expect(provider.transactions, hasLength(9)); // 1 Jan .. 1 Sep

        await provider.updateRecurringRule(
          provider.recurringRules.single.copyWith(
            frequency: RecurrenceFrequency.week,
          ),
        );

        expect(provider.transactions, hasLength(9));
        expect(provider.dueOccurrences, isEmpty);
        // The weekly dates go on from today: 1 Jan 2026 is a Thursday.
        expect(
          dates(provider.upcomingOccurrences).first,
          DateTime(2026, 9, 17),
        );

        await reload();
        expect(provider.transactions, hasLength(9));
      });

      test('extending an ended rule does not queue the gap', () async {
        fake.rules.add(
          testRule(
            'Rent',
            900,
            DateTime(2026),
          ).copyWith(endType: RecurrenceEnd.afterCount, endCount: 3),
        );
        await reload();
        for (final o in List.of(provider.dueOccurrences)) {
          await provider.postOccurrence(o);
        }
        expect(provider.dueOccurrences, isEmpty);

        await provider.updateRecurringRule(
          provider.recurringRules.single.copyWith(
            endType: RecurrenceEnd.never,
            endCount: null,
          ),
        );

        expect(provider.dueOccurrences, isEmpty);
        expect(dates(provider.upcomingOccurrences), [DateTime(2026, 10)]);
        expect(provider.transactions, hasLength(3));
      });

      test('extending an ended automatic rule posts nothing in '
          'between', () async {
        fake.rules.add(
          testRule('Gym', 30, DateTime(2026), autoPost: true).copyWith(
            endType: RecurrenceEnd.onDate,
            endDate: DateTime(2026, 3, 31),
          ),
        );
        await reload();
        expect(provider.transactions, hasLength(3)); // Jan, Feb, Mar

        await provider.updateRecurringRule(
          provider.recurringRules.single.copyWith(
            endDate: DateTime(2026, 12, 31),
          ),
        );

        expect(provider.transactions, hasLength(3));
        expect(dates(provider.upcomingOccurrences), [DateTime(2026, 10)]);
      });

      test('a start moved later but still in the past posts nothing '
          'back-dated', () async {
        fake.rules.add(testRule('Gym', 30, DateTime(2026), autoPost: true));
        await reload();
        expect(provider.transactions, hasLength(9));

        await provider.updateRecurringRule(
          provider.recurringRules.single.copyWith(
            startDate: DateTime(2026, 3, 15),
          ),
        );

        // 15 Sep is today and falls on the new schedule, so it posts; the
        // six months before it do not.
        expect(
          [
            for (final t in provider.transactions)
              if (t.date.isAfter(DateTime(2026, 9))) t.date,
          ],
          [DateTime(2026, 9, 15)],
        );
        expect(provider.transactions, hasLength(10));
      });

      test('an item waiting in Due stays when it is on the new schedule; '
          'the new dates before today are skipped, not queued', () async {
        await provider.addRecurringRule(
          testRule('Rent', 900, DateTime(2026, 8)),
        );
        expect(dates(provider.dueOccurrences), [
          DateTime(2026, 8),
          DateTime(2026, 9),
        ]);

        // Weekly from 1 Aug keeps 1 Aug (a Saturday) on the schedule, but
        // not 1 Sep (a Tuesday).
        await provider.updateRecurringRule(
          provider.recurringRules.single.copyWith(
            frequency: RecurrenceFrequency.week,
          ),
        );

        expect(dates(provider.dueOccurrences), [DateTime(2026, 8)]);
        expect(
          dates(provider.upcomingOccurrences).first,
          DateTime(2026, 9, 19),
        );

        await reload();
        expect(dates(provider.dueOccurrences), [DateTime(2026, 8)]);
        expect(provider.transactions, isEmpty);
      });
    });

    test('a failed post changes nothing', () async {
      await provider.addRecurringRule(testRule('Rent', 900, DateTime(2026, 9)));
      fake.failWrites = true;

      await expectLater(
        provider.postOccurrence(provider.dueOccurrences.single),
        throwsStateError,
      );
      expect(provider.transactions, isEmpty);
      expect(provider.dueOccurrences, hasLength(1));
    });
  });

  group('what the rules come to (RCR-8)', () {
    Money monthly(RecurrenceFrequency frequency, int interval, num amount) =>
        testRule(
          'r',
          amount,
          DateTime(2026, 9),
        ).copyWith(frequency: frequency, interval: interval).monthlyCost;

    Future<TransactionProvider> loaded(List<RecurringRule> rules) async {
      final provider = TransactionProvider(
        db: FakeDB(rules: rules),
        clock: () => today,
      );
      await provider.load();
      return provider;
    }

    test('a rule is worked out per month, whatever it repeats on', () {
      expect(monthly(RecurrenceFrequency.month, 1, 900), const Money(900000));
      expect(monthly(RecurrenceFrequency.month, 2, 900), const Money(450000));
      expect(monthly(RecurrenceFrequency.week, 1, 10), const Money(43333));
      expect(monthly(RecurrenceFrequency.year, 1, 120), const Money(10000));
      expect(monthly(RecurrenceFrequency.day, 1, 1), const Money(30417));
    });

    test('every interval divides, whatever the rule repeats on (RCR-8)', () {
      // 10 every second week: 26 a year, 21.67 a month.
      expect(monthly(RecurrenceFrequency.week, 2, 10), const Money(21667));
      // 1 every second day: 182.5 a year, 15.21 a month.
      expect(monthly(RecurrenceFrequency.day, 2, 1), const Money(15208));
      // 120 every second year: 5 a month.
      expect(monthly(RecurrenceFrequency.year, 2, 120), const Money(5000));
    });

    test('a rule whose end is today still counts today (RCR-8)', () {
      final endsToday = testRule(
        'r',
        10,
        DateTime(2026, 9),
      ).copyWith(endType: RecurrenceEnd.onDate, endDate: DateTime(2026, 9, 15));
      expect(endsToday.isActiveOn(DateTime(2026, 9, 15)), isTrue);
      expect(endsToday.isActiveOn(DateTime(2026, 9, 16)), isFalse);

      // July, August, September: the last of them falls today.
      final lastToday = testRule(
        'r',
        10,
        DateTime(2026, 7, 15),
      ).copyWith(endType: RecurrenceEnd.afterCount, endCount: 3);
      expect(lastToday.isActiveOn(DateTime(2026, 9, 15)), isTrue);
      expect(lastToday.isActiveOn(DateTime(2026, 9, 16)), isFalse);
    });

    test('income, paused and finished rules stay out of the total', () async {
      final provider = await loaded([
        testRule('rent', 900, DateTime(2026, 9)),
        testRule(
          'salary',
          2000,
          DateTime(2026, 9),
        ).copyWith(type: TransactionType.income),
        testRule('gym', 30, DateTime(2026, 9)).copyWith(pausedAt: today),
        testRule(
          'old',
          50,
          DateTime(2026),
        ).copyWith(endType: RecurrenceEnd.onDate, endDate: DateTime(2026, 6)),
      ]);

      expect(provider.monthlyBills, const Money(900000));
    });

    test('what falls next is the first still waiting, in days', () async {
      final provider = await loaded([
        // Nothing overdue, or the line says nothing at all (RCR-8).
        testRule('Rent', 900, DateTime(2026, 10)),
        testRule('Gym', 30, DateTime(2026, 9, 20)),
      ]);

      final next = provider.nextScheduled!;
      expect(next.rule.id, 'Gym');
      expect(provider.daysUntil(next.date), 5);
    });

    test('one due today comes before the days ahead', () async {
      final provider = await loaded([
        testRule('Water', 20, DateTime(2026, 9, 15)),
        testRule('Gym', 30, DateTime(2026, 9, 20)),
      ]);

      expect(provider.nextScheduled!.rule.id, 'Water');
      expect(provider.daysUntil(provider.nextScheduled!.date), 0);
    });

    test('nothing is named next while something is overdue (RCR-8)', () async {
      // "Next: Gym, in 5 days" printed above a rent payment that has been
      // waiting since the first of the month is a contradiction: the screen
      // would say nothing is coming for five days and list something already
      // waiting directly underneath.
      final provider = await loaded([
        testRule('Rent', 900, DateTime(2026, 9)),
        testRule('Gym', 30, DateTime(2026, 9, 20)),
      ]);

      expect(provider.dueOccurrences, isNotEmpty);
      expect(provider.nextScheduled, isNull);
    });

    test('with no rules there is no total and nothing next', () async {
      final provider = await loaded([]);

      expect(provider.monthlyBills, Money.zero);
      expect(provider.nextScheduled, isNull);
    });

    test('a rule counts until its last occurrence has gone by', () async {
      final provider = await loaded([
        // June, July, August: the third and last is behind us.
        testRule(
          'instalments',
          100,
          DateTime(2026, 6),
        ).copyWith(endType: RecurrenceEnd.afterCount, endCount: 3),
        // August, September, October: one still to come.
        testRule(
          'course',
          60,
          DateTime(2026, 8),
        ).copyWith(endType: RecurrenceEnd.afterCount, endCount: 3),
      ]);

      expect(provider.monthlyBills, const Money(60000));
    });
  });

  group('how a schedule reads (RCR-1, LANG-7)', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    String label(RecurrenceFrequency frequency, int interval) => scheduleLabel(
      testRule(
        'r',
        10,
        DateTime(2026, 9),
      ).copyWith(frequency: frequency, interval: interval),
      l10n,
    );

    test('an interval of one has a wording of its own', () {
      expect(label(RecurrenceFrequency.day, 1), 'Every day');
      expect(label(RecurrenceFrequency.week, 1), 'Every week');
      expect(label(RecurrenceFrequency.month, 1), 'Every month');
      expect(label(RecurrenceFrequency.year, 1), 'Every year');
    });

    test(
      'every other interval counts, including the ones Russian tripped on',
      () {
        expect(label(RecurrenceFrequency.day, 21), 'Every 21 days');
        expect(label(RecurrenceFrequency.week, 2), 'Every 2 weeks');
        expect(label(RecurrenceFrequency.month, 3), 'Every 3 months');
        expect(label(RecurrenceFrequency.year, 31), 'Every 31 years');
      },
    );

    test('a paused rule says so, whichever wording it took', () {
      final paused = testRule(
        'r',
        10,
        DateTime(2026, 9),
      ).copyWith(pausedAt: today);

      expect(scheduleLabel(paused, l10n), 'Every month · Paused');
    });
  });
}
