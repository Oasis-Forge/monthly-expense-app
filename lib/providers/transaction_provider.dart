import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:uuid/uuid.dart';

import '../db/db_helper.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/money.dart';
import '../models/period.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';

/// Holds transactions, transfers, categories, and accounts in memory, persists
/// changes through [DBHelper], and computes the selected period's totals and
/// balances (PER-1, BAL-1–BAL-5).
class TransactionProvider extends ChangeNotifier {
  /// Stores data in [db], or the app database when null. [clock] supplies
  /// "now"; tests pass a fixed time. [startDay] is the first day of each
  /// month (PER-2).
  TransactionProvider({
    DBHelper? db,
    DateTime Function()? clock,
    int startDay = 1,
  }) : _db = db ?? DBHelper.instance,
       _clock = clock ?? DateTime.now,
       _startDay = startDay,
       _period = Period.containing(
         (clock ?? DateTime.now)(),
         startDay: startDay,
       );

  /// How long deleted transactions stay in the trash (DEL-3).
  static const trashRetention = Duration(days: 30);

  final DBHelper _db;
  final DateTime Function() _clock;
  final List<ExpenseTransaction> _transactions = [];
  final List<ExpenseTransaction> _deleted = [];
  final List<Transfer> _transfers = [];

  /// Transfers deleted since loading, kept so Undo can restore them.
  final List<Transfer> _deletedTransfers = [];
  List<Category> _categories = const [];
  List<Account> _accounts = const [];
  int _startDay;
  Period _period;
  _PeriodSummary? _summary;

  /// Transactions that aren't deleted, newest first.
  List<ExpenseTransaction> get transactions => List.unmodifiable(_transactions);

  /// Transactions in the trash, most recently deleted first.
  List<ExpenseTransaction> get deletedTransactions =>
      List.unmodifiable(_deleted);

  /// Transfers that aren't deleted, newest first.
  List<Transfer> get transfers => List.unmodifiable(_transfers);

  List<Category> get categories => List.unmodifiable(_categories);

  /// Every account that isn't deleted, archived ones included.
  List<Account> get accounts => List.unmodifiable(_accounts);
  Period get period => _period;
  int get startDay => _startDay;

  /// Categories of [type] that aren't archived, in display order.
  List<Category> categoriesFor(TransactionType type) => [
    for (final category in _categories)
      if (category.type == type && category.archivedAt == null) category,
  ];

  /// Archived categories of [type] (CAT-4).
  List<Category> archivedCategoriesFor(TransactionType type) => [
    for (final category in _categories)
      if (category.type == type && category.archivedAt != null) category,
  ];

  Category? categoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  List<Account> get activeAccounts => [
    for (final account in _accounts)
      if (account.archivedAt == null) account,
  ];

  List<Account> get archivedAccounts => [
    for (final account in _accounts)
      if (account.archivedAt != null) account,
  ];

