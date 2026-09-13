import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  const income = TransactionType.income;
  final today = DateTime(2026, 9, 15);

  Future<TransactionProvider> providerWith(
    List<ExpenseTransaction> transactions, {
    int startDay = 1,
  }) async {
    final provider = TransactionProvider(
      db: FakeDB(transactions: transactions),
      clock: () => today,
      startDay: startDay,
    );
    await provider.load();
    return provider;
  }

  test('isLoaded turns true once loading finishes', () async {
    final provider = TransactionProvider(db: FakeDB(), clock: () => today);
    expect(provider.isLoaded, isFalse);

    await provider.load();

    expect(provider.isLoaded, isTrue);
    expect(provider.today, today);
  });

  test('daily totals include upcoming days; category totals do not '
      '(INS-1, INS-3, BAL-4)', () async {
    final provider = await providerWith([
      testTx('a', expense, 10, DateTime(2026, 9, 5, 9)),
      testTx('b', expense, 5, DateTime(2026, 9, 5, 18)),
      testTx('c', income, 100, DateTime(2026, 9, 5)),
      testTx('d', expense, 40, DateTime(2026, 9, 20)),
      testTx(
        'e',
        income,
        7,
        DateTime(2026, 9, 1),
        categoryId: 'cat-income-other',
      ),
      testTx('f', expense, 99, DateTime(2026, 8, 31)),
    ]);

    final fifth = provider.dailyTotals[DateTime(2026, 9, 5)]!;
    expect(
      (fifth.income, fifth.expense),
      (const Money(100000), const Money(15000)),
    );
    expect(
      provider.dailyTotals[DateTime(2026, 9, 20)]!.expense,
      const Money(40000),
    );
    expect(provider.dailyTotals.containsKey(DateTime(2026, 8, 31)), isFalse);
    expect(provider.incomeByCategory, {
      'cat-salary': const Money(100000),
      'cat-income-other': const Money(7000),
    });
    expect(provider.expenseByCategory, {'cat-food': const Money(15000)});
  });

  test(
    'the trend covers the periods ending with the selected one (INS-2)',
    () async {
      final provider = await providerWith([
        testTx('march', expense, 1, DateTime(2026, 3)),
        testTx('july', income, 200, DateTime(2026, 7)),
        testTx('august', expense, 60, DateTime(2026, 8, 10)),
        testTx('september', expense, 30, DateTime(2026, 9, 5)),
        testTx('upcoming', expense, 40, DateTime(2026, 9, 20)),
      ]);

      final trend = provider.trend(3);

      expect(
        [for (final totals in trend) totals.period.start],
        [DateTime(2026, 7), DateTime(2026, 8), DateTime(2026, 9)],
      );
      expect(
        [for (final totals in trend) (totals.income, totals.expense)],
        [
          (const Money(200000), Money.zero),
          (Money.zero, const Money(60000)),
          (Money.zero, const Money(30000)),
        ],
      );
      expect(trend.last.net, const Money(-30000));

      provider.previousPeriod();
      expect(provider.trend(1).single.expense, const Money(60000));
    },
  );

  test('trend periods follow the first day of the month (PER-1)', () async {
    final provider = await providerWith([
      testTx('before', expense, 10, DateTime(2026, 8, 24)),
      testTx('after', expense, 20, DateTime(2026, 8, 25)),
    ], startDay: 25);

    final trend = provider.trend(2);

    expect(trend.first.period.start, DateTime(2026, 7, 25));
    expect(
      [for (final totals in trend) totals.expense],
      [const Money(10000), const Money(20000)],
    );
  });
}
