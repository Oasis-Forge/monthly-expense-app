import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/widgets.dart' show Locale;
import 'package:uuid/uuid.dart';

import '../db/db_helper.dart';
import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/insights.dart';
import '../models/money.dart';
import '../models/note.dart';
import '../models/period.dart';
import '../models/recurring_rule.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../models/transfer.dart';
import '../models/widget_summary.dart';
import '../services/reminder_service.dart';

/// Holds the app's data in memory, persists changes through [DBHelper], and
/// computes the selected period's totals, balances, and budgets (PER-1,
/// BAL-1–BAL-5, BUD-1–BUD-6). It also posts recurring transactions
/// (RCR-1–RCR-7) and answers searches (SRCH-1–SRCH-3).
class TransactionProvider extends ChangeNotifier {
  /// Stores data in [db], or the app database when null. [clock] supplies
  /// "now"; tests pass a fixed time. [startDay] is the first day of each
  /// month (PER-2). [reminders] schedules note notifications; `main.dart`
  /// passes a [DeviceReminderService] and everyone else does nothing.
  TransactionProvider({
    DBHelper? db,
    DateTime Function()? clock,
    int startDay = 1,
    ReminderService? reminders,
  }) : _db = db ?? DBHelper.instance,
       _clock = clock ?? DateTime.now,
       _startDay = startDay,
       _reminders = reminders ?? const NoopReminderService(),
       _period = Period.containing(
         (clock ?? DateTime.now)(),
         startDay: startDay,
       );

  /// How long deleted transactions stay in the trash (DEL-3).
  static const trashRetention = Duration(days: 30);

  /// How far ahead the upcoming list looks (RCR-7).
  static const upcomingDays = 30;

  final DBHelper _db;
  final DateTime Function() _clock;
  final ReminderService _reminders;
  final List<ExpenseTransaction> _transactions = [];
  final List<ExpenseTransaction> _deleted = [];
  final List<Transfer> _transfers = [];

  /// Transfers deleted since loading, kept so Undo can restore them.
  final List<Transfer> _deletedTransfers = [];
  List<Category> _categories = const [];
  List<Account> _accounts = const [];
  List<Budget> _budgets = const [];
  List<RecurringRule> _rules = const [];
  List<Note> _notes = [];

  /// Notes deleted since loading, kept so Undo can restore them.
  final List<Note> _deletedNotes = [];

  /// Notes reopened by deleting the transaction they were recorded as, keyed
  /// by that transaction's ID and holding when the note had been done, so
  /// undoing the delete links them again (NOTE-4, DEL-2).
  final Map<String, ({String noteId, DateTime doneAt})> _reopenedNotes = {};

  /// The app lock and language the last [rescheduleReminders] ran with, for
  /// re-arming a reminder away from a screen that could pass its own.
  bool _appLockOn = false;
  Locale _locale = const Locale('en');

  /// Handled occurrences by [RecurringOccurrence.key].
  final Map<String, RecurringOccurrence> _occurrences = {};
  int _startDay;
  Period _period;
  _PeriodSummary? _summary;
  bool _loaded = false;

  /// Whether [load] has finished at least once.
  bool get isLoaded => _loaded;

  /// Transactions that aren't deleted, newest first.
  List<ExpenseTransaction> get transactions => List.unmodifiable(_transactions);

  /// The active transaction with [id], or null (also for one in the trash).
  ExpenseTransaction? transactionById(String id) {
    for (final tx in _transactions) {
      if (tx.id == id) return tx;
    }
    return null;
  }

  /// Transactions in the trash, most recently deleted first.
  List<ExpenseTransaction> get deletedTransactions =>
      List.unmodifiable(_deleted);

  /// Transfers that aren't deleted, newest first.
  List<Transfer> get transfers => List.unmodifiable(_transfers);

  List<Category> get categories => List.unmodifiable(_categories);

  /// Every account that isn't deleted, archived ones included.
  List<Account> get accounts => List.unmodifiable(_accounts);

