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

    test('upcoming lists the next 30 days (RCR-7)', () async {
      await provider.addRecurringRule(
        testRule('Rent', 900, DateTime(2026, 9, 20)),
      );

      expect(dates(provider.upcomingOccurrences), [DateTime(2026, 9, 20)]);
      expect(provider.dueOccurrences, isEmpty);
    });

    test('occurrences due while paused are skipped (RCR-6)', () async {
      await provider.addRecurringRule(testRule('Rent', 900, DateTime(2026, 9)));
      await provider.pauseRecurringRule('Rent');
      expect(provider.dueOccurrences, isEmpty);
      expect(provider.upcomingOccurrences, isEmpty);

      now = DateTime(2026, 11, 10);
      await reload();
      await provider.resumeRecurringRule('Rent');

      expect(provider.dueOccurrences, isEmpty);
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
        testRule('Rent', 900, DateTime(2026, 9)),
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
