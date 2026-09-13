import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  const income = TransactionType.income;
  final today = DateTime(2026, 9, 15, 10);

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<TransactionProvider> loaded(FakeDB db, {DateTime? now}) async {
    final provider = TransactionProvider(db: db, clock: () => now ?? today);
    await provider.load();
    return provider;
  }

  group('with the real database', () {
    late DBHelper db;
    late DateTime now;
    late TransactionProvider provider;

    setUp(() async {
      db = DBHelper(path: inMemoryDatabasePath);
      now = today;
      provider = TransactionProvider(db: db, clock: () => now);
      await provider.load();
    });

    tearDown(() => db.close());

    test('load reads the default categories and the Cash account', () {
      expect(provider.categoriesFor(expense), hasLength(10));
      expect(provider.categoriesFor(income), hasLength(5));
      expect(provider.categoryById('cat-food')!.icon, '🍔');
      expect(provider.accounts.single.id, Account.cashId);
    });

    test('writes stamp timestamps and delete is soft (REC-1, DEL-1)', () async {
      await provider.addTransaction(
        testTx('a', expense, 10, DateTime(2026, 9, 1)),
      );
      final added = provider.transactions.single;
      expect(added.createdAt, today.toUtc());
      expect(added.updatedAt, today.toUtc());

      now = today.add(const Duration(hours: 1));
      await provider.updateTransaction(
        added.copyWith(amount: const Money(12500)),
      );
      final updated = provider.transactions.single;
      expect(updated.createdAt, today.toUtc());
      expect(updated.updatedAt, now.toUtc());

      await provider.deleteTransaction('a');
      expect(provider.transactions, isEmpty);

      final reloaded = TransactionProvider(db: db, clock: () => now);
      await reloaded.load();
      expect(reloaded.transactions, isEmpty);

      final row = (await (await db.database).query('transactions')).single;
      expect(row['amount'], 12500);
      expect(row['deleted_at'], now.toUtc().toIso8601String());
    });
  });

  group('period totals (PER-1, BAL-1–BAL-5)', () {
    test(
      'totals, categories, and day groups cover the selected period',
      () async {
        final provider = await loaded(
          FakeDB(
            transactions: [
              testTx('s1', income, 1000, DateTime(2026, 9, 5)),
              testTx('s2', expense, 20, DateTime(2026, 9, 5)),
              testTx('s3', expense, 10, DateTime(2026, 9, 12)),
              testTx(
                's4',
                expense,
                15,
                DateTime(2026, 9, 12),
                categoryId: 'cat-rent',
              ),
              testTx('a1', expense, 7, DateTime(2026, 8, 31)),
            ],
          ),
        );

        expect(provider.period.start, DateTime(2026, 9));
        expect(provider.periodIncome, const Money(1000000));
        expect(provider.periodExpense, const Money(45000));
        expect(provider.periodNet, const Money(955000));
        expect(provider.expenseByCategory, {
          'cat-food': const Money(30000),
          'cat-rent': const Money(15000),
        });
        expect(provider.groupedByDay.keys.toList(), [
          DateTime(2026, 9, 12),
          DateTime(2026, 9, 5),
        ]);
        expect(provider.carriedForward, const Money(-7000));
        expect(provider.closingBalance, const Money(948000));

        provider.previousPeriod();
        expect(provider.period.start, DateTime(2026, 8));
        expect(provider.periodExpense, const Money(7000));

        provider.nextPeriod();
        provider.nextPeriod();
        expect(provider.periodTransactions, isEmpty);
      },
    );

    test(
      'future-dated transactions are listed but not counted (BAL-4)',
      () async {
        final provider = await loaded(
          FakeDB(
            transactions: [
              testTx('later', expense, 50, DateTime(2026, 9, 20)),
              testTx('tonight', expense, 5, DateTime(2026, 9, 15, 20)),
            ],
          ),
        );

        final ids = [for (final t in provider.periodTransactions) t.id];
        expect(ids, ['later', 'tonight']);
        expect(provider.periodExpense, const Money(5000));
        expect(provider.expenseByCategory, {'cat-food': const Money(5000)});
        expect(provider.isUpcoming(provider.periodTransactions.first), isTrue);
        expect(provider.isUpcoming(provider.periodTransactions.last), isFalse);
      },
    );

    test(
      'balances count opening balances from their date (BAL-2, BAL-3)',
      () async {
        final provider = await loaded(
          FakeDB(
            accounts: [
              testAccount(
                Account.cashId,
                opening: 100,
                on: DateTime(2026, 1, 1),
              ),
              testAccount('bank', opening: 40, on: DateTime(2026, 9, 10)),
            ],
            transactions: [
              testTx('i', income, 50, DateTime(2026, 8, 3)),
              testTx('e', expense, 20, DateTime(2026, 8, 4)),
              testTx('s', income, 10, DateTime(2026, 9, 2)),
            ],
          ),
        );

        expect(provider.carriedForward, const Money(130000));
        expect(provider.closingBalance, const Money(180000));
      },
    );

    test(
      'a month start day of 25 moves the period boundaries (PER-2)',
      () async {
        final provider = await loaded(
          FakeDB(
            transactions: [
              testTx('before', expense, 10, DateTime(2026, 9, 24)),
              testTx('first day', expense, 3, DateTime(2026, 9, 25)),
            ],
          ),
          now: DateTime(2026, 9, 26),
        );

        provider.setStartDay(25);

        expect(provider.period.start, DateTime(2026, 9, 25));
        expect(provider.period.end, DateTime(2026, 10, 25));
        expect(provider.periodExpense, const Money(3000));
        expect(provider.carriedForward, const Money(-10000));
      },
    );

    test('cached totals refresh after a change', () async {
      final provider = await loaded(FakeDB());
      expect(provider.periodExpense, Money.zero);

      await provider.addTransaction(
        testTx('a', expense, 8, DateTime(2026, 9, 14)),
      );

      expect(provider.periodExpense, const Money(8000));
    });
  });

  group('when a database write fails', () {
    late FakeDB fake;
    late TransactionProvider provider;
    late int notifications;

    setUp(() async {
      fake = FakeDB(
        transactions: [
          testTx('keep', expense, 5, DateTime(2026, 9, 2)),
          testTx('x', expense, 10, DateTime(2026, 9, 1)),
        ],
      );
      provider = await loaded(fake);
      fake.failWrites = true;
      notifications = 0;
      provider.addListener(() => notifications++);
    });

    List<String> ids() => [for (final t in provider.transactions) t.id];

    test('add rethrows and leaves the list unchanged', () async {
      await expectLater(
        provider.addTransaction(testTx('new', income, 1, DateTime(2026, 9, 3))),
        throwsStateError,
      );
      expect(ids(), ['keep', 'x']);
      expect(notifications, 0);
    });

    test('update rethrows and keeps the old values', () async {
      await expectLater(
        provider.updateTransaction(
          provider.transactions.last.copyWith(amount: const Money(99000)),
        ),
        throwsStateError,
      );
      expect(provider.transactions.last.amount, const Money(10000));
      expect(notifications, 0);
    });

    test('delete rethrows and leaves the list unchanged', () async {
      await expectLater(provider.deleteTransaction('keep'), throwsStateError);
      expect(ids(), ['keep', 'x']);
      expect(notifications, 0);
    });
  });
}