  /// Recurring rules that aren't deleted, oldest first.
  List<RecurringRule> get recurringRules => List.unmodifiable(_rules);

  /// The period shown on Home and Stats.
  Period get period => _period;

  /// The period that contains today; budget changes apply from it (BUD-5).
  Period get currentPeriod => Period.containing(_clock(), startDay: _startDay);
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

  RecurringRule? recurringRuleById(String id) {
    for (final rule in _rules) {
      if (rule.id == id) return rule;
    }
    return null;
  }

  /// Every note that isn't deleted, open and done alike.
  List<Note> get notes => List.unmodifiable(_notes);

  Note? noteById(String id) {
    for (final note in _notes) {
      if (note.id == id) return note;
    }
    return null;
  }

  /// Open notes, overdue first (earliest due date first), then by due date,
  /// then dateless notes by last edit (NOTE-2).
  List<Note> get openNotes {
    final today = _today;
    int bucket(Note note) {
      final due = note.dueDate;
      if (due == null) return 2;
      return _dayOf(due).isBefore(today) ? 0 : 1;
    }

    final open =
        [
          for (final note in _notes)
            if (!note.isDone) note,
        ]..sort((a, b) {
          final bucketA = bucket(a);
          final bucketB = bucket(b);
          if (bucketA != bucketB) return bucketA.compareTo(bucketB);
          return bucketA == 2
              ? b.updatedAt.compareTo(a.updatedAt)
              : a.dueDate!.compareTo(b.dueDate!);
        });
    return open;
  }

  /// Done notes, most recently done first.
  List<Note> get doneNotes {
    final done = [
      for (final note in _notes)
        if (note.isDone) note,
    ]..sort((a, b) => b.doneAt!.compareTo(a.doneAt!));
    return done;
  }

  /// Open notes due in the selected period, for the Home notice (NOTE-5).
  List<Note> get notesDueInPeriod => [
    for (final note in _notes)
      if (!note.isDone &&
          note.dueDate != null &&
          _period.contains(note.dueDate!))
        note,
  ];

  /// Open notes due on [day], for the Insights calendar (NOTE-5, INS-1).
  List<Note> notesDueOn(DateTime day) {
    final target = _dayOf(day);
    return [
      for (final note in _notes)
        if (!note.isDone &&
            note.dueDate != null &&
            _dayOf(note.dueDate!) == target)
          note,
    ];
  }

