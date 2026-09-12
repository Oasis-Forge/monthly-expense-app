import 'package:flutter/foundation.dart';

import '../db/db_helper.dart';
import '../models/transaction.dart';

/// Holds all transactions in memory, persists them to sqflite, and exposes
/// derived data (monthly totals, category breakdowns) to the UI.
class TransactionProvider extends ChangeNotifier {
  final List<ExpenseTransaction> _transactions = [];
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<ExpenseTransaction> get transactions => List.unmodifiable(_transactions);
  DateTime get selectedMonth => _selectedMonth;

  Future<void> load() async {
    final loaded = await DBHelper.instance.fetchAllTransactions();
    _transactions
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void nextMonth() {
    setSelectedMonth(DateTime(_selectedMonth.year, _selectedMonth.month + 1));
  }

  void previousMonth() {
    setSelectedMonth(DateTime(_selectedMonth.year, _selectedMonth.month - 1));
  }

  Future<void> addTransaction(ExpenseTransaction tx) async {
    _transactions.insert(0, tx);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    await DBHelper.instance.insertTransaction(tx);
  }

  Future<void> updateTransaction(ExpenseTransaction tx) async {
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    if (index != -1) {
      _transactions[index] = tx;
      notifyListeners();
    }
    await DBHelper.instance.updateTransaction(tx);
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    await DBHelper.instance.deleteTransaction(id);
  }

  List<ExpenseTransaction> get transactionsForSelectedMonth {
    return _transactions
        .where(
          (t) =>
              t.date.year == _selectedMonth.year &&
              t.date.month == _selectedMonth.month,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double get monthlyIncome => transactionsForSelectedMonth
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthlyExpense => transactionsForSelectedMonth
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthlyBalance => monthlyIncome - monthlyExpense;

  /// Total expense amount grouped by category, for the selected month.
  Map<String, double> get expenseByCategory {
    final Map<String, double> result = {};
    for (final t in transactionsForSelectedMonth) {
      if (t.type == TransactionType.expense) {
        result[t.category] = (result[t.category] ?? 0) + t.amount;
      }
    }
    return result;
  }

  /// Transactions for the selected month, grouped by day (most recent first).
  Map<DateTime, List<ExpenseTransaction>> get groupedBySelectedDay {
    final Map<DateTime, List<ExpenseTransaction>> grouped = {};
    for (final t in transactionsForSelectedMonth) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      grouped.putIfAbsent(day, () => []).add(t);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: grouped[k]!};
  }
}
