import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/models/transaction.dart';

/// An in-memory [DBHelper] for tests that don't need sqflite. Set
/// [failWrites] to make every insert, update, and delete throw.
class FakeDB extends DBHelper {
  FakeDB([List<ExpenseTransaction> seed = const []]) : rows = [...seed];

  final List<ExpenseTransaction> rows;
  bool failWrites = false;

  void _checkWrite() {
    if (failWrites) throw StateError('write failed');
  }

  @override
  Future<List<ExpenseTransaction>> fetchAllTransactions() async => [...rows];

  @override
  Future<void> insertTransaction(ExpenseTransaction tx) async {
    _checkWrite();
    rows.add(tx);
  }

  @override
  Future<void> updateTransaction(ExpenseTransaction tx) async {
    _checkWrite();
    rows[rows.indexWhere((t) => t.id == tx.id)] = tx;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _checkWrite();
    rows.removeWhere((t) => t.id == id);
  }
}
