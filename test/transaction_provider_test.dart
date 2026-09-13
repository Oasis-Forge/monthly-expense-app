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

    TransactionProvider reloadable() =>
        TransactionProvider(db: db, clock: () => now);

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
      expect(provider.deletedTransactions.single.id, 'a');

      final reloaded = reloadable();
      await reloaded.load();
      expect(reloaded.transactions, isEmpty);
      expect(reloaded.deletedTransactions.single.id, 'a');

      final row = (await (await db.database).query('transactions')).single;
      expect(row['amount'], 12500);
      expect(row['deleted_at'], now.toUtc().toIso8601String());
    });

    test('restore brings a trashed transaction back (DEL-4)', () async {
      await provider.addTransaction(
        testTx('a', expense, 10, DateTime(2026, 9, 1)),
      );
      await provider.deleteTransaction('a');

      await provider.restoreTransaction('a');

      expect(provider.deletedTransactions, isEmpty);
      expect(provider.transactions.single.deletedAt, isNull);
      final reloaded = reloadable();
      await reloaded.load();
      expect(reloaded.transactions.single.id, 'a');
      expect(reloaded.deletedTransactions, isEmpty);
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

    test('the start day can be set when the provider is created', () {
      final provider = TransactionProvider(
        db: FakeDB(),
        clock: () => today,
        startDay: 25,
      );

      expect(provider.period.start, DateTime(2026, 8, 25));
    });

    test('cached totals refresh after a change', () async {
      final provider = await loaded(FakeDB());
      expect(provider.periodExpense, Money.zero);

      await provider.addTransaction(
        testTx('a', expense, 8, DateTime(2026, 9, 14)),
      );

      expect(provider.periodExpense, const Money(8000));
    });
  });

  test('load purges trash older than 30 days (DEL-3)', () async {
    final fake = FakeDB(
      transactions: [
        testTx(
          'old',
          expense,
          1,
          DateTime(2026, 7, 1),
        ).copyWith(deletedAt: DateTime(2026, 8, 1)),
        testTx(
          'recent',
          expense,
          1,
          DateTime(2026, 9, 1),
        ).copyWith(deletedAt: DateTime(2026, 9, 10)),
      ],
    );

    final provider = await loaded(fake);

    expect([for (final t in provider.deletedTransactions) t.id], ['recent']);
    expect([for (final t in fake.rows) t.id], ['recent']);
    expect(provider.trashDaysLeft(provider.deletedTransactions.single), 25);
  });

  group('categories (CAT-3, CAT-4)', () {
    late FakeDB fake;
    late TransactionProvider provider;

    setUp(() async {
      fake = FakeDB(
        transactions: [testTx('a', expense, 5, DateTime(2026, 9, 1))],
      );
      provider = await loaded(fake);
    });

    List<String> expenseIds() => [
      for (final c in provider.categoriesFor(expense)) c.id,
    ];

    test('a new category goes to the end of its type and is saved', () async {
      final coffee = await provider.addCategory(
        type: expense,
        name: 'Coffee',
        icon: '☕',
      );

      expect(expenseIds(), ['cat-food', 'cat-rent', 'cat-other', coffee.id]);
      expect(coffee.sortOrder, 3);
      expect(fake.categories.last.name, 'Coffee');
    });

    test('reordering saves the new order', () async {
      await provider.reorderCategories(expense, 2, 0);

      expect(expenseIds(), ['cat-other', 'cat-food', 'cat-rent']);
      final saved = {for (final c in fake.categories) c.id: c.sortOrder};
      expect(
        [saved['cat-other'], saved['cat-food'], saved['cat-rent']],
        [0, 1, 2],
      );
    });

    test('archiving hides a category from pickers until unarchived', () async {
      await provider.archiveCategory('cat-food');
      expect(expenseIds(), ['cat-rent', 'cat-other']);
      expect(provider.archivedCategoriesFor(expense).single.id, 'cat-food');

      await provider.unarchiveCategory('cat-food');
      expect(expenseIds(), ['cat-food', 'cat-rent', 'cat-other']);
    });

    test('only an unused category can be deleted', () async {
      await expectLater(provider.deleteCategory('cat-food'), throwsStateError);

      await provider.deleteCategory('cat-rent');

      expect(expenseIds(), ['cat-food', 'cat-other']);
      expect(
        fake.categories.firstWhere((c) => c.id == 'cat-rent').deletedAt,
        isNotNull,
      );
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
      expect(provider.deletedTransactions, isEmpty);
      expect(notifications, 0);
    });

    test('a failed category change leaves categories unchanged', () async {
      await expectLater(provider.archiveCategory('cat-food'), throwsStateError);
      expect(provider.categoriesFor(expense), hasLength(3));
      expect(notifications, 0);
    });
  });
}
