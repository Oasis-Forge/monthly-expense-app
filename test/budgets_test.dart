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
        expect(provider.budgetsOver, 1);
      },
    );

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
