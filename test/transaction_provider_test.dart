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
  const cash = Account.cashId;
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
      expect(provider.accounts.single.id, cash);
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

    test('accounts and transfers survive a reload', () async {
      final bank = await provider.addAccount(
        name: 'Bank',
        type: AccountType.bank,
        openingBalance: const Money(100000),
        openingDate: DateTime(2026, 9),
      );
      await provider.addTransfer(
        testTransfer('t', bank.id, cash, 40, DateTime(2026, 9, 5)),
      );

      final reloaded = reloadable();
      await reloaded.load();

      expect(reloaded.accountBalance(bank.id), const Money(60000));
      expect(reloaded.accountBalance(cash), const Money(40000));
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
              testAccount(cash, opening: 100, on: DateTime(2026, 1, 1)),
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
      transfers: [
        testTransfer(
          'old-transfer',
          cash,
          'bank',
          1,
          DateTime(2026, 7, 1),
        ).copyWith(deletedAt: DateTime(2026, 8, 1)),
      ],
    );

    final provider = await loaded(fake);

    expect([for (final t in provider.deletedTransactions) t.id], ['recent']);
    expect([for (final t in fake.rows) t.id], ['recent']);
    expect(fake.transfers, isEmpty);
    expect(provider.trashDaysLeft(provider.deletedTransactions.single), 25);
  });

  group('accounts (ACC-1, ACC-4, ACC-5)', () {
    late FakeDB fake;
    late TransactionProvider provider;

    setUp(() async {
      fake = FakeDB(
        accounts: [testAccount(cash, opening: 100), testAccount('bank')],
        transactions: [
          testTx('i', income, 50, DateTime(2026, 9, 1)),
          testTx(
            'e',
            expense,
            20,
            DateTime(2026, 9, 2),
          ).copyWith(accountId: 'bank'),
          testTx('later', expense, 999, DateTime(2026, 9, 20)),
        ],
        transfers: [
          testTransfer('t', cash, 'bank', 30, DateTime(2026, 9, 3)),
          testTransfer('later-t', 'bank', cash, 5, DateTime(2026, 9, 25)),
        ],
      );
      provider = await loaded(fake);
    });

    test('balances add opening, transactions, and transfers up to today', () {
      expect(provider.accountBalance(cash), const Money(120000));
      expect(provider.accountBalance('bank'), const Money(10000));
      // Every account together matches Home's closing balance.
      expect(provider.closingBalance, const Money(130000));
    });

    test('transfers are listed in the period but never counted (BAL-1)', () {
      expect(provider.periodIncome, const Money(50000));
      expect(provider.periodExpense, const Money(20000));
      expect(
        [for (final t in provider.periodTransfers) t.id],
        ['later-t', 't'],
      );
      expect(provider.transfersByDay.keys.toList(), [
        DateTime(2026, 9, 25),
        DateTime(2026, 9, 3),
      ]);
    });

    test('a new account is saved and counts from its opening date', () async {
      final card = await provider.addAccount(
        name: 'Card',
        type: AccountType.card,
        openingBalance: const Money(-40000),
        openingDate: DateTime(2026, 9, 10),
      );

      expect(provider.activeAccounts.last.id, card.id);
      expect(fake.accounts.last.name, 'Card');
      expect(provider.accountBalance(card.id), const Money(-40000));

      await provider.updateAccount(card.copyWith(name: 'Visa'));
      expect(provider.accountById(card.id)!.name, 'Visa');
    });

    test(
      'an account with history can be archived, not deleted (ACC-5)',
      () async {
        await expectLater(provider.deleteAccount(cash), throwsStateError);

        await provider.archiveAccount('bank');
        expect([for (final a in provider.activeAccounts) a.id], [cash]);
        expect(provider.archivedAccounts.single.id, 'bank');
        // The last active account stays active.
        await expectLater(provider.archiveAccount(cash), throwsStateError);

        await provider.unarchiveAccount('bank');
        expect(provider.activeAccounts, hasLength(2));
      },
    );

    test('an unused account can be deleted', () async {
      final spare = await provider.addAccount(
        name: 'Spare',
        type: AccountType.other,
        openingBalance: Money.zero,
        openingDate: DateTime(2026, 9),
      );

      await provider.deleteAccount(spare.id);

      expect(provider.accountById(spare.id), isNull);
      expect(
        fake.accounts.firstWhere((a) => a.id == spare.id).deletedAt,
        isNotNull,
      );
    });
  });

  group('transfers (ACC-3)', () {
    late FakeDB fake;
    late TransactionProvider provider;

    setUp(() async {
      fake = FakeDB(accounts: [testAccount(cash), testAccount('bank')]);
      provider = await loaded(fake);
    });

    test('adding, editing, deleting, and restoring a transfer', () async {
      await provider.addTransfer(
        testTransfer('t', cash, 'bank', 30, DateTime(2026, 9, 3)),
      );
      expect(provider.accountBalance('bank'), const Money(30000));
      expect(provider.isAccountUsed('bank'), isTrue);

      await provider.updateTransfer(
        provider.transfers.single.copyWith(amount: const Money(45000)),
      );
      expect(fake.transfers.single.amount, const Money(45000));

      await provider.deleteTransfer('t');
      expect(provider.transfers, isEmpty);
      expect(provider.accountBalance('bank'), Money.zero);

      await provider.restoreTransfer('t');
      expect(provider.transfers.single.deletedAt, isNull);
      expect(provider.accountBalance('bank'), const Money(45000));
    });

    test('a transfer needs two different accounts', () async {
      await expectLater(
        provider.addTransfer(
          testTransfer('t', cash, cash, 1, DateTime(2026, 9, 3)),
        ),
        throwsArgumentError,
      );
      expect(fake.transfers, isEmpty);
    });
  });

  group('form defaults (ADD-3, ADD-5)', () {
    test('the last used category and account come first', () async {
      final provider = await loaded(
        FakeDB(
          accounts: [testAccount(cash), testAccount('bank')],
          transactions: [
            testTx(
              '1',
              expense,
              1,
              DateTime(2026, 9, 1),
              categoryId: 'cat-rent',
            ).copyWith(createdAt: DateTime.utc(2026, 9, 1)),
            testTx(
              '2',
              expense,
              1,
              DateTime(2026, 9, 1),
            ).copyWith(accountId: 'bank', createdAt: DateTime.utc(2026, 9, 4)),
            testTx(
              '3',
              expense,
              1,
              DateTime(2026, 9, 1),
              categoryId: 'cat-rent',
            ).copyWith(createdAt: DateTime.utc(2026, 9, 2)),
          ],
        ),
      );

      expect(provider.defaultCategoryId(expense), 'cat-food');
      expect(
        [for (final c in provider.recentCategories(expense)) c.id],
        ['cat-food', 'cat-rent'],
      );
      expect(provider.defaultCategoryId(income), 'cat-salary');
      expect(provider.defaultAccountId(), 'bank');
    });

    test(
      'without history the first active category and account are used',
      () async {
        final provider = await loaded(FakeDB());

        expect(provider.defaultCategoryId(expense), 'cat-food');
        expect(provider.recentCategories(expense), isEmpty);
        expect(provider.defaultAccountId(), cash);
      },
    );

    test('archived choices are skipped', () async {
      final provider = await loaded(
        FakeDB(
          accounts: [testAccount(cash), testAccount('bank')],
          transactions: [
            testTx(
              '1',
              expense,
              1,
              DateTime(2026, 9, 1),
            ).copyWith(accountId: 'bank'),
          ],
        ),
      );

      await provider.archiveCategory('cat-food');
      await provider.archiveAccount('bank');

      expect(provider.recentCategories(expense), isEmpty);
      expect(provider.defaultCategoryId(expense), 'cat-rent');
      expect(provider.defaultAccountId(), cash);
    });
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
        accounts: [testAccount(cash), testAccount('bank')],
        transactions: [
          testTx('keep', expense, 5, DateTime(2026, 9, 2)),
          testTx('x', expense, 10, DateTime(2026, 9, 1)),
        ],
        transfers: [testTransfer('t', cash, 'bank', 3, DateTime(2026, 9, 1))],
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

    test(
      'failed category, account, and transfer changes change nothing',
      () async {
        await expectLater(
          provider.archiveCategory('cat-food'),
          throwsStateError,
        );
        await expectLater(provider.archiveAccount('bank'), throwsStateError);
        await expectLater(provider.deleteTransfer('t'), throwsStateError);
        await expectLater(
          provider.addAccount(
            name: 'Card',
            type: AccountType.card,
            openingBalance: Money.zero,
            openingDate: DateTime(2026, 9),
          ),
          throwsStateError,
        );

        expect(provider.categoriesFor(expense), hasLength(3));
        expect(provider.activeAccounts, hasLength(2));
        expect(provider.transfers, hasLength(1));
        expect(notifications, 0);
      },
    );
  });
}
