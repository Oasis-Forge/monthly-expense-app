import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../db/db_helper.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/money.dart';
import '../models/period.dart';
import '../models/transaction.dart';

/// Holds transactions, categories, and accounts in memory, persists changes
/// through [DBHelper], and computes the selected period's totals and balances
/// (PER-1, BAL-1–BAL-5).
class TransactionProvider extends ChangeNotifier {
  /// Stores data in [db], or the app database when null. [clock] supplies
  /// "now"; tests pass a fixed time.
  TransactionProvider({DBHelper? db, DateTime Function()? clock})
    : _db = db ?? DBHelper.instance,
      _clock = clock ?? DateTime.now,
      _period = Period.containing((clock ?? DateTime.now)());

  final DBHelper _db;
  final DateTime Function() _clock;
  final List<ExpenseTransaction> _transactions = [];
  List<Category> _categories = const [];
  List<Account> _accounts = const [];
  int _startDay = 1;
  Period _period;
  _PeriodSummary? _summary;

  /// Transactions that aren't deleted, newest first.
  List<ExpenseTransaction> get transactions => List.unmodifiable(_transactions);
  List<Category> get categories => List.unmodifiable(_categories);
  List<Account> get accounts => List.unmodifiable(_accounts);
  Period get period => _period;
  int get startDay => _startDay;

  /// Categories of [type] that aren't archived, in display order.
  List<Category> categoriesFor(TransactionType type) => [
    for (final category in _categories)
      if (category.type == type && category.archivedAt == null) category,
  ];

  Category? categoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  /// Whether [tx] is dated after today, so it doesn't count yet (BAL-4).
  bool isUpcoming(ExpenseTransaction tx) => _dayOf(tx.date).isAfter(_today);

  DateTime get _today => _dayOf(_clock());

  Future<void> load() async {
    _categories = await _db.fetchCategories();
    _accounts = await _db.fetchAccounts();
    final loaded = await _db.fetchTransactions();
    _transactions
      ..clear()
      ..addAll(loaded)
      ..sort(_newestFirst);
    _changed();
  }

  /// Sets the first day of each month (PER-2) and shows the period that
  /// contains today.
  void setStartDay(int day) {
    _startDay = day;
    _period = Period.containing(_clock(), startDay: day);
    _changed();
  }

  void nextPeriod() {
    _period = _period.next;
    _changed();
  }

  void previousPeriod() {
    _period = _period.previous;
    _changed();
  }

  /// Saves [tx] with fresh timestamps (REC-1), then adds it to the list. If
  /// saving fails, the list is unchanged and the error is rethrown.
  Future<void> addTransaction(ExpenseTransaction tx) async {
    final now = _clock().toUtc();
    final stamped = tx.copyWith(createdAt: now, updatedAt: now);
    await _db.insertTransaction(stamped);
    _transactions
      ..add(stamped)
      ..sort(_newestFirst);
    _changed();
  }

  /// Saves [tx], then replaces the old version in the list. If saving fails,
  /// the list is unchanged and the error is rethrown.
  Future<void> updateTransaction(ExpenseTransaction tx) async {
    final stamped = tx.copyWith(updatedAt: _clock().toUtc());
    await _db.updateTransaction(stamped);
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    if (index != -1) {
      _transactions[index] = stamped;
      _transactions.sort(_newestFirst);
      _changed();
    }
  }

  /// Marks the transaction deleted in the database (DEL-1), then removes it
  /// from the list. If saving fails, the list is unchanged and the error is
  /// rethrown.
  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final now = _clock().toUtc();
    await _db.updateTransaction(
      _transactions[index].copyWith(deletedAt: now, updatedAt: now),
    );
    _transactions.removeWhere((t) => t.id == id);
    _changed();
  }

  /// Every transaction dated in the period, upcoming ones included, newest
  /// first.
  List<ExpenseTransaction> get periodTransactions => _current.transactions;

  /// [periodTransactions] grouped by day, newest day first.
  Map<DateTime, List<ExpenseTransaction>> get groupedByDay => _current.byDay;

  Money get periodIncome => _current.income;
  Money get periodExpense => _current.expense;

  /// Income minus expense in the period (BAL-1).
  Money get periodNet => _current.income - _current.expense;

  /// Opening balances plus every net before the period (BAL-2).
  Money get carriedForward => _current.carriedForward;

  /// Carried forward plus the period's net and opening balances (BAL-3).
  Money get closingBalance => _current.closingBalance;

  /// Expense per category ID in the period.
  Map<String, Money> get expenseByCategory => _current.expenseByCategory;

  void _changed() {
    _summary = null;
    notifyListeners();
  }

  _PeriodSummary get _current {
    final today = _today;
    final cached = _summary;
    if (cached != null && cached.today == today) return cached;
    return _summary = _PeriodSummary(_period, today, _transactions, _accounts);
  }

  static int _newestFirst(ExpenseTransaction a, ExpenseTransaction b) =>
      b.date.compareTo(a.date);
}

/// Totals for one period as of [today], computed once per change.
class _PeriodSummary {
  _PeriodSummary(
    Period period,
    this.today,
    List<ExpenseTransaction> newestFirst,
    List<Account> accounts,
  ) {
    var openingBefore = Money.zero;
    var openingDuring = Money.zero;
    for (final account in accounts) {
      if (account.openingDate.isBefore(period.start)) {
        openingBefore += account.openingBalance;
      } else if (period.contains(account.openingDate) &&
          !_dayOf(account.openingDate).isAfter(today)) {
        openingDuring += account.openingBalance;
      }
    }

    var netBefore = Money.zero;
    for (final tx in newestFirst) {
      final counts = !_dayOf(tx.date).isAfter(today);
      if (period.contains(tx.date)) {
        transactions.add(tx);
        byDay.putIfAbsent(_dayOf(tx.date), () => []).add(tx);
        if (!counts) continue;
        if (tx.type == TransactionType.income) {
          income += tx.amount;
        } else {
          expense += tx.amount;
          expenseByCategory[tx.categoryId] =
              (expenseByCategory[tx.categoryId] ?? Money.zero) + tx.amount;
        }
      } else if (counts && tx.date.isBefore(period.start)) {
        netBefore += tx.type == TransactionType.income ? tx.amount : -tx.amount;
      }
    }

    carriedForward = openingBefore + netBefore;
    closingBalance = carriedForward + openingDuring + income - expense;
  }

  final DateTime today;
  final List<ExpenseTransaction> transactions = [];
  final Map<DateTime, List<ExpenseTransaction>> byDay = {};
  final Map<String, Money> expenseByCategory = {};
  Money income = Money.zero;
  Money expense = Money.zero;
  late final Money carriedForward;
  late final Money closingBalance;
}

DateTime _dayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);
