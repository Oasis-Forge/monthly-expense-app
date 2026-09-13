import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/recurring_rule.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import 'migrations.dart';

/// One schema step. It runs inside the transaction that opens the database.
typedef Migration = Future<void> Function(DatabaseExecutor db);

/// Thin wrapper around the local sqflite database.
class DBHelper {
  /// Opens the database at [path], or the app's database file when null.
  /// Tests pass `inMemoryDatabasePath`, and can pass their own [migrations].
  DBHelper({this.path, List<Migration>? migrations})
    : migrations = migrations ?? schemaMigrations;

  static final DBHelper instance = DBHelper();

  /// The app's schema steps, in order: step 1 upgrades version 1 to 2, and so
  /// on. To change the schema, append a step in `migrations.dart`. Never edit
  /// a merged step or the version 1 tables in [_createVersion1].
  static const List<Migration> schemaMigrations = [
    migrateToVersion2,
    migrateToVersion3,
    migrateToVersion4,
    migrateToVersion5,
    migrateToVersion6,
    migrateToVersion7,
  ];

  static const _fileName = 'monthly_expense_app.db';

  final String? path;
  final List<Migration> migrations;
  Database? _db;

  /// Version 1 plus one per migration step.
  int get version => migrations.length + 1;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<Database> _initDB() async {
    return openDatabase(
      path ?? await _defaultPath(),
      version: version,
      onCreate: (db, newVersion) async {
        await _createVersion1(db);
        await _migrate(db, from: 1, to: newVersion);
      },
      onUpgrade: (db, oldVersion, newVersion) =>
          _migrate(db, from: oldVersion, to: newVersion),
    );
  }

  /// On Windows and Linux the FFI factory's default folder is under the
  /// working directory, so keep the database in the per-user app support
  /// folder instead.
  static Future<String> _defaultPath() async {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return join((await getApplicationSupportDirectory()).path, _fileName);
    }
    return join(await getDatabasesPath(), _fileName);
  }

  /// The original schema. A fresh install creates it and then runs every
  /// step, so it ends up identical to an upgraded install.
  static Future<void> _createVersion1(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  Future<void> _migrate(
    DatabaseExecutor db, {
    required int from,
    required int to,
  }) async {
    for (var v = from; v < to; v++) {
      await migrations[v - 1](db);
    }
  }

  Future<void> insertTransaction(ExpenseTransaction tx) async {
    final db = await database;
    await db.insert(
      'transactions',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Saves every field of [tx], including `deleted_at` for soft deletes.
  Future<void> updateTransaction(ExpenseTransaction tx) async {
    final db = await database;
    await db.update(
      'transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  /// Transactions that aren't deleted, newest first.
  Future<List<ExpenseTransaction>> fetchTransactions() async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'deleted_at IS NULL',
      orderBy: 'date DESC',
    );
    return [for (final map in maps) ExpenseTransaction.fromMap(map)];
  }

  /// Transactions in the trash, most recently deleted first.
  Future<List<ExpenseTransaction>> fetchDeletedTransactions() async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'deleted_at IS NOT NULL',
      orderBy: 'deleted_at DESC',
    );
    return [for (final map in maps) ExpenseTransaction.fromMap(map)];
  }

  /// Permanently removes transactions and transfers deleted before [cutoff]
  /// (DEL-3).
  Future<void> purgeDeletedBefore(DateTime cutoff) async {
    final db = await database;
    for (final table in ['transactions', 'transfers']) {
      await db.delete(
        table,
        where: 'deleted_at IS NOT NULL AND deleted_at < ?',
        whereArgs: [cutoff.toUtc().toIso8601String()],
      );
    }
  }

  Future<List<Category>> fetchCategories() async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'deleted_at IS NULL',
      orderBy: 'type, sort_order',
    );
    return [for (final map in maps) Category.fromMap(map)];
  }

  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert('categories', category.toMap());
  }

  /// Saves every field of [categories] in one database transaction.
  Future<void> updateCategories(List<Category> categories) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final category in categories) {
        await txn.update(
          'categories',
          category.toMap(),
          where: 'id = ?',
          whereArgs: [category.id],
        );
      }
    });
  }

  Future<List<Account>> fetchAccounts() async {
    final db = await database;
    final maps = await db.query(
      'accounts',
      where: 'deleted_at IS NULL',
      orderBy: 'sort_order',
    );
    return [for (final map in maps) Account.fromMap(map)];
  }

  Future<void> insertAccount(Account account) async {
    final db = await database;
    await db.insert('accounts', account.toMap());
  }

  /// Saves every field of [accounts] in one database transaction.
  Future<void> updateAccounts(List<Account> accounts) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final account in accounts) {
        await txn.update(
          'accounts',
          account.toMap(),
          where: 'id = ?',
          whereArgs: [account.id],
        );
      }
    });
  }

  /// Transfers that aren't deleted, newest first.
  Future<List<Transfer>> fetchTransfers() async {
    final db = await database;
    final maps = await db.query(
      'transfers',
      where: 'deleted_at IS NULL',
      orderBy: 'date DESC',
    );
    return [for (final map in maps) Transfer.fromMap(map)];
  }

  Future<void> insertTransfer(Transfer transfer) async {
    final db = await database;
    await db.insert('transfers', transfer.toMap());
  }

  /// Saves every field of [transfer], including `deleted_at`.
  Future<void> updateTransfer(Transfer transfer) async {
    final db = await database;
    await db.update(
      'transfers',
      transfer.toMap(),
      where: 'id = ?',
      whereArgs: [transfer.id],
    );
  }

  /// Budget versions that aren't deleted.
  Future<List<Budget>> fetchBudgets() async {
    final db = await database;
    final maps = await db.query('budgets', where: 'deleted_at IS NULL');
    return [for (final map in maps) Budget.fromMap(map)];
  }

  Future<void> insertBudget(Budget budget) async {
    final db = await database;
    await db.insert('budgets', budget.toMap());
  }

  Future<void> updateBudget(Budget budget) async {
    final db = await database;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  /// Recurring rules that aren't deleted, oldest first.
  Future<List<RecurringRule>> fetchRecurringRules() async {
    final db = await database;
    final maps = await db.query(
      'recurring_rules',
      where: 'deleted_at IS NULL',
      orderBy: 'created_at',
    );
    return [for (final map in maps) RecurringRule.fromMap(map)];
  }

  Future<void> insertRecurringRule(RecurringRule rule) async {
    final db = await database;
    await db.insert('recurring_rules', rule.toMap());
  }

  /// Saves every field of [rule], including `deleted_at`.
  Future<void> updateRecurringRule(RecurringRule rule) async {
    final db = await database;
    await db.update(
      'recurring_rules',
      rule.toMap(),
      where: 'id = ?',
      whereArgs: [rule.id],
    );
  }

  Future<List<RecurringOccurrence>> fetchOccurrences() async {
    final db = await database;
    final maps = await db.query('recurring_occurrences');
    return [for (final map in maps) RecurringOccurrence.fromMap(map)];
  }

  /// Records a skipped occurrence. Recording the same one again is ignored.
  Future<void> insertOccurrence(RecurringOccurrence occurrence) async {
    final db = await database;
    await db.insert(
      'recurring_occurrences',
      occurrence.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Saves [tx] and its occurrence record together. If the occurrence was
  /// already handled, this throws and saves nothing (RCR-4).
  Future<void> postOccurrence(
    ExpenseTransaction tx,
    RecurringOccurrence occurrence,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'recurring_occurrences',
        occurrence.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await txn.insert('transactions', tx.toMap());
    });
  }
}
