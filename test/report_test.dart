import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/report.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/models/transfer.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 9, 15);

  Account account(String id, num opening, DateTime openingDate) =>
      testAccount(id, opening: opening, on: openingDate);

  Transfer transfer(
    String id,
    String from,
    String to,
    num amount,
    DateTime on,
  ) => Transfer(
    id: id,
    fromAccountId: from,
    toAccountId: to,
    amount: Money((amount * 1000).round()),
    date: on,
  );

  ReportData report({
    DateTime? from,
    DateTime? to,
    List<ExpenseTransaction> transactions = const [],
    List<Transfer> transfers = const [],
    List<Account> accounts = const [],
    String? accountId,
    Money? Function(String)? budgetLimit,
    int startDay = 1,
    ReportOptions options = const ReportOptions(),
  }) => buildReport(
    from: from ?? DateTime(2026, 9, 1),
    to: to ?? DateTime(2026, 9, 30),
    today: today,
    transactions: transactions,
    transfers: transfers,
    accounts: accounts,
    accountId: accountId,
    budgetLimit: budgetLimit,
    startDay: startDay,
    options: options,
  );

  group('report figures (PDF-2)', () {
    test('income, expense, and net count only what has happened (BAL-4)', () {
      final data = report(
        transactions: [
          testTx('a', TransactionType.income, 1000, DateTime(2026, 9, 2)),
          testTx('b', TransactionType.expense, 250, DateTime(2026, 9, 10)),
          // Dated in the range but after today, so it counts towards nothing.
          testTx('c', TransactionType.expense, 900, DateTime(2026, 9, 20)),
        ],
      );

      expect(data.income.toDouble(), 1000);
      expect(data.expense.toDouble(), 250);
      expect(data.net.toDouble(), 750);
      expect(data.upcoming.single.transaction!.id, 'c');
    });

    test('the opening balance carries in what came before (BAL-2)', () {
      final data = report(
        accounts: [account('cash', 500, DateTime(2026, 1, 1))],
        transactions: [
          testTx('old', TransactionType.expense, 200, DateTime(2026, 8, 20)),
          testTx('a', TransactionType.expense, 100, DateTime(2026, 9, 5)),
        ],
      );

      expect(data.openingBalance.toDouble(), 300);
      expect(data.closingBalance.toDouble(), 200);
    });

    test('an account opened inside the range lands in the closing balance '
        'only (BAL-3)', () {
      final data = report(
        accounts: [account('savings', 400, DateTime(2026, 9, 10))],
      );

      expect(data.openingBalance.toDouble(), 0);
      expect(data.closingBalance.toDouble(), 400);
    });

    test('an account opened after today counts nowhere yet (BAL-4)', () {
      final data = report(
        accounts: [account('later', 400, DateTime(2026, 9, 25))],
      );

      expect(data.openingBalance.toDouble(), 0);
      expect(data.closingBalance.toDouble(), 0);
    });

    test('entries outside the range are left out entirely', () {
      final data = report(
        from: DateTime(2026, 9, 5),
        to: DateTime(2026, 9, 10),
        transactions: [
          testTx('before', TransactionType.expense, 10, DateTime(2026, 9, 4)),
          testTx('in', TransactionType.expense, 20, DateTime(2026, 9, 7)),
          testTx('after', TransactionType.expense, 30, DateTime(2026, 9, 11)),
        ],
      );

      expect(data.entryCount, 1);
      expect(data.byDay.values.single.single.transaction!.id, 'in');
      expect(data.expense.toDouble(), 20);
    });
  });

  group('report categories (PDF-2, BUD-2)', () {
    test('lines are largest first, with each share of the total', () {
      final data = report(
        transactions: [
          testTx(
            'a',
            TransactionType.expense,
            25,
            DateTime(2026, 9, 2),
            categoryId: 'cat-food',
          ),
          testTx(
            'b',
            TransactionType.expense,
            75,
            DateTime(2026, 9, 3),
            categoryId: 'cat-rent',
          ),
        ],
      );

      expect(data.expenseCategories.map((line) => line.categoryId), [
        'cat-rent',
        'cat-food',
      ]);
      expect(data.expenseCategories.first.share, 0.75);
      expect(data.expenseCategories.last.share, 0.25);
    });

    test('a category with a budget reports how much of it is used', () {
      final data = report(
        transactions: [
          testTx(
            'a',
            TransactionType.expense,
            60,
            DateTime(2026, 9, 2),
            categoryId: 'cat-food',
          ),
        ],
        budgetLimit: (id) => id == 'cat-food' ? const Money(100000) : null,
      );

      final line = data.expenseCategories.single;
      expect(line.budget!.toDouble(), 100);
      expect(line.budgetUsed, 0.6);
    });

    test('a category without a budget reports none', () {
      final data = report(
        transactions: [
          testTx('a', TransactionType.expense, 60, DateTime(2026, 9, 2)),
        ],
      );

      expect(data.expenseCategories.single.budget, isNull);
      expect(data.expenseCategories.single.budgetUsed, isNull);
    });

    test('shares are zero rather than infinite when nothing was spent', () {
      final data = report();
      expect(data.expenseCategories, isEmpty);
      expect(data.isEmpty, isTrue);
    });
  });

  group('report trend (PDF-2, INS-2)', () {
    test('a short range draws a point a day, including empty ones', () {
      final data = report(
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 3),
        transactions: [
          testTx('a', TransactionType.expense, 10, DateTime(2026, 9, 2)),
        ],
      );

      expect(data.trend, hasLength(3));
      expect(data.trend.every((p) => p.label == ReportTrendGrain.day), isTrue);
      expect(data.trend[0].expense.toDouble(), 0);
      expect(data.trend[1].expense.toDouble(), 10);
    });

    test('a year draws a point a period instead of 365 (PDF-2)', () {
      final data = report(
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 12, 31),
        transactions: [
          testTx('a', TransactionType.expense, 10, DateTime(2026, 3, 4)),
        ],
      );

      expect(data.trend, hasLength(12));
      expect(
        data.trend.every((p) => p.label == ReportTrendGrain.period),
        isTrue,
      );
      expect(data.trend[2].expense.toDouble(), 10);
    });
  });

  group('report accounts and transfers (PDF-1, ACC-4)', () {
    test('transfers show in the day list but move no total', () {
      final data = report(
        accounts: [
          account('cash', 100, DateTime(2026, 1, 1)),
          account('bank', 100, DateTime(2026, 1, 1)),
        ],
        transfers: [transfer('t', 'cash', 'bank', 50, DateTime(2026, 9, 4))],
      );

      expect(data.byDay.values.single.single.isTransfer, isTrue);
      expect(data.income.toDouble(), 0);
      expect(data.expense.toDouble(), 0);
      expect(data.closingBalance.toDouble(), 200);
    });

    test('narrowed to one account, only its entries and balance appear', () {
      final data = report(
        accountId: 'cash',
        accounts: [
          account('cash', 100, DateTime(2026, 1, 1)),
          account('bank', 900, DateTime(2026, 1, 1)),
        ],
        transactions: [
          testTx(
            'mine',
            TransactionType.expense,
            10,
            DateTime(2026, 9, 5),
            accountId: 'cash',
          ),
          testTx(
            'theirs',
            TransactionType.expense,
            70,
            DateTime(2026, 9, 6),
            accountId: 'bank',
          ),
        ],
      );

      expect(data.entryCount, 1);
      expect(data.expense.toDouble(), 10);
      expect(data.openingBalance.toDouble(), 100);
      expect(data.closingBalance.toDouble(), 90);
    });

    test('narrowed to one account, a transfer moves its balance', () {
      final data = report(
        accountId: 'cash',
        accounts: [account('cash', 100, DateTime(2026, 1, 1))],
        transfers: [
          transfer('in', 'bank', 'cash', 30, DateTime(2026, 9, 4)),
          transfer('out', 'cash', 'bank', 10, DateTime(2026, 9, 5)),
          // Before the range, so it lands in the opening balance instead.
          transfer('earlier', 'bank', 'cash', 5, DateTime(2026, 8, 20)),
        ],
      );

      expect(data.openingBalance.toDouble(), 105);
      expect(data.closingBalance.toDouble(), 125);
    });
  });

  group('report privacy options (PDF-3)', () {
    test('leaving the transaction list out keeps the figures', () {
      final data = report(
        options: const ReportOptions(transactions: false),
        transactions: [
          testTx('a', TransactionType.expense, 40, DateTime(2026, 9, 2)),
        ],
      );

      expect(data.byDay, isEmpty);
      expect(data.expense.toDouble(), 40);
      expect(data.expenseCategories, hasLength(1));
      expect(data.entryCount, 1);
    });
  });

  group('report ordering', () {
    test('days run oldest first, and so do the entries within a day', () {
      final data = report(
        transactions: [
          testTx('late', TransactionType.expense, 1, DateTime(2026, 9, 9, 18)),
          testTx('early', TransactionType.expense, 1, DateTime(2026, 9, 9, 8)),
          testTx('first', TransactionType.expense, 1, DateTime(2026, 9, 2)),
        ],
      );

      expect(data.byDay.keys.toList(), [
        DateTime(2026, 9, 2),
        DateTime(2026, 9, 9),
      ]);
      expect(data.byDay[DateTime(2026, 9, 9)]!.map((e) => e.transaction!.id), [
        'early',
        'late',
      ]);
    });
  });
}
