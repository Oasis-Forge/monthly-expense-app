import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/models/transaction.dart';

void main() {
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

  DBHelper helperAt(String file, List<Migration> steps) {
    final helper = DBHelper(path: p.join(dir.path, file), migrations: steps);
    opened.add(helper);
    return helper;
  }

  Future<void> addCurrency(DatabaseExecutor db) => db.execute(
    "ALTER TABLE transactions ADD COLUMN currency TEXT NOT NULL DEFAULT 'USD'",
  );

  Future<void> addTags(DatabaseExecutor db) =>
      db.execute('CREATE TABLE tags (id TEXT PRIMARY KEY, name TEXT NOT NULL)');

  Future<List<String>> columns(DBHelper helper, String table) async {
    final db = await helper.database;
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return [for (final row in rows) row['name']! as String];
  }

  final lunch = ExpenseTransaction(
    id: 'a',
    title: 'Lunch',
    amount: 12.5,
    category: 'Food',
    type: TransactionType.expense,
    date: DateTime(2026, 9, 13),
  );

  test('version is 1 plus the number of steps', () {
    expect(DBHelper(migrations: []).version, 1);
    expect(DBHelper(migrations: [addCurrency, addTags]).version, 3);
  });

  test(
    'upgrading a version 1 database runs the steps and keeps data',
    () async {
      final v1 = helperAt('app.db', []);
      await v1.insertTransaction(lunch);
      await v1.close();

      final v3 = helperAt('app.db', [addCurrency, addTags]);
      final db = await v3.database;

      expect(await db.getVersion(), 3);
      expect(await columns(v3, 'transactions'), contains('currency'));
      expect(await columns(v3, 'tags'), ['id', 'name']);
      expect((await db.query('transactions')).single['currency'], 'USD');
      expect((await v3.fetchAllTransactions()).single.amount, 12.5);
    },
  );

  test(
    'upgrading from an intermediate version runs only newer steps',
    () async {
      final v2 = helperAt('app.db', [addCurrency]);
      await v2.insertTransaction(lunch);
      await v2.close();

      // Re-running addCurrency would fail with a duplicate column error.
      final v3 = helperAt('app.db', [addCurrency, addTags]);

      expect(await (await v3.database).getVersion(), 3);
      expect(await columns(v3, 'tags'), ['id', 'name']);
      expect(await v3.fetchAllTransactions(), hasLength(1));
    },
  );

  test('a fresh install matches an upgraded install', () async {
    final steps = [addCurrency, addTags];

    final old = helperAt('upgraded.db', []);
    await old.database;
    await old.close();
    final upgraded = helperAt('upgraded.db', steps);
    final fresh = helperAt('fresh.db', steps);

    expect(await (await fresh.database).getVersion(), 3);
    for (final table in ['transactions', 'tags']) {
      expect(await columns(fresh, table), await columns(upgraded, table));
    }
  });
}
