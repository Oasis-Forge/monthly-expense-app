import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction.dart';

/// Thin wrapper around a local sqflite database for storing transactions.
class DBHelper {
  /// Opens the database at [path], or the app's database file when null.
  /// Tests pass `inMemoryDatabasePath`.
  DBHelper({this.path});

  static final DBHelper instance = DBHelper();

  final String? path;
  Database? _db;

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
      version: 1,
      onCreate: (db, version) async {
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
      },
    );
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
