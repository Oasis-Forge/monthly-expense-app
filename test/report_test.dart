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
    bool Function(ExpenseTransaction)? matches,
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
    matches: matches,
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

  group('a report narrowed to a search (PDF-1, ACC-6, review-money-2)', () {
    test('carries no budget, even within one period', () {
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
        matches: (tx) => true,
        budgetLimit: (id) => id == 'cat-food' ? const Money(100000) : null,
      );

      expect(data.expenseCategories.single.budget, isNull);
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

  group('report narrowed by a search filter (PDF-1, BAL-2, BAL-3, BAK-5)', () {
    bool matchesRent(ExpenseTransaction tx) => tx.title == 'Rent';

    test('opening and closing balance stay true regardless of the filter', () {
      // The scenario from the audit: cash opening 1000, Salary +900 (Aug 1),
      // Rent -800 (Aug 2), Rent -800 (Sep 1), a Freelance +500 that doesn't
      // match "Rent" (Sep 15), reported for Sep 1-30.
      final accounts = [account('cash', 1000, DateTime(2026, 1, 1))];
      final transactions = [
        testTx(
          'salary',
          TransactionType.income,
          900,
          DateTime(2026, 8, 1),
          title: 'Salary',
        ),
        testTx(
          'rent-aug',
          TransactionType.expense,
          800,
          DateTime(2026, 8, 2),
          title: 'Rent',
        ),
        testTx(
          'rent-sep',
          TransactionType.expense,
          800,
          DateTime(2026, 9, 1),
          title: 'Rent',
        ),
        testTx(
          'freelance',
          TransactionType.income,
          500,
          DateTime(2026, 9, 15),
          title: 'Freelance',
        ),
      ];

      final unfiltered = report(accounts: accounts, transactions: transactions);
      final filtered = report(
        accounts: accounts,
        transactions: transactions,
        matches: matchesRent,
      );

      expect(unfiltered.openingBalance.toDouble(), 1100);
      expect(unfiltered.closingBalance.toDouble(), 800);
      // The filtered report never states a false balance (BAL-2, BAL-3):
      // both figures match the unfiltered report exactly.
      expect(filtered.openingBalance, unfiltered.openingBalance);
      expect(filtered.closingBalance, unfiltered.closingBalance);
    });

    test('only matching entries show in the day list, income, expense, and '
        'categories', () {
      final transactions = [
        testTx(
          'rent-sep',
          TransactionType.expense,
          800,
          DateTime(2026, 9, 1),
          title: 'Rent',
        ),
        testTx(
          'freelance',
          TransactionType.income,
          500,
          DateTime(2026, 9, 15),
          title: 'Freelance',
        ),
      ];

      final filtered = report(transactions: transactions, matches: matchesRent);

      expect(filtered.entryCount, 1);
      expect(filtered.income.toDouble(), 0);
      expect(filtered.expense.toDouble(), 800);
      expect(filtered.incomeCategories, isEmpty);
      expect(
        filtered.byDay.values.expand((e) => e).single.transaction!.id,
        'rent-sep',
      );
    });

    test('a matching entry after today still lands in upcoming', () {
      final transactions = [
        testTx(
          'rent-upcoming',
          TransactionType.expense,
          800,
          DateTime(2026, 9, 20),
          title: 'Rent',
        ),
        testTx(
          'other-upcoming',
          TransactionType.expense,
          10,
          DateTime(2026, 9, 21),
          title: 'Coffee',
        ),
      ];

      final filtered = report(transactions: transactions, matches: matchesRent);

      expect(filtered.upcoming.single.transaction!.id, 'rent-upcoming');
    });

    test('transfers are left out of the day list and upcoming, but their '
        'balance still counts (ACC-4)', () {
      final data = report(
        accountId: 'cash',
        accounts: [account('cash', 100, DateTime(2026, 1, 1))],
        transfers: [
          transfer('in', 'bank', 'cash', 30, DateTime(2026, 9, 4)),
          // Dated after today, so it would otherwise land in upcoming.
          transfer('later', 'bank', 'cash', 5, DateTime(2026, 9, 20)),
        ],
        matches: matchesRent,
      );

      expect(data.byDay, isEmpty);
      expect(data.upcoming, isEmpty);
      expect(data.entryCount, 0);
      expect(data.closingBalance.toDouble(), 130);
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

    test('upcoming entries run oldest first, transfers among them (PDF-2)', () {
      final data = report(
        // Newest first, the way the provider hands them over.
        transactions: [
          testTx('later', TransactionType.expense, 5, DateTime(2026, 9, 25)),
          testTx('sooner', TransactionType.expense, 5, DateTime(2026, 9, 18)),
        ],
        transfers: [transfer('t', 'cash', 'bank', 5, DateTime(2026, 9, 20))],
      );

      expect(data.upcoming.map((entry) => entry.date), [
        DateTime(2026, 9, 18),
        DateTime(2026, 9, 20),
        DateTime(2026, 9, 25),
      ]);
    });
  });

  group('report edges (PDF-1, PDF-2, BAL-2–BAL-4, ACC-8)', () {
    test('the first and last day of the range both count (PDF-1)', () {
      final data = report(
        from: DateTime(2026, 9, 5),
        to: DateTime(2026, 9, 10),
        transactions: [
          testTx('first', TransactionType.expense, 10, DateTime(2026, 9, 5)),
          testTx(
            'last',
            TransactionType.expense,
            20,
            DateTime(2026, 9, 10, 21),
          ),
        ],
      );

      expect(data.entryCount, 2);
      expect(data.expense.toDouble(), 30);
    });

    test('an entry dated today counts rather than waiting (BAL-4)', () {
      final data = report(
        transactions: [
          testTx(
            'tonight',
            TransactionType.expense,
            30,
            DateTime(2026, 9, 15, 23, 30),
          ),
        ],
      );

      expect(data.expense.toDouble(), 30);
      expect(data.upcoming, isEmpty);
    });

    test('an account opened on the first day counts once, in the closing '
        'balance (BAL-2, BAL-3)', () {
      final data = report(
        accounts: [account('savings', 400, DateTime(2026, 9, 1))],
      );

      expect(data.openingBalance.toDouble(), 0);
      expect(data.closingBalance.toDouble(), 400);
    });

    test('a range after today carries in only what has happened (BAL-4)', () {
      final data = report(
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 31),
        accounts: [account('cash', 500, DateTime(2026, 1, 1))],
        transactions: [
          testTx('done', TransactionType.expense, 100, DateTime(2026, 9, 10)),
          // After today, so it isn't carried into October yet.
          testTx('soon', TransactionType.expense, 50, DateTime(2026, 9, 20)),
        ],
      );

      expect(data.openingBalance.toDouble(), 400);
      expect(data.closingBalance.toDouble(), 400);
    });

    test('the trend keeps each day\'s income and expense apart (INS-2)', () {
      final data = report(
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 3),
        transactions: [
          testTx('pay', TransactionType.income, 100, DateTime(2026, 9, 2)),
          testTx('lunch', TransactionType.expense, 10, DateTime(2026, 9, 2)),
        ],
      );

      expect(data.trend[1].income.toDouble(), 100);
      expect(data.trend[1].expense.toDouble(), 10);
    });

    test('a range of exactly two periods is still drawn a day at a time '
        '(PDF-2)', () {
      final data = report(
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 10, 31),
      );

      expect(data.trend, hasLength(61));
      expect(data.trend.every((p) => p.label == ReportTrendGrain.day), isTrue);
    });

    test('income lines take their share of the income total (PDF-2)', () {
      final data = report(
        transactions: [
          testTx('pay', TransactionType.income, 300, DateTime(2026, 9, 2)),
          testTx(
            'gift',
            TransactionType.income,
            100,
            DateTime(2026, 9, 3),
            categoryId: 'cat-income-other',
          ),
          testTx('lunch', TransactionType.expense, 50, DateTime(2026, 9, 4)),
        ],
      );

      expect(data.incomeCategories.map((line) => line.share), [0.75, 0.25]);
    });

    test('a zero budget reports no progress rather than infinity (BUD-2)', () {
      const line = ReportCategoryLine(
        categoryId: 'cat-food',
        amount: Money(5000),
        share: 1,
        budget: Money.zero,
      );

      expect(line.budgetUsed, isNull);
    });

    test('narrowed to one account, another account opened in the range '
        'stays out (ACC-8)', () {
      final data = report(
        accountId: 'cash',
        accounts: [
          account('cash', 100, DateTime(2026, 1, 1)),
          account('bank', 900, DateTime(2026, 9, 10)),
        ],
      );

      expect(data.closingBalance.toDouble(), 100);
    });

    test('narrowed to one account, a transfer out before the range lowers '
        'its opening balance (ACC-8)', () {
      final data = report(
        accountId: 'cash',
        accounts: [account('cash', 100, DateTime(2026, 1, 1))],
        transfers: [transfer('out', 'cash', 'bank', 40, DateTime(2026, 8, 20))],
      );

      expect(data.openingBalance.toDouble(), 60);
      expect(data.closingBalance.toDouble(), 60);
    });

    test('narrowed to one account, an upcoming transfer moves no balance yet '
        '(ACC-8, BAL-4)', () {
      final data = report(
        accountId: 'cash',
        accounts: [account('cash', 100, DateTime(2026, 1, 1))],
        transfers: [transfer('in', 'bank', 'cash', 30, DateTime(2026, 9, 20))],
      );

      expect(data.closingBalance.toDouble(), 100);
      expect(data.upcoming.single.isTransfer, isTrue);
      expect(data.byDay, isEmpty);
    });
  });
}
