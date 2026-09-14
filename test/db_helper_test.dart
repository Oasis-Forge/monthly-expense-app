import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/category.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  late Directory dir;
  final opened = <DBHelper>[];

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    dir = Directory.systemTemp.createTempSync('db_helper_test');
  });

  tearDown(() async {
    for (final helper in opened) {
      await helper.close();
    }
    opened.clear();
    dir.deleteSync(recursive: true);
  });

  /// A helper for [file] in the temp directory, using the app's schema steps
  /// unless [steps] is given.
  DBHelper helperAt(String file, [List<Migration>? steps]) {
    final helper = DBHelper(path: p.join(dir.path, file), migrations: steps);
    opened.add(helper);
    return helper;
  }

  Future<List<String>> columns(DBHelper helper, String table) async {
    final db = await helper.database;
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return [for (final row in rows) row['name']! as String];
  }

  group('migration scaffold', () {
    Future<void> addTags(DatabaseExecutor db) =>
        db.execute('CREATE TABLE tags (id TEXT PRIMARY KEY)');
    Future<void> addLabels(DatabaseExecutor db) =>
        db.execute('CREATE TABLE labels (id TEXT PRIMARY KEY)');

    test('version is 1 plus the number of steps', () {
      expect(DBHelper(migrations: []).version, 1);
      expect(DBHelper(migrations: [addTags, addLabels]).version, 3);
      expect(DBHelper().version, DBHelper.schemaMigrations.length + 1);
    });

    test(
      'upgrading from an intermediate version runs only newer steps',
      () async {
        final v2 = helperAt('app.db', [addTags]);
        await v2.database;
        await v2.close();

        // Re-running addTags would fail because the table already exists.
        final v3 = helperAt('app.db', [addTags, addLabels]);

        expect(await (await v3.database).getVersion(), 3);
        expect(await columns(v3, 'labels'), ['id']);
      },
    );
  });

  group('app schema', () {
    test('upgrading version 1 data converts every row', () async {
      final v1 = helperAt('app.db', []);
      final raw = await v1.database;
      for (final row in [
        {
          'id': 'a',
          'title': 'Lunch',
          'amount': 19.99,
          'category': 'Food',
          'type': 'expense',
          'date': '2026-09-13T12:00:00.000',
          'note': 'with team',
        },
        {
          'id': 'b',
          'title': ' ',
          'amount': 500.0,
          'category': 'Freelance',
          'type': 'income',
          'date': '2026-09-01T00:00:00.000',
          'note': null,
        },
        {
          'id': 'c',
          'title': 'Coffee',
          'amount': 3.5,
          'category': 'Coffee',
          'type': 'expense',
          'date': '2026-09-02T08:30:00.000',
          'note': null,
        },
      ]) {
        await raw.insert('transactions', row);
      }
      await v1.close();

      final current = helperAt('app.db');
      final byId = {for (final t in await current.fetchTransactions()) t.id: t};

      expect(await (await current.database).getVersion(), current.version);
      expect(byId['a']!.amount, const Money(19990));
      expect(byId['a']!.categoryId, 'cat-food');
      expect(byId['a']!.note, 'with team');
      expect(byId['b']!.title, isNull);
      expect(byId['b']!.categoryId, 'cat-business');
      expect(byId['c']!.amount, const Money(3500));
      expect(byId['c']!.categoryId, 'cat-other');
      expect({for (final t in byId.values) t.accountId}, {Account.cashId});
    });

    test(
      'a fresh install has the defaults and matches an upgraded install',
      () async {
        final old = helperAt('upgraded.db', []);
        await old.database;
        await old.close();
        final upgraded = helperAt('upgraded.db');
        final fresh = helperAt('fresh.db');

        final categories = await fresh.fetchCategories();
        expect(categories.where((c) => c.type == expense), hasLength(10));
        expect(
          categories.where((c) => c.type == TransactionType.income),
          hasLength(5),
        );
        expect((await fresh.fetchAccounts()).single.id, Account.cashId);
        expect(await fresh.fetchTransfers(), isEmpty);
        for (final table in [
          'transactions',
          'categories',
          'accounts',
          'transfers',
          'budgets',
          'recurring_rules',
          'recurring_occurrences',
          'notes',
        ]) {
          expect(await columns(fresh, table), await columns(upgraded, table));
        }
      },
    );

    test('soft-deleted rows move from the list to the trash', () async {
      final helper = helperAt('app.db');
      final lunch = testTx('a', expense, 12.5, DateTime(2026, 9, 13));
      await helper.insertTransaction(lunch);
      await helper.insertTransaction(
        testTx('b', expense, 3, DateTime(2026, 9, 12)),
      );
      await helper.updateTransaction(
        lunch.copyWith(deletedAt: DateTime.utc(2026, 9, 14)),
      );

      expect([for (final t in await helper.fetchTransactions()) t.id], ['b']);
      expect(
        [for (final t in await helper.fetchDeletedTransactions()) t.id],
        ['a'],
      );
    });

    test('purgeDeletedBefore removes only older trash (DEL-3)', () async {
      final helper = helperAt('app.db');
      await helper.insertTransaction(
        testTx('active', expense, 1, DateTime(2026, 9, 1)),
      );
      await helper.insertTransaction(
        testTx(
          'old',
          expense,
          1,
          DateTime(2026, 7, 1),
        ).copyWith(deletedAt: DateTime.utc(2026, 8, 1)),
      );
      await helper.insertTransaction(
        testTx(
          'recent',
          expense,
          1,
          DateTime(2026, 9, 1),
        ).copyWith(deletedAt: DateTime.utc(2026, 9, 10)),
      );
      await helper.insertTransfer(
        testTransfer(
          'old-transfer',
          Account.cashId,
          'bank',
          1,
          DateTime(2026, 7, 1),
        ).copyWith(deletedAt: DateTime.utc(2026, 8, 1)),
      );

      await helper.purgeDeletedBefore(DateTime.utc(2026, 9));

      expect(
        [for (final t in await helper.fetchDeletedTransactions()) t.id],
        ['recent'],
      );
      expect(
        [for (final t in await helper.fetchTransactions()) t.id],
        ['active'],
      );
      expect(await (await helper.database).query('transfers'), isEmpty);
    });

    test('categories can be added and updated', () async {
      final helper = helperAt('app.db');
      final coffee = Category(
        id: 'c1',
        type: expense,
        name: 'Coffee',
        icon: '☕',
        sortOrder: 10,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );

      await helper.insertCategory(coffee);
      await helper.updateCategories([
        coffee.copyWith(name: 'Café', archivedAt: DateTime.utc(2026, 9)),
      ]);

      final saved = (await helper.fetchCategories()).firstWhere(
        (c) => c.id == 'c1',
      );
      expect(saved.name, 'Café');
      expect(saved.archivedAt, DateTime.utc(2026, 9));
    });

    test('accounts can be added and updated', () async {
      final helper = helperAt('app.db');
      final bank = testAccount('bank', opening: 250);

      await helper.insertAccount(bank);
      await helper.updateAccounts([
        bank.copyWith(name: 'Savings', archivedAt: DateTime.utc(2026, 9)),
      ]);

      final saved = (await helper.fetchAccounts()).firstWhere(
        (a) => a.id == 'bank',
      );
      expect(
        (saved.name, saved.openingBalance, saved.archivedAt),
        ('Savings', const Money(250000), DateTime.utc(2026, 9)),
      );
    });

    test('transfers are saved, updated, and skipped once deleted', () async {
      final helper = helperAt('app.db');
      final transfer = testTransfer(
        't',
        Account.cashId,
        'bank',
        50,
        DateTime(2026, 9, 3),
      );
      await helper.insertTransfer(transfer);
      await helper.insertTransfer(
        testTransfer('u', 'bank', Account.cashId, 5, DateTime(2026, 9, 4)),
      );
      await helper.updateTransfer(
        transfer.copyWith(amount: const Money(60000)),
      );

      expect(
        [for (final t in await helper.fetchTransfers()) (t.id, t.amount)],
        [('u', const Money(5000)), ('t', const Money(60000))],
      );

      await helper.updateTransfer(
        transfer.copyWith(deletedAt: DateTime.utc(2026, 9, 5)),
      );
      expect([for (final t in await helper.fetchTransfers()) t.id], ['u']);
    });

    test('an import is written whole or not at all (IMP-1)', () async {
      final helper = helperAt('app.db');

      await helper.insertImported(
        transactions: [
          testTx('i1', expense, 12.5, DateTime(2026, 9, 1)),
          testTx('i2', expense, 3, DateTime(2026, 9, 2)),
        ],
        transfers: [
          testTransfer('i3', Account.cashId, 'bank', 5, DateTime(2026, 9, 3)),
        ],
      );

      expect(
        [for (final t in await helper.fetchTransactions()) t.id],
        ['i2', 'i1'],
      );
      expect([for (final t in await helper.fetchTransfers()) t.id], ['i3']);

      // The second row repeats i1's primary key, so the batch fails and the
      // first row of it isn't left behind either.
      await expectLater(
        helper.insertImported(
          transactions: [
            testTx('i4', expense, 1, DateTime(2026, 9, 4)),
            testTx('i1', expense, 1, DateTime(2026, 9, 5)),
          ],
          transfers: const [],
        ),
        throwsA(anything),
      );
      expect([
        for (final t in await helper.fetchTransactions()) t.id,
      ], isNot(contains('i4')));
    });

    test('recurring rules are updated and skipped once deleted', () async {
      final helper = helperAt('app.db');
      final rule = testRule('rent', 900, DateTime(2026, 9));
      await helper.insertRecurringRule(rule);

      await helper.updateRecurringRule(
        rule.copyWith(pausedAt: DateTime.utc(2026, 9, 5)),
      );
      expect(
        (await helper.fetchRecurringRules()).single.pausedAt,
        DateTime.utc(2026, 9, 5),
      );

      await helper.updateRecurringRule(
        rule.copyWith(deletedAt: DateTime.utc(2026, 9, 6)),
      );
      expect(await helper.fetchRecurringRules(), isEmpty);
    });

    test('notes are saved, updated, and purged from the trash', () async {
      final helper = helperAt('app.db');
      final note = testNote('n', 'Pay rent', dueDate: DateTime(2026, 9, 1));
      await helper.insertNote(note);

      await helper.updateNote(note.copyWith(doneAt: DateTime.utc(2026, 9, 2)));
      expect(
        (await helper.fetchNotes()).single.doneAt,
        DateTime.utc(2026, 9, 2),
      );

      await helper.updateNote(
        note.copyWith(deletedAt: DateTime.utc(2026, 8, 1)),
      );
      expect(await helper.fetchNotes(), isEmpty);

      await helper.purgeDeletedBefore(DateTime.utc(2026, 9));
      expect(await (await helper.database).query('notes'), isEmpty);
    });
  });
}