  /// The note recorded as [transactionId], if any (NOTE-4).
  Note? noteForTransaction(String transactionId) {
    for (final note in _notes) {
      if (note.transactionId == transactionId) return note;
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

  /// Purges old trash (DEL-3), loads everything, and posts due occurrences of
  /// automatic recurring rules (RCR-4).
  /// [appLockOn] and [locale] shape reminder notifications rescheduled for
  /// open notes (NOTE-6): after a reboot clears the OS alarms, or a restore
  /// changes which notes are open, the next launch resyncs them.
  Future<void> load({
    bool appLockOn = false,
    Locale locale = const Locale('en'),
  }) async {
    await _db.purgeDeletedBefore(_clock().subtract(trashRetention));
    _categories = await _db.fetchCategories();
    _accounts = await _db.fetchAccounts();
    _budgets = await _db.fetchBudgets();
    _rules = await _db.fetchRecurringRules();
    _notes = await _db.fetchNotes();
    final occurrences = await _db.fetchOccurrences();
    final loaded = await _db.fetchTransactions();
    final deleted = await _db.fetchDeletedTransactions();
    final transfers = await _db.fetchTransfers();
    _occurrences
      ..clear()
      ..addEntries([for (final o in occurrences) MapEntry(o.key, o)]);
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
    _deletedNotes.clear();
    _reopenedNotes.clear();
    await _postAutomaticOccurrences();
    await rescheduleReminders(appLockOn: appLockOn, locale: locale);
    _loaded = true;
    _changed();
  }

  /// Re-schedules every open note's reminder (NOTE-6). Settings calls this
  /// after a change to app lock or the app's language, so notifications
  /// already scheduled pick up the new [appLockOn] and [locale] instead of
  /// waiting for the next launch (LOCK-2).
  Future<void> rescheduleReminders({
    required bool appLockOn,
    required Locale locale,
  }) async {
    _appLockOn = appLockOn;
    _locale = locale;
    for (final note in _notes) {
      await _reminders.schedule(note, appLockOn: appLockOn, locale: locale);
    }
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
    await _reopenNoteFor(id);
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
    await _relinkNoteFor(id);
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

  // Notes (NOTE-1–NOTE-8).

  /// Saves a new note (NOTE-1) and schedules its reminder, if any (NOTE-6).
  Future<void> addNote(
    Note note, {
    required bool appLockOn,
    required Locale locale,
  }) async {
    final now = _clock().toUtc();
    final stamped = note.copyWith(createdAt: now, updatedAt: now);
    await _db.insertNote(stamped);
    _notes = [..._notes, stamped];
    await _reminders.schedule(stamped, appLockOn: appLockOn, locale: locale);
    _changed();
  }

  /// Saves an edited note and reschedules its reminder.
  Future<void> updateNote(
    Note note, {
    required bool appLockOn,
    required Locale locale,
  }) async {
    final stamped = note.copyWith(updatedAt: _clock().toUtc());
    await _db.updateNote(stamped);
    _notes = [
      for (final existing in _notes)
        if (existing.id == note.id) stamped else existing,
    ];
    await _reminders.schedule(stamped, appLockOn: appLockOn, locale: locale);
    _changed();
  }

  /// Marks the note done, or open again.
  Future<void> setNoteDone(
    String id,
    bool done, {
    required bool appLockOn,
    required Locale locale,
  }) => updateNote(
    noteById(id)!.copyWith(doneAt: done ? _clock().toUtc() : null),
    appLockOn: appLockOn,
    locale: locale,
  );

  /// Marks the note done and links it to the transaction recorded from it;
  /// each shows the other (NOTE-4).
  Future<void> recordNote(
    String id,
    String transactionId, {
    required bool appLockOn,
    required Locale locale,
  }) => updateNote(
    noteById(id)!
        .copyWith(transactionId: transactionId, doneAt: _clock().toUtc()),
    appLockOn: appLockOn,
    locale: locale,
  );

  /// Moves the note to the trash and cancels its reminder (DEL-1, NOTE-7);
  /// [restoreNote] undoes both.
  Future<void> deleteNote(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;
    final now = _clock().toUtc();
    final deleted = _notes[index].copyWith(deletedAt: now, updatedAt: now);
    await _db.updateNote(deleted);
    await _reminders.cancel(deleted);
    _notes.removeWhere((n) => n.id == id);
    _deletedNotes.insert(0, deleted);
    _changed();
  }

  Future<void> restoreNote(
    String id, {
    required bool appLockOn,
    required Locale locale,
  }) async {
    final index = _deletedNotes.indexWhere((n) => n.id == id);
    if (index == -1) return;
    final restored = _deletedNotes[index].copyWith(
      deletedAt: null,
      updatedAt: _clock().toUtc(),
    );
    await _db.updateNote(restored);
    _deletedNotes.removeWhere((n) => n.id == id);
    _notes = [..._notes, restored];
    await _reminders.schedule(restored, appLockOn: appLockOn, locale: locale);
    _changed();
  }

  /// Reopens the note recorded as [transactionId], if any, and re-arms its
  /// reminder for a due date still ahead (NOTE-4). [_relinkNoteFor] puts both
  /// back when the delete is undone.
  Future<void> _reopenNoteFor(String transactionId) async {
    final note = noteForTransaction(transactionId);
    if (note == null) return;
    final now = _clock().toUtc();
    _reopenedNotes[transactionId] = (
      noteId: note.id,
      doneAt: note.doneAt ?? now,
    );
    final reopened = note.copyWith(
      transactionId: null,
      doneAt: null,
      updatedAt: now,
    );
    await _db.updateNote(reopened);
    _notes = [
      for (final existing in _notes)
        if (existing.id == note.id) reopened else existing,
    ];
    await _reminders.schedule(reopened, appLockOn: _appLockOn, locale: _locale);
  }

  /// Marks the note that deleting [transactionId] reopened done and linked
  /// again, so undoing that delete undoes both halves (NOTE-4). Its reminder
  /// goes back off, since the note is done. Any edit made in between stays.
  Future<void> _relinkNoteFor(String transactionId) async {
    final reopened = _reopenedNotes.remove(transactionId);
    if (reopened == null) return;
    final note = noteById(reopened.noteId);
    if (note == null) return;
    final relinked = note.copyWith(
      transactionId: transactionId,
      doneAt: reopened.doneAt,
      updatedAt: _clock().toUtc(),
    );
    await _db.updateNote(relinked);
    _notes = [
      for (final existing in _notes)
        if (existing.id == note.id) relinked else existing,
    ];
    await _reminders.cancel(relinked);
  }

  // Search (SRCH-1–SRCH-3).

  /// Transactions matching [filter], newest first. Text matches the title,
  /// note, [categoryName], [accountName], or an equal amount, ignoring case
  /// and accents.
  SearchResult search(
    TransactionFilter filter, {
    required String Function(Category category) categoryName,
    required String Function(Account account) accountName,
  }) {
    final query = foldForSearch(filter.query.trim());
    final queryAmount = Money.tryParse(filter.query);
    final from = filter.from == null ? null : _dayOf(filter.from!);
    final to = filter.to == null ? null : _dayOf(filter.to!);

    bool matchesText(ExpenseTransaction tx) {
      if (query.isEmpty || tx.amount == queryAmount) return true;
      final category = categoryById(tx.categoryId);
      final account = accountById(tx.accountId);
      return [
        tx.title,
        tx.note,
        if (category != null) categoryName(category),
        if (account != null) accountName(account),
      ].any((text) => text != null && foldForSearch(text).contains(query));
    }

    final matches = <ExpenseTransaction>[];
    var income = Money.zero;
    var expense = Money.zero;
    for (final tx in _transactions) {
      final day = _dayOf(tx.date);
      if ((filter.type != null && tx.type != filter.type) ||
          (filter.categoryId != null && tx.categoryId != filter.categoryId) ||
          (filter.accountId != null && tx.accountId != filter.accountId) ||
          (from != null && day.isBefore(from)) ||
          (to != null && day.isAfter(to)) ||
          !matchesText(tx)) {
        continue;
      }
      matches.add(tx);
      if (isUpcoming(tx)) continue;
      if (tx.type == TransactionType.income) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    return SearchResult(matches, income, expense);
  }

  // Budgets (BUD-1–BUD-6).

  /// The limit for [categoryId] (null for the overall budget) during
  /// [period], or the selected period (BUD-5).
  Money? budgetLimit(String? categoryId, [Period? period]) =>
      limitFor(_budgets, categoryId, period ?? _period);

  /// Sets a budget, or removes it with a null [limit], from the current
  /// period onward; earlier periods keep their limits (BUD-5).
  Future<void> setBudget(String? categoryId, Money? limit) async {
    final from = currentPeriod.start;
    final now = _clock().toUtc();
    Budget? existing;
    for (final budget in _budgets) {
      if (budget.categoryId == categoryId && budget.effectiveFrom == from) {
        existing = budget;
      }
    }

    if (existing != null) {
      final updated = existing.copyWith(limit: limit, updatedAt: now);
      await _db.updateBudget(updated);
      _budgets = [
        for (final budget in _budgets)
          budget.id == updated.id ? updated : budget,
      ];
    } else {
      if (limit == null && budgetLimit(categoryId, currentPeriod) == null) {
        return;
      }
      final budget = Budget(
        id: const Uuid().v4(),
        categoryId: categoryId,
        limit: limit,
        effectiveFrom: from,
        createdAt: now,
        updatedAt: now,
      );
      await _db.insertBudget(budget);
      _budgets = [..._budgets, budget];
    }
    _changed();
  }

  /// Progress of every budget in the selected period: the overall budget
  /// first, then categories in display order (BUD-2–BUD-6).
  List<BudgetStatus> get budgetStatuses {
    final today = _today;
    final timing = _period.timingOn(today);
    final daysLeft = timing == PeriodTiming.current
        ? DateTime.utc(
            _period.end.year,
            _period.end.month,
            _period.end.day,
          ).difference(DateTime.utc(today.year, today.month, today.day)).inDays
        : 0;

    BudgetStatus? statusFor(String? categoryId, Money spent) {
      final limit = budgetLimit(categoryId);
      if (limit == null) return null;
      return BudgetStatus(
        categoryId: categoryId,
        limit: limit,
        spent: spent,
        timing: timing,
        daysLeft: daysLeft,
      );
    }

    final byCategory = expenseByCategory;
    return [
      ?statusFor(null, periodExpense),
      for (final category in [
        ...categoriesFor(TransactionType.expense),
        ...archivedCategoriesFor(TransactionType.expense),
      ])
        ?statusFor(category.id, byCategory[category.id] ?? Money.zero),
    ];
  }

  /// How many budgets are at or over their limit in the selected period.
  int get budgetsOver =>
      budgetStatuses.where((status) => status.level == BudgetLevel.over).length;

  // Recurring transactions (RCR-1–RCR-7).

  /// Occurrences of rules that wait for a tap, dated today or earlier and not
  /// posted or skipped yet, oldest first (RCR-2).
  List<ScheduledOccurrence> get dueOccurrences =>
      _scheduled(to: _today, autoPost: false);

  /// Occurrences in the next [upcomingDays] days, after today (RCR-7).
  List<ScheduledOccurrence> get upcomingOccurrences {
    final today = _today;
    return _scheduled(
      from: DateTime(today.year, today.month, today.day + 1),
      to: DateTime(today.year, today.month, today.day + upcomingDays),
    );
  }

  List<ScheduledOccurrence> _scheduled({
    DateTime? from,
    required DateTime to,
    bool? autoPost,
  }) {
    final scheduled = <ScheduledOccurrence>[];
    for (final rule in _rules) {
      if (rule.isPaused || (autoPost != null && rule.autoPost != autoPost)) {
        continue;
      }
      for (final date in rule.occurrencesBetween(from ?? rule.activeFrom, to)) {
        if (!_occurrences.containsKey(occurrenceKey(rule.id, date))) {
          scheduled.add(ScheduledOccurrence(rule, date));
        }
      }
    }
    return scheduled..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Posts [occurrence] as a transaction, with an edited [amount] if given
  /// (RCR-2). If saving fails, nothing changes and the error is rethrown.
  Future<void> postOccurrence(
    ScheduledOccurrence occurrence, {
    Money? amount,
  }) async {
    await _post(occurrence, amount ?? occurrence.rule.amount);
    _changed();
  }

  /// Skips [occurrence]; it won't come due again.
  Future<void> skipOccurrence(ScheduledOccurrence occurrence) async {
    final record = RecurringOccurrence(
      ruleId: occurrence.rule.id,
      date: occurrence.date,
      status: OccurrenceStatus.skipped,
      createdAt: _clock().toUtc(),
    );
    await _db.insertOccurrence(record);
    _occurrences[record.key] = record;
    _changed();
  }

  /// Saves a new rule; automatic rules post what's already due.
  Future<void> addRecurringRule(RecurringRule rule) async {
    final now = _clock().toUtc();
    final stamped = rule.copyWith(
      activeFrom: rule.startDate,
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertRecurringRule(stamped);
    _rules = [..._rules, stamped];
    await _postAutomaticOccurrences();
    _changed();
  }

  /// Saves an edited rule. The change applies from today onward: posted
  /// transactions stay as they are, and earlier occurrences that weren't
  /// handled are dropped (RCR-5).
  Future<void> updateRecurringRule(RecurringRule rule) async {
    final today = _today;
    await _saveRule(
      rule.copyWith(
        activeFrom: rule.startDate.isAfter(today) ? rule.startDate : today,
        updatedAt: _clock().toUtc(),
      ),
    );
    await _postAutomaticOccurrences();
    _changed();
  }

  Future<void> pauseRecurringRule(String id) async {
    final now = _clock().toUtc();
    await _saveRule(
      recurringRuleById(id)!.copyWith(pausedAt: now, updatedAt: now),
    );
    _changed();
  }

  /// Resumes a rule. Occurrences that came due while it was paused are
  /// skipped, not caught up (RCR-6).
  Future<void> resumeRecurringRule(String id) async {
    final rule = recurringRuleById(id)!;
    final today = _today;
    await _saveRule(
      rule.copyWith(
        pausedAt: null,
        activeFrom: rule.activeFrom.isAfter(today) ? rule.activeFrom : today,
        updatedAt: _clock().toUtc(),
      ),
    );
    await _postAutomaticOccurrences();
    _changed();
  }

  /// Deletes a rule; the transactions it posted stay (RCR-5).
  Future<void> deleteRecurringRule(String id) async {
    final now = _clock().toUtc();
    await _saveRule(
      recurringRuleById(id)!.copyWith(deletedAt: now, updatedAt: now),
    );
    _changed();
  }

  Future<void> _saveRule(RecurringRule rule) async {
    await _db.updateRecurringRule(rule);
    _rules = [
      for (final existing in _rules)
        if (existing.id != rule.id)
          existing
        else if (rule.deletedAt == null)
          rule,
    ];
  }

  /// Posts every due occurrence of automatic rules, exactly once (RCR-4).
  Future<void> _postAutomaticOccurrences() async {
    for (final occurrence in _scheduled(to: _today, autoPost: true)) {
      await _post(occurrence, occurrence.rule.amount);
    }
  }

  Future<void> _post(ScheduledOccurrence occurrence, Money amount) async {
    final rule = occurrence.rule;
    final now = _clock().toUtc();
    final tx = ExpenseTransaction(
      id: const Uuid().v4(),
      title: rule.title,
      amount: amount,
      categoryId: rule.categoryId,
      accountId: rule.accountId,
      type: rule.type,
      date: occurrence.date,
      note: rule.note,
      createdAt: now,
      updatedAt: now,
    );
    final record = RecurringOccurrence(
      ruleId: rule.id,
      date: occurrence.date,
      status: OccurrenceStatus.posted,
      transactionId: tx.id,
      createdAt: now,
    );
    await _db.postOccurrence(tx, record);
    _occurrences[record.key] = record;
    _transactions
      ..add(tx)
      ..sort(_newestFirst);
  }

  // The selected period (PER-1, BAL-1–BAL-5).

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

  /// Income per category ID in the period (INS-3).
  Map<String, Money> get incomeByCategory => _current.incomeByCategory;

  /// Income and expense per day in the period, upcoming days included
  /// (INS-1).
  Map<DateTime, DayTotals> get dailyTotals => _current.dailyTotals;

  /// Today's date, from the provider's clock.
  DateTime get today => _today;

  /// Counted income and expense of the [count] periods that end with the
  /// selected one, oldest first (INS-2, BAL-4).
  List<PeriodTotals> trend(int count) {
    assert(count > 0, 'A trend needs at least one period');
    final periods = [_period];
    while (periods.length < count) {
      periods.insert(0, periods.first.previous);
    }
    final income = List.filled(count, Money.zero);
    final expense = List.filled(count, Money.zero);
    for (final tx in _transactions) {
      if (isUpcoming(tx) ||
          tx.date.isBefore(periods.first.start) ||
          !tx.date.isBefore(_period.end)) {
        continue;
      }
      final index = periods.indexWhere((period) => period.contains(tx.date));
      if (tx.type == TransactionType.income) {
        income[index] += tx.amount;
      } else {
        expense[index] += tx.amount;
      }
    }
    return [
      for (var i = 0; i < count; i++)
        PeriodTotals(periods[i], income: income[i], expense: expense[i]),
    ];
  }

  // The home-screen widget (WID-1–WID-6).

  /// Shows the period that contains today, whatever was selected before
  /// (WID-3).
  void showCurrentPeriod() {
    final current = currentPeriod;
    if (current == _period) return;
    _period = current;
    _changed();
  }

  /// What the home-screen widget should show: the current period as of
  /// today, then one entry for each of the next [days] days on which the
  /// numbers change — a new period starting, or a dated-ahead entry
  /// beginning to count (WID-2, WID-5, BAL-4).
  ///
  /// The widget can't recompute anything itself, so it is handed the days
  /// ahead as well and picks the entry whose day has come. That keeps it
  /// right past midnight even if the app is never opened.
  List<WidgetSummary> widgetTimeline({
    bool carryForward = true,
    int days = 31,
  }) {
    final today = _today;
    final last = today.add(Duration(days: days));

    final changeDays = <DateTime>{today};
    for (final tx in _transactions) {
      final day = _dayOf(tx.date);
      if (day.isAfter(today) && !day.isAfter(last)) changeDays.add(day);
    }
    for (final account in _accounts) {
      final day = _dayOf(account.openingDate);
      if (day.isAfter(today) && !day.isAfter(last)) changeDays.add(day);
    }
    for (
      var period = currentPeriod.next;
      !period.start.isAfter(last);
      period = period.next
    ) {
      changeDays.add(_dayOf(period.start));
    }

    final ordered = changeDays.toList()..sort();
    return [
      for (final day in ordered)
        _widgetEntryOn(day, carryForward: carryForward),
    ];
  }

  WidgetSummary _widgetEntryOn(DateTime day, {required bool carryForward}) {
    final period = Period.containing(day, startDay: _startDay);
    final summary = _PeriodSummary(
      period,
      day,
      _transactions,
      _transfers,
      _accounts,
    );
    final limit = limitFor(_budgets, null, period);
    return WidgetSummary(
      from: day,
      period: period,
      income: summary.income,
      expense: summary.expense,
      balance: carryForward
          ? summary.closingBalance
          : summary.income - summary.expense,
      balanceIsNet: !carryForward,
      budgetLeft: limit == null ? null : limit - summary.expense,
    );
  }

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
      final isIncome = tx.type == TransactionType.income;
      if (period.contains(tx.date)) {
        final day = _dayOf(tx.date);
        transactions.add(tx);
        byDay.putIfAbsent(day, () => []).add(tx);
        final totals = dailyTotals[day] ?? const DayTotals();
        dailyTotals[day] = DayTotals(
          income: isIncome ? totals.income + tx.amount : totals.income,
          expense: isIncome ? totals.expense : totals.expense + tx.amount,
        );
        if (!counts) continue;
        final byCategory = isIncome ? incomeByCategory : expenseByCategory;
        byCategory[tx.categoryId] =
            (byCategory[tx.categoryId] ?? Money.zero) + tx.amount;
        if (isIncome) {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
      } else if (counts && tx.date.isBefore(period.start)) {
        netBefore += isIncome ? tx.amount : -tx.amount;
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
  final Map<DateTime, DayTotals> dailyTotals = {};
  final List<Transfer> transfers = [];
  final Map<DateTime, List<Transfer>> transfersByDay = {};
  final Map<String, Money> expenseByCategory = {};
  final Map<String, Money> incomeByCategory = {};
  Money income = Money.zero;
  Money expense = Money.zero;
  late final Money carriedForward;
  late final Money closingBalance;
}

DateTime _dayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);
