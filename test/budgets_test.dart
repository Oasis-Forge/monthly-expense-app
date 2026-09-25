import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/period.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  final today = DateTime(2026, 9, 15, 10);

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Budget budget(
    String id,
    Money? limit,
    DateTime from, {
    String? categoryId = 'cat-food',
  }) {
    return Budget(
      id: id,
      categoryId: categoryId,
      limit: limit,
      effectiveFrom: from,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  group('Budget model', () {
    test('round-trips through maps, with or without a limit', () {
      for (final b in [
        budget('a', const Money(300000), DateTime(2026, 9)),
        budget('b', null, DateTime(2026, 10), categoryId: null),
      ]) {
        expect(Budget.fromMap(b.toMap()).toMap(), b.toMap());
      }
    });

    test(
      'the newest version in effect before the period ends applies (BUD-5)',
      () {
        final budgets = [
          budget('a', const Money(300000), DateTime(2026, 7)),
          budget('b', const Money(400000), DateTime(2026, 9)),
          budget('c', null, DateTime(2026, 11)),
          budget(
            'o',
            const Money(1000000),
            DateTime(2026, 9),
            categoryId: null,
          ),
        ];
        Period month(int m) => Period.containing(DateTime(2026, m, 5));

        expect(limitFor(budgets, 'cat-food', month(8)), const Money(300000));
        expect(limitFor(budgets, 'cat-food', month(9)), const Money(400000));
        expect(limitFor(budgets, 'cat-food', month(10)), const Money(400000));
        expect(limitFor(budgets, 'cat-food', month(11)), isNull);
        expect(limitFor(budgets, null, month(9)), const Money(1000000));
        expect(limitFor(budgets, null, month(8)), isNull);
        expect(limitFor(budgets, 'cat-rent', month(9)), isNull);
      },
    );

    test('versions from the same period go by the one saved last, like '
        'ones merged from a backup (BAK-3)', () {
      Budget savedOn(String id, int limit, DateTime updated) => Budget(
        id: id,
        categoryId: 'cat-food',
        limit: Money(limit),
        effectiveFrom: DateTime(2026, 9),
        createdAt: DateTime.utc(2026),
        updatedAt: updated,
      );
      final september = Period.containing(DateTime(2026, 9, 5));

      expect(
        limitFor(
          [
            savedOn('later', 2000, DateTime.utc(2026, 9, 10)),
            savedOn('earlier', 1000, DateTime.utc(2026, 9, 2)),
          ],
          'cat-food',
          september,
        ),
        const Money(2000),
      );
      expect(
        limitFor(
          [
            savedOn('earlier', 1000, DateTime.utc(2026, 9, 2)),
            savedOn('later', 2000, DateTime.utc(2026, 9, 10)),
          ],
          'cat-food',
          september,
        ),
        const Money(2000),
      );
    });

    test('a deleted version never applies (BUD-5)', () {
      final september = Period.containing(DateTime(2026, 9, 5));
      final deleted = budget(
        'b',
        const Money(400000),
        DateTime(2026, 9),
      ).copyWith(deletedAt: DateTime.utc(2026, 9, 2));

      expect(
        limitFor(
          [budget('a', const Money(300000), DateTime(2026, 8)), deleted],
          'cat-food',
          september,
        ),
        const Money(300000),
      );
    });

    test('levels, remaining, and per-day allowance (BUD-3, BUD-4)', () {
      BudgetStatus status(
        int spent, {
        PeriodTiming timing = PeriodTiming.current,
      }) {
        return BudgetStatus(
          categoryId: 'cat-food',
          limit: const Money(300000),
          spent: Money(spent * 1000),
          timing: timing,
          daysLeft: 10,
        );
      }

      expect(status(100).level, BudgetLevel.ok);
      expect(status(240).level, BudgetLevel.warning);
      expect(status(300).level, BudgetLevel.over);
      expect(status(100).perDayAllowance, const Money(20000));
      expect(status(300).perDayAllowance, isNull);
      expect(status(320).remaining, const Money(-20000));
      expect(status(100, timing: PeriodTiming.past).perDayAllowance, isNull);
    });

    test('the per-day allowance rounds down, so spending it every day stays '
        'within the limit (BUD-3)', () {
      const status = BudgetStatus(
        categoryId: null,
        limit: Money(10000),
        spent: Money.zero,
        timing: PeriodTiming.current,
        daysLeft: 3,
      );

      expect(status.perDayAllowance, const Money(3333));
    });

    group('the line the summary card leads with (BAL-8)', () {
      BudgetStatus overall(
        int limit,
        int spent, {
        PeriodTiming timing = PeriodTiming.current,
        int daysLeft = 10,
      }) => BudgetStatus(
        categoryId: null,
        limit: Money(limit * 1000),
        spent: Money(spent * 1000),
        timing: timing,
        daysLeft: daysLeft,
      );

      HeroLine lineFor(
        BudgetStatus? status, {
        int spent = 0,
        int daysElapsed = 5,
        PeriodTiming timing = PeriodTiming.current,
      }) => HeroLine.of(
        overall: status,
        spent: Money(spent * 1000),
        daysElapsed: daysElapsed,
        timing: timing,
      );

      test('a budget still has room: what is left, and per day', () {
        final line = lineFor(overall(300, 100));

        expect(line.kind, HeroLineKind.leftToSpend);
        expect(line.amount, const Money(200000));
        // 200 left over ten days, today counted (BUD-3).
        expect(line.perDay, const Money(20000));
      });

      test('past the limit: how much over, and no allowance (BUD-3)', () {
        final line = lineFor(overall(300, 320));

        expect(line.kind, HeroLineKind.overBudget);
        expect(line.amount, const Money(20000));
        expect(line.perDay, isNull);
      });

      test('exactly at the limit is reached, not over by nothing', () {
        final line = lineFor(overall(300, 300));

        expect(line.kind, HeroLineKind.limitReached);
        expect(line.perDay, isNull);
      });

      test('a budget on a period that is not running (BUD-6)', () {
        final line = lineFor(
          overall(300, 100, timing: PeriodTiming.past, daysLeft: 0),
          timing: PeriodTiming.past,
        );

        expect(line.kind, HeroLineKind.spentTotal);
        expect(line.amount, const Money(100000));
        expect(line.perDay, isNull);
      });

      test('no budget, mid-period: spent so far, and per day', () {
        final line = lineFor(null, spent: 100, daysElapsed: 5);

        expect(line.kind, HeroLineKind.spentSoFar);
        expect(line.amount, const Money(100000));
        expect(line.perDay, const Money(20000));
      });

      test('no budget, and no day to divide by', () {
        final line = lineFor(
          null,
          spent: 100,
          daysElapsed: 0,
          timing: PeriodTiming.past,
        );

        expect(line.kind, HeroLineKind.spentTotal);
        expect(line.perDay, isNull);
      });

      test('no budget, on a period that is not running, whatever days are '
          'counted (BUD-6)', () {
        final line = lineFor(
          null,
          spent: 100,
          daysElapsed: 30,
          timing: PeriodTiming.past,
        );

        expect(line.kind, HeroLineKind.spentTotal);
        expect(line.perDay, isNull);
      });
    });

    group('the budgets card line (BUD-7)', () {
      BudgetStatus status(String? categoryId, int limit, int spent) =>
          BudgetStatus(
            categoryId: categoryId,
            limit: Money(limit * 1000),
            spent: Money(spent * 1000),
            timing: PeriodTiming.current,
          );

      test('no budgets, no line', () {
        expect(BudgetSummary.of(const []), isNull);
      });

      test('the overall budget speaks for the period', () {
        final summary = BudgetSummary.of([
          status(null, 1000, 500),
          status('cat-food', 100, 150),
        ])!;

        expect(summary.progress, 0.5);
        // The food budget is over, so the line says so and turns red.
        expect((summary.over, summary.level), (1, BudgetLevel.over));
        expect(summary.count, 2);
      });

      test('without one, the category budgets count together', () {
        final summary = BudgetSummary.of([
          status('cat-food', 300, 240),
          status('cat-transport', 100, 20),
        ])!;

        expect(summary.progress, closeTo(260 / 400, 1e-9));
        // Food is at 80%: a warning, and nothing over.
        expect((summary.over, summary.level), (0, BudgetLevel.warning));
      });

      test('one over and one near its limit: the line takes the worst, over '
          '(BUD-4, BUD-7)', () {
        final summary = BudgetSummary.of([
          status('cat-food', 100, 150),
          status('cat-transport', 100, 85),
        ])!;

        expect((summary.over, summary.level), (1, BudgetLevel.over));
      });

      test('all within their limits', () {
        final summary = BudgetSummary.of([status('cat-food', 300, 10)])!;

        expect((summary.over, summary.level), (0, BudgetLevel.ok));
      });

      test('a limit of nothing counts as used up, like its budget', () {
        expect(BudgetSummary.of([status('cat-food', 0, 0)])!.progress, 1);
      });
    });

    test('a period is past, current, or future relative to today', () {
      final september = Period.containing(DateTime(2026, 9, 10));

      expect(
        september.timingOn(DateTime(2026, 9, 30, 23)),
        PeriodTiming.current,
      );
      expect(september.timingOn(DateTime(2026, 10, 1)), PeriodTiming.past);
      expect(september.timingOn(DateTime(2026, 8, 31)), PeriodTiming.future);
    });

    test('budgets are saved and updated in the database', () async {
      final db = DBHelper(path: inMemoryDatabasePath);
      addTearDown(db.close);
      final food = budget('a', const Money(300000), DateTime(2026, 9));

      await db.insertBudget(food);
      await db.updateBudget(food.copyWith(limit: null));

      final saved = (await db.fetchBudgets()).single;
      expect((saved.categoryId, saved.limit), ('cat-food', null));
    });

    test('a limit changed after the app reopens replaces the one saved '
        'before it (BUD-5)', () async {
      final db = DBHelper(path: inMemoryDatabasePath);
      addTearDown(db.close);
      Future<TransactionProvider> open() async {
        final provider = TransactionProvider(db: db, clock: () => today);
        await provider.load();
        return provider;
      }

      await (await open()).setBudget('cat-food', const Money(300000));
      // Reopened, the budget is read back from the database.
      final reopened = await open();
      await reopened.setBudget('cat-food', const Money(350000));

      expect(reopened.budgetLimit('cat-food'), const Money(350000));
      expect(await db.fetchBudgets(), hasLength(1));
    });
  });

  group('provider budgets (BUD-1–BUD-6)', () {
    late FakeDB fake;
    late DateTime now;
    late TransactionProvider provider;

    Future<void> reload() async {
      provider = TransactionProvider(db: fake, clock: () => now);
      await provider.load();
    }

    setUp(() async {
      now = today;
      fake = FakeDB(
        transactions: [
          testTx('food1', expense, 100, DateTime(2026, 9, 5)),
          testTx('food2', expense, 150, DateTime(2026, 9, 12)),
          testTx(
            'rent',
            expense,
            900,
            DateTime(2026, 9, 1),
            categoryId: 'cat-rent',
          ),
          testTx('later', expense, 500, DateTime(2026, 9, 25)),
        ],
      );
      await reload();
    });

    test(
      'statuses show spent, remaining, level, and per-day allowance',
      () async {
        await provider.setBudget('cat-food', const Money(300000));
        await provider.setBudget(null, const Money(1000000));

        final statuses = provider.budgetStatuses;
        expect([for (final s in statuses) s.categoryId], [null, 'cat-food']);

        final food = statuses.last;
        expect(
          (food.spent, food.remaining, food.level),
          (const Money(250000), const Money(50000), BudgetLevel.warning),
        );
        // September 15–30 is 16 days, today included.
        expect(food.daysLeft, 16);
        expect(food.perDayAllowance, const Money(3125));

        final overall = statuses.first;
        expect(
          (overall.spent, overall.level, overall.perDayAllowance),
          (const Money(1150000), BudgetLevel.over, null),
        );
        expect(BudgetSummary.of(statuses)!.over, 1);
      },
    );

    test('an archived category\'s budget stops counting from the current '
        'period on; past periods still report it (BUD-5, BUD-6, CAT-4, '
        'rules-6-10#9)', () async {
      now = DateTime(2026, 8, 20);
      await reload();
      await provider.setBudget('cat-food', const Money(50000));
      now = today;
      await reload();

      await provider.archiveCategory('cat-food');
      expect(
        provider.categoriesFor(expense).map((c) => c.id),
        isNot(contains('cat-food')),
      );

      // Current: the budget no longer counts, and with no other budget the
      // card has nothing to show.
      expect(
        provider.budgetStatuses.map((s) => s.categoryId),
        isNot(contains('cat-food')),
      );
      expect(BudgetSummary.of(provider.budgetStatuses), isNull);

      provider.nextPeriod();
      expect(
        provider.budgetStatuses.map((s) => s.categoryId),
        isNot(contains('cat-food')),
      );

      // August is over: it still shows the result it had (BUD-6).
      provider
        ..previousPeriod()
        ..previousPeriod();
      expect(provider.budgetStatuses.single.categoryId, 'cat-food');

      // Unarchiving brings it back as it was (CAT-4).
      await provider.unarchiveCategory('cat-food');
      provider.nextPeriod();
      expect(provider.budgetStatuses.single.categoryId, 'cat-food');
    });

    test('the overall offer starts from the period before the current one, '
        'whichever is selected (BUD-11, rules-6-10#8)', () async {
      fake.rows.addAll([
        testTx('aug', expense, 80, DateTime(2026, 8, 10)),
        testTx('aug-in', TransactionType.income, 999, DateTime(2026, 8, 11)),
        testTx('jul', expense, 40, DateTime(2026, 7, 10)),
      ]);
      await reload();
      expect(provider.lastPeriodExpense, const Money(80000));

      provider.previousPeriod();
      expect(provider.lastPeriodExpense, const Money(80000));
    });

    test('after the start day moves, a change or removal still takes effect '
        'at once (BUD-5, PER-2, rules-6-10#5)', () async {
      // Set on the 1st-to-1st calendar: this version starts on 1 Sep.
      await provider.setBudget('cat-food', const Money(300000));
      await provider.setBudget(null, const Money(1000000));

      // Now the period runs 25 Aug – 24 Sep, starting before that version.
      provider.setStartDay(25);
      expect(provider.budgetLimit('cat-food'), const Money(300000));

      await provider.setBudget('cat-food', const Money(400000));
      expect(provider.budgetLimit('cat-food'), const Money(400000));
      provider.nextPeriod();
      expect(provider.budgetLimit('cat-food'), const Money(400000));
      provider.previousPeriod();

      await provider.setBudget(null, null);
      expect(provider.budgetLimit(null), isNull);
      provider.nextPeriod();
      expect(provider.budgetLimit(null), isNull);

      // The period before keeps what it had: nothing was set before 1 Sep.
      provider
        ..previousPeriod()
        ..previousPeriod();
      expect(provider.budgetLimit('cat-food'), isNull);

      await reload();
      provider.setStartDay(25);
      expect(provider.budgetLimit('cat-food'), const Money(400000));
      expect(provider.budgetLimit(null), isNull);
    });

    test(
      'a change applies from the current period on (BUD-5, BUD-6)',
      () async {
        now = DateTime(2026, 8, 20);
        await reload();
        await provider.setBudget('cat-food', const Money(200000));

        now = today;
        await reload();
        // August's limit carries into September until it changes.
        expect(provider.budgetLimit('cat-food'), const Money(200000));
        await provider.setBudget('cat-food', const Money(300000));
        await provider.setBudget('cat-food', const Money(350000));
        expect(fake.budgets, hasLength(2));

        provider.previousPeriod();
        expect(provider.budgetLimit('cat-food'), const Money(200000));
        expect(provider.budgetStatuses.single.timing, PeriodTiming.past);

        provider
          ..nextPeriod()
          ..nextPeriod();
        expect(provider.budgetLimit('cat-food'), const Money(350000));
        expect(provider.budgetStatuses.single.timing, PeriodTiming.future);

        await provider.setBudget('cat-food', null);
        expect(
          provider.budgetLimit('cat-food', provider.currentPeriod),
          isNull,
        );
        provider
          ..previousPeriod()
          ..previousPeriod();
        expect(provider.budgetLimit('cat-food'), const Money(200000));
      },
    );

    test('removing a budget that was never set saves nothing', () async {
      await provider.setBudget('cat-food', null);

      expect(fake.budgets, isEmpty);
    });

    test('a failed save leaves budgets unchanged', () async {
      fake.failWrites = true;

      await expectLater(
        provider.setBudget('cat-food', const Money(1000)),
        throwsStateError,
      );
      expect(provider.budgetLimit('cat-food'), isNull);
    });
  });
}
