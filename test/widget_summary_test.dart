import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  const income = TransactionType.income;
  final today = DateTime(2026, 9, 15, 10);

  Budget overall(Money? limit, DateTime from) => Budget(
    id: 'b-${from.month}',
    categoryId: null,
    limit: limit,
    effectiveFrom: from,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  Future<TransactionProvider> loaded({
    List<ExpenseTransaction> transactions = const [],
    List<Budget> budgets = const [],
    int startDay = 1,
  }) async {
    final provider = TransactionProvider(
      db: FakeDB(transactions: transactions, budgets: budgets),
      clock: () => today,
      startDay: startDay,
    );
    await provider.load();
    return provider;
  }

  group('the widget timeline (WID-1, WID-2)', () {
    test('the first entry is the current period as of today', () async {
      final provider = await loaded(
        transactions: [
          testTx('a', expense, 30, DateTime(2026, 9, 3)),
          testTx('b', income, 200, DateTime(2026, 9, 1)),
          // Another period, so it must not count.
          testTx('c', expense, 500, DateTime(2026, 8, 20)),
        ],
      );

      final now = provider.widgetTimeline().first;
      expect(now.period.start, DateTime(2026, 9));
      expect(now.income, const Money(200000));
      expect(now.expense, const Money(30000));
      // Carried forward -500 from August, plus this period's +170 (BAL-3).
      expect(now.balance, const Money(-330000));
      expect(now.balanceIsNet, isFalse);
      expect(now.budgetLeft, isNull);
    });

    test('carry-forward off makes the balance the period net', () async {
      final provider = await loaded(
        transactions: [
          testTx('a', expense, 30, DateTime(2026, 9, 3)),
          testTx('c', expense, 500, DateTime(2026, 8, 20)),
        ],
      );

      final entry = provider.widgetTimeline(carryForward: false).first;
      expect(entry.balance, const Money(-30000));
      expect(entry.balanceIsNet, isTrue);
    });

    test('an overall budget gives what is left, and goes negative', () async {
      final provider = await loaded(
        transactions: [testTx('a', expense, 120, DateTime(2026, 9, 3))],
        budgets: [overall(const Money(100000), DateTime(2026, 9))],
      );

      final entry = provider.widgetTimeline().first;
      expect(entry.budgetLeft, const Money(-20000));
      expect(entry.isOverBudget, isTrue);
    });

    test('it stays on the current period whatever is selected', () async {
      final provider = await loaded(
        transactions: [testTx('a', expense, 30, DateTime(2026, 9, 3))],
      );
      provider.previousPeriod();
      provider.previousPeriod();
      expect(provider.period.start, DateTime(2026, 7));

      final entry = provider.widgetTimeline().first;
      expect(entry.period.start, DateTime(2026, 9));
      expect(entry.expense, const Money(30000));
    });

    test('a first day other than the 1st shapes the period', () async {
      final provider = await loaded(
        transactions: [
          // Before the 10th, so in the period that started 10 August.
          testTx('a', expense, 30, DateTime(2026, 9, 3)),
          testTx('b', expense, 7, DateTime(2026, 9, 12)),
        ],
        startDay: 10,
      );

      final entry = provider.widgetTimeline().first;
      expect(entry.period.start, DateTime(2026, 9, 10));
      expect(entry.expense, const Money(7000));
    });
  });

  group('the days ahead (WID-5, BAL-4)', () {
    test('a quiet month ahead is one entry per period start', () async {
      final provider = await loaded(
        transactions: [testTx('a', expense, 30, DateTime(2026, 9, 3))],
      );

      final timeline = provider.widgetTimeline();
      expect(timeline.length, 2);
      expect(timeline[0].from, DateTime(2026, 9, 15));
      expect(timeline[1].from, DateTime(2026, 10));
      expect(timeline[1].period.start, DateTime(2026, 10));
      // October has nothing of its own but carries September forward.
      expect(timeline[1].expense, Money.zero);
      expect(timeline[1].balance, const Money(-30000));
    });

    test('an entry dated ahead starts counting on its own day', () async {
      final provider = await loaded(
        transactions: [
          testTx('now', expense, 30, DateTime(2026, 9, 3)),
          testTx('soon', expense, 45, DateTime(2026, 9, 20)),
        ],
      );

      final timeline = provider.widgetTimeline();
      expect(timeline.first.expense, const Money(30000), reason: 'today');
      final onTheDay = timeline.firstWhere(
        (entry) => entry.from == DateTime(2026, 9, 20),
      );
      expect(onTheDay.expense, const Money(75000));
    });

    test('it looks no further ahead than it is asked to', () async {
      final provider = await loaded(
        transactions: [
          testTx('far', expense, 45, DateTime(2026, 10, 20)),
          testTx('near', expense, 45, DateTime(2026, 9, 18)),
        ],
      );

      final days = provider.widgetTimeline(days: 7).map((e) => e.from);
      expect(days, [DateTime(2026, 9, 15), DateTime(2026, 9, 18)]);
    });

    test('the days it lists are the days something changes', () async {
      final provider = await loaded(
        transactions: [
          testTx('one', expense, 1, DateTime(2026, 9, 18)),
          testTx('two', expense, 2, DateTime(2026, 9, 18)),
        ],
      );

      // Two entries on the same day are one change, not two.
      final days = provider.widgetTimeline(days: 10).map((e) => e.from);
      expect(days, [DateTime(2026, 9, 15), DateTime(2026, 9, 18)]);
    });

    test('a budget that changes with the period is followed', () async {
      final provider = await loaded(
        transactions: [testTx('a', expense, 30, DateTime(2026, 9, 3))],
        budgets: [
          overall(const Money(100000), DateTime(2026, 9)),
          overall(const Money(50000), DateTime(2026, 10)),
        ],
      );

      final timeline = provider.widgetTimeline();
      expect(timeline[0].budgetLeft, const Money(70000));
      // October starts fresh against its own, smaller limit (BUD-5).
      expect(timeline[1].budgetLeft, const Money(50000));
    });
  });

  group('showCurrentPeriod (WID-3)', () {
    test('brings Home back to today, and notifies once', () async {
      final provider = await loaded();
      provider.previousPeriod();
      var notified = 0;
      provider.addListener(() => notified++);

      provider.showCurrentPeriod();
      expect(provider.period.start, DateTime(2026, 9));
      expect(notified, 1);

      // Already there: nothing to tell anyone.
      provider.showCurrentPeriod();
      expect(notified, 1);
    });
  });
}