  Account? accountById(String id) {
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  /// Up to [limit] active categories of [type], most recently used first
  /// (ADD-5).
  List<Category> recentCategories(TransactionType type, {int limit = 5}) {
    final newestFirst = [
      for (final tx in _transactions)
        if (tx.type == type) tx,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recent = <Category>[];
    for (final tx in newestFirst) {
      final category = categoryById(tx.categoryId);
      if (category == null ||
          category.archivedAt != null ||
          recent.contains(category)) {
        continue;
      }
      recent.add(category);
      if (recent.length == limit) break;
    }
    return recent;
  }

  /// The last category used for [type], or its first active category (ADD-3).
  String? defaultCategoryId(TransactionType type) {
    final recent = recentCategories(type, limit: 1);
    if (recent.isNotEmpty) return recent.first.id;
    final options = categoriesFor(type);
    return options.isEmpty ? null : options.first.id;
  }

  /// The account of the most recently added transaction while it's active,
  /// or the first active account (ADD-3).
  String? defaultAccountId() {
    ExpenseTransaction? newest;
    for (final tx in _transactions) {
      if (newest == null || tx.createdAt.isAfter(newest.createdAt)) {
        newest = tx;
      }
    }
    final account = newest == null ? null : accountById(newest.accountId);
    if (account != null && account.archivedAt == null) return account.id;
    final active = activeAccounts;
    return active.isEmpty ? null : active.first.id;
  }

  /// Whether [date] is after today, so it doesn't count yet (BAL-4).
  bool isUpcomingDate(DateTime date) => _dayOf(date).isAfter(_today);

  bool isUpcoming(ExpenseTransaction tx) => isUpcomingDate(tx.date);

  /// Whole days before a trashed [tx] is deleted for good, at least 1.
  int trashDaysLeft(ExpenseTransaction tx) {
    final left =
        trashRetention.inDays - _clock().difference(tx.deletedAt!).inDays;
    return left < 1 ? 1 : left;
  }

  /// The account's balance today: its opening balance from the opening date,
  /// plus income, minus expense, minus transfers out, plus transfers in
  /// (ACC-4). Future-dated entries don't count yet (BAL-4).
  Money accountBalance(String id) {
    final account = accountById(id);
    var balance = account != null && !isUpcomingDate(account.openingDate)
        ? account.openingBalance
        : Money.zero;
    for (final tx in _transactions) {
      if (tx.accountId != id || isUpcomingDate(tx.date)) continue;
      balance += tx.type == TransactionType.income ? tx.amount : -tx.amount;
    }
    for (final transfer in _transfers) {
      if (isUpcomingDate(transfer.date)) continue;
      if (transfer.fromAccountId == id) balance -= transfer.amount;
      if (transfer.toAccountId == id) balance += transfer.amount;
    }
    return balance;
  }

  DateTime get _today => _dayOf(_clock());

  /// Purges old trash (DEL-3), then loads everything.
  Future<void> load() async {
    await _db.purgeDeletedBefore(_clock().subtract(trashRetention));
    _categories = await _db.fetchCategories();
    _accounts = await _db.fetchAccounts();
    final loaded = await _db.fetchTransactions();
    final deleted = await _db.fetchDeletedTransactions();
    final transfers = await _db.fetchTransfers();
    _transactions
      ..clear()
      ..addAll(loaded)
      ..sort(_newestFirst);
    _deleted
      ..clear()
      ..addAll(deleted);
    _transfers
      ..clear()
      ..addAll(transfers)
      ..sort(_newestTransferFirst);
    _deletedTransfers.clear();
    _changed();
  }

  /// Sets the first day of each month (PER-2) and shows the period that
  /// contains today.
  void setStartDay(int day) {
    if (day == _startDay) return;
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

  /// Moves the transaction to the trash (DEL-1). If saving fails, nothing
  /// changes and the error is rethrown.
  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final now = _clock().toUtc();
    final deleted = _transactions[index].copyWith(
      deletedAt: now,
      updatedAt: now,
    );
    await _db.updateTransaction(deleted);
    _transactions.removeWhere((t) => t.id == id);
    _deleted.insert(0, deleted);
    _changed();
  }

  /// Takes the transaction out of the trash with its original ID, date, and
  /// category (DEL-4). If saving fails, nothing changes and the error is
  /// rethrown.
  Future<void> restoreTransaction(String id) async {
    final index = _deleted.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final restored = _deleted[index].copyWith(
      deletedAt: null,
      updatedAt: _clock().toUtc(),
    );
    await _db.updateTransaction(restored);
    _deleted.removeWhere((t) => t.id == id);
    _transactions
      ..add(restored)
      ..sort(_newestFirst);
    _changed();
  }

  /// Saves a new transfer (ACC-3). Throws an [ArgumentError] when both sides
  /// are the same account.
  Future<void> addTransfer(Transfer transfer) async {
    _checkAccounts(transfer);
    final now = _clock().toUtc();
    final stamped = transfer.copyWith(createdAt: now, updatedAt: now);
    await _db.insertTransfer(stamped);
    _transfers
      ..add(stamped)
      ..sort(_newestTransferFirst);
    _changed();
  }

  /// Saves an edited transfer. Throws an [ArgumentError] when both sides are
  /// the same account.
  Future<void> updateTransfer(Transfer transfer) async {
    _checkAccounts(transfer);
    final stamped = transfer.copyWith(updatedAt: _clock().toUtc());
    await _db.updateTransfer(stamped);
    final index = _transfers.indexWhere((t) => t.id == transfer.id);
    if (index != -1) {
      _transfers[index] = stamped;
      _transfers.sort(_newestTransferFirst);
      _changed();
    }
  }

  /// Soft-deletes the transfer; [restoreTransfer] undoes it.
  Future<void> deleteTransfer(String id) async {
    final index = _transfers.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final now = _clock().toUtc();
    final deleted = _transfers[index].copyWith(deletedAt: now, updatedAt: now);
    await _db.updateTransfer(deleted);
    _transfers.removeWhere((t) => t.id == id);
    _deletedTransfers.insert(0, deleted);
    _changed();
  }

  Future<void> restoreTransfer(String id) async {
    final index = _deletedTransfers.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final restored = _deletedTransfers[index].copyWith(
      deletedAt: null,
      updatedAt: _clock().toUtc(),
    );
    await _db.updateTransfer(restored);
    _deletedTransfers.removeWhere((t) => t.id == id);
    _transfers
      ..add(restored)
      ..sort(_newestTransferFirst);
    _changed();
  }

  static void _checkAccounts(Transfer transfer) {
    if (transfer.fromAccountId == transfer.toAccountId) {
      throw ArgumentError('A transfer needs two different accounts.');
    }
  }

  /// Adds an account after the existing ones (ACC-1).
  Future<Account> addAccount({
    required String name,
    required AccountType type,
    required Money openingBalance,
    required DateTime openingDate,
  }) async {
    final now = _clock().toUtc();
    var sortOrder = 0;
    for (final account in _accounts) {
      if (account.sortOrder >= sortOrder) sortOrder = account.sortOrder + 1;
    }
    final account = Account(
      id: const Uuid().v4(),
      type: type,
      name: name,
      openingBalance: openingBalance,
      openingDate: openingDate,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertAccount(account);
    _accounts = [..._accounts, account];
    _changed();
    return account;
  }

  Future<void> updateAccount(Account account) => _saveAccounts([account]);

  /// Archives an account (ACC-5). Throws a [StateError] for the last active
  /// account.
  Future<void> archiveAccount(String id) async {
    if (activeAccounts.length <= 1) {
      throw StateError('Keep at least one active account.');
    }
    await _saveAccounts([
      accountById(id)!.copyWith(archivedAt: _clock().toUtc()),
    ]);
  }

  Future<void> unarchiveAccount(String id) =>
      _saveAccounts([accountById(id)!.copyWith(archivedAt: null)]);

  /// Whether any transaction or transfer, deleted ones included, uses the
  /// account.
  bool isAccountUsed(String id) =>
      _transactions.any((t) => t.accountId == id) ||
      _deleted.any((t) => t.accountId == id) ||
      [
        ..._transfers,
        ..._deletedTransfers,
      ].any((t) => t.fromAccountId == id || t.toAccountId == id);

  /// Deletes an unused account. An account with history can only be
  /// archived (ACC-5), and one active account must remain; otherwise this
  /// throws a [StateError].
  Future<void> deleteAccount(String id) async {
    final account = accountById(id)!;
    if (isAccountUsed(id)) {
      throw StateError('Account $id has history; archive it instead.');
    }
    if (account.archivedAt == null && activeAccounts.length <= 1) {
      throw StateError('Keep at least one active account.');
    }
    await _saveAccounts([account.copyWith(deletedAt: _clock().toUtc())]);
  }

  Future<void> _saveAccounts(List<Account> changed) async {
    final now = _clock().toUtc();
    final stamped = {
      for (final account in changed)
        account.id: account.copyWith(updatedAt: now),
    };
    await _db.updateAccounts(stamped.values.toList());
    _accounts = [
      for (final account in _accounts)
        if (stamped[account.id]?.deletedAt == null)
          stamped[account.id] ?? account,
    ];
    _changed();
  }

  /// Adds a custom category at the end of its type's list (CAT-3).
  Future<Category> addCategory({
    required TransactionType type,
    required String name,
    required String icon,
  }) async {
    final now = _clock().toUtc();
    var sortOrder = 0;
    for (final category in _categories) {
      if (category.type == type && category.sortOrder >= sortOrder) {
        sortOrder = category.sortOrder + 1;
      }
    }
    final category = Category(
      id: const Uuid().v4(),
      type: type,
      name: name,
      icon: icon,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertCategory(category);
    _categories = [..._categories, category]..sort(_byTypeAndOrder);
    _changed();
    return category;
  }

  /// Saves a renamed or re-iconed category (CAT-3).
  Future<void> updateCategory(Category category) => _saveCategories([category]);

  Future<void> archiveCategory(String id) => _saveCategories([
    categoryById(id)!.copyWith(archivedAt: _clock().toUtc()),
  ]);

  Future<void> unarchiveCategory(String id) =>
      _saveCategories([categoryById(id)!.copyWith(archivedAt: null)]);

  /// Whether any transaction, trashed ones included, uses the category.
  bool isCategoryUsed(String id) =>
      _transactions.any((t) => t.categoryId == id) ||
      _deleted.any((t) => t.categoryId == id);

  /// Deletes an unused category. A used category can only be archived
  /// (CAT-4), so this throws a [StateError] for one.
  Future<void> deleteCategory(String id) async {
    if (isCategoryUsed(id)) {
      throw StateError('Category $id has transactions; archive it instead.');
    }
    await _saveCategories([
      categoryById(id)!.copyWith(deletedAt: _clock().toUtc()),
    ]);
  }

  /// Moves the active category at [oldIndex] of [type] to [newIndex], both
  /// positions in [categoriesFor] (CAT-3).
  Future<void> reorderCategories(
    TransactionType type,
    int oldIndex,
    int newIndex,
  ) {
    final ordered = categoriesFor(type);
    ordered.insert(newIndex, ordered.removeAt(oldIndex));
    return _saveCategories([
      for (var i = 0; i < ordered.length; i++)
        if (ordered[i].sortOrder != i) ordered[i].copyWith(sortOrder: i),
    ]);
  }

  /// Stamps and saves [changed] categories, then updates the list. Deleted
  /// categories leave the list.
  Future<void> _saveCategories(List<Category> changed) async {
    if (changed.isEmpty) return;
    final now = _clock().toUtc();
    final stamped = {
      for (final category in changed)
        category.id: category.copyWith(updatedAt: now),
    };
    await _db.updateCategories(stamped.values.toList());
    _categories = [
      for (final category in _categories)
        if (stamped[category.id]?.deletedAt == null)
          stamped[category.id] ?? category,
    ]..sort(_byTypeAndOrder);
    _changed();
  }

  /// Every transaction dated in the period, upcoming ones included, newest
  /// first.
  List<ExpenseTransaction> get periodTransactions => _current.transactions;

  /// [periodTransactions] grouped by day, newest day first.
  Map<DateTime, List<ExpenseTransaction>> get groupedByDay => _current.byDay;

  /// Transfers dated in the period, newest first. They never count as income
  /// or expense (BAL-1).
  List<Transfer> get periodTransfers => _current.transfers;

  /// [periodTransfers] grouped by day, newest day first.
  Map<DateTime, List<Transfer>> get transfersByDay => _current.transfersByDay;

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
    return _summary = _PeriodSummary(
      _period,
      today,
      _transactions,
      _transfers,
      _accounts,
    );
  }

  static int _newestFirst(ExpenseTransaction a, ExpenseTransaction b) =>
      b.date.compareTo(a.date);

  static int _newestTransferFirst(Transfer a, Transfer b) =>
      b.date.compareTo(a.date);

  static int _byTypeAndOrder(Category a, Category b) {
    final byType = a.type.index.compareTo(b.type.index);
    return byType != 0 ? byType : a.sortOrder.compareTo(b.sortOrder);
  }
}

/// Totals for one period as of [today], computed once per change.
class _PeriodSummary {
  _PeriodSummary(
    Period period,
    this.today,
    List<ExpenseTransaction> newestFirst,
    List<Transfer> newestTransfersFirst,
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

    for (final transfer in newestTransfersFirst) {
      if (period.contains(transfer.date)) {
        transfers.add(transfer);
        transfersByDay
            .putIfAbsent(_dayOf(transfer.date), () => [])
            .add(transfer);
      }
    }

    carriedForward = openingBefore + netBefore;
    closingBalance = carriedForward + openingDuring + income - expense;
  }

  final DateTime today;
  final List<ExpenseTransaction> transactions = [];
  final Map<DateTime, List<ExpenseTransaction>> byDay = {};
  final List<Transfer> transfers = [];
  final Map<DateTime, List<Transfer>> transfersByDay = {};
  final Map<String, Money> expenseByCategory = {};
  Money income = Money.zero;
  Money expense = Money.zero;
  late final Money carriedForward;
  late final Money closingBalance;
}

DateTime _dayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);
