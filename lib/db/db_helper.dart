import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction.dart';

/// One schema step. It runs inside the transaction that opens the database.
typedef Migration = Future<void> Function(DatabaseExecutor db);

/// Thin wrapper around a local sqflite database for storing transactions.
class DBHelper {
  /// Opens the database at [path], or the app's database file when null.
  /// Tests pass `inMemoryDatabasePath`, and can pass their own [migrations].
  DBHelper({this.path, List<Migration>? migrations})
    : migrations = migrations ?? schemaMigrations;

  static final DBHelper instance = DBHelper();

  /// The app's schema steps, in order: step 1 upgrades version 1 to 2, and so
  /// on. To change the schema, append a step. Never edit a merged step or the
  /// version 1 tables in [_createVersion1].
  static const List<Migration> schemaMigrations = [];

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
      path ?? join(await getDatabasesPath(), 'monthly_expense_app.db'),
      version: version,
      onCreate: (db, newVersion) async {
        await _createVersion1(db);
        await _migrate(db, from: 1, to: newVersion);
      },
      onUpgrade: (db, oldVersion, newVersion) =>
          _migrate(db, from: oldVersion, to: newVersion),
    );
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

  Future<void> updateTransaction(ExpenseTransaction tx) async {
    final db = await database;
    await db.update(
      'transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ExpenseTransaction>> fetchAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((m) => ExpenseTransaction.fromMap(m)).toList();
  }
}
