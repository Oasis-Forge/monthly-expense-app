import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier, listEquals;
import 'package:flutter/widgets.dart' show Locale;
import 'package:uuid/uuid.dart';

import '../db/db_helper.dart';
import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/csv_import.dart';
import '../models/insights.dart';
import '../models/money.dart';
import '../models/note.dart';
import '../models/period.dart';
import '../models/recurring_rule.dart';
import '../models/reminders.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../models/transfer.dart';
import '../models/widget_summary.dart';
import '../services/attachment_service.dart';
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
  /// [attachments] holds the photo and voice files (ATT-2); the provider only
  /// deletes the ones their transactions leave behind.
  TransactionProvider({
    DBHelper? db,
    DateTime Function()? clock,
    int startDay = 1,
    ReminderService? reminders,
    AttachmentService? attachments,
  }) : _db = db ?? DBHelper.instance,
       _clock = clock ?? DateTime.now,
       _startDay = startDay,
       _reminders = SafeReminderService(
         reminders ?? const NoopReminderService(),
       ),
       _attachments = attachments ?? AttachmentService(),
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
  final AttachmentService _attachments;
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

  /// The day Home shows on its own (DAY-1), null for the whole period
  /// (DAY-5), with the period it was chosen for so a different period picks
  /// its own day again (DAY-6).
  DateTime? _selectedDay;
  Period? _daySelectionPeriod;

  /// The account Home is showing on its own, null for every account (ACC-6).
  /// Read through [accountFilterId], which falls back to every account when the
  /// chosen one has been archived or removed since it was chosen.
  String? _accountFilterId;
  _PeriodSummary? _summary;

  /// The same period with no account filter, for the things that have no
  /// account to be about (ACC-7). Only the budgets read it, and only when an
  /// account is chosen, so it is built at most once per change.
  _PeriodSummary? _everyAccountSummary;

  bool _loaded = false;

  /// Whether [load] has finished at least once.
  bool get isLoaded => _loaded;

  /// Bumped every time [_changed] runs — a save, a delete, a period or
  /// account-filter change — but not by [selectDay] or [clearSelectedDay]
  /// picking a different day inside the same period, which changes nothing
  /// the totals or the home-screen widget show (DAY-5, WID-5). Lets a
  /// listener that only cares about the numbers, not the view, tell the two
  /// kinds of notification apart instead of recomputing on every one
  /// (lifecycle-perf#9).
  int _dataVersion = 0;
  int get dataVersion => _dataVersion;

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

  /// Transfers in the trash, most recently deleted first (DEL-5). They are
  /// restored the same way transactions are, from the same screen.
  List<Transfer> get deletedTransfers => List.unmodifiable(_deletedTransfers);

  /// Notes in the trash, most recently deleted first (DEL-5, NOTE-7). Like
  /// transactions and transfers, they are restored from the same screen.
  List<Note> get deletedNotes => List.unmodifiable(_deletedNotes);

  List<Category> get categories => List.unmodifiable(_categories);

  /// Every account that isn't deleted, archived ones included.
  List<Account> get accounts => List.unmodifiable(_accounts);

  /// Recurring rules that aren't deleted, oldest first.
  List<RecurringRule> get recurringRules => List.unmodifiable(_rules);

  /// The period shown on Home and Stats.
  Period get period => _period;

  /// The day Home's list is filtered to, or null when it shows every day in
  /// the period. A period containing today starts on today; any other period
  /// starts with no day chosen (DAY-1, DAY-6).
  DateTime? get selectedDay {
    if (_daySelectionPeriod != _period) {
      _daySelectionPeriod = _period;
      final today = _today;
      _selectedDay = _period.contains(today) ? today : null;
    }
    return _selectedDay;
  }

  /// The account Home is showing, or null for every account (ACC-6). An
  /// account archived or removed since it was chosen reads as null rather
  /// than showing an empty Home with no way back, and [selectAccountFilter]
  /// is what writes it.
  String? get accountFilterId {
    final id = _accountFilterId;
    if (id == null) return null;
    final account = accountById(id);
    return account != null && account.archivedAt == null ? id : null;
  }

  /// Show one account on Home, or every account with null (ACC-6). The whole
  /// of Home follows: the summary card, the day list, and each day's own
  /// totals (ACC-7).
  void selectAccountFilter(String? id) {
    if (id == _accountFilterId) return;
    _accountFilterId = id;
    // A filter change moves nothing [dataVersion] tracks: every figure it
    // gates is the same, just narrowed to fewer accounts on the next read
    // (lifecycle-perf#9).
    _changed(dataChanged: false);
  }

  /// The period that contains today; budget changes apply from it (BUD-5).
  Period get currentPeriod => Period.containing(_clock(), startDay: _startDay);

  /// The day Home last took for today, so a return on a later day can tell
  /// whether Home was still on the old one.
  DateTime? _dayLastSeen;

  /// Brings Home to today when the app comes back on a later day while Home
  /// was still showing the old today (DAY-1, PER-1), so an entry added then
  /// belongs to the new day (ADD-3). A day or period the user chose stays
  /// chosen. Also posts any automatic occurrence that fell due while the app
  /// stayed open across the day change, since otherwise only [load] does
  /// (RCR-4, RCR-7).
  Future<void> returnToToday() async {
    final today = _today;
    final before = _dayLastSeen;
    _dayLastSeen = today;
    final dayChanged = before != null && before != today;
    if (dayChanged && selectedDay == before) {
      _period = currentPeriod;
      _daySelectionPeriod = null;
      _changed();
    }
    if (dayChanged) {
      await _postAutomaticOccurrences();
      _changed();
    }
  }

  final _loadDone = Completer<void>();

  /// Completes once [load] has read everything, for work that must see the
  /// user's entries first: counting ignored nudges before them would count
  /// days with entries as ignored (NUDGE-5).
  Future<void> get whenLoaded => _loadDone.future;
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

  Map<String, Category>? _categoryIndex;

  Category? categoryById(String id) => (_categoryIndex ??= {
    for (final category in _categories) category.id: category,
  })[id];

  List<Account> get activeAccounts => [
    for (final account in _accounts)
      if (account.archivedAt == null) account,
  ];

  List<Account> get archivedAccounts => [
    for (final account in _accounts)
      if (account.archivedAt != null) account,
  ];

  Map<String, Account>? _accountIndex;

  Account? accountById(String id) => (_accountIndex ??= {
    for (final account in _accounts) account.id: account,
  })[id];

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
    // Home showing one account is a stronger signal than the last one used:
    // an entry started from there almost always belongs to it (ACC-9).
    final chosen = accountFilterId;
    if (chosen != null) return chosen;
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
  int trashDaysLeft(ExpenseTransaction tx) => _daysLeftSince(tx.deletedAt!);

  /// The same for a trashed transfer (DEL-5).
  int trashDaysLeftForTransfer(Transfer transfer) =>
      _daysLeftSince(transfer.deletedAt!);

  /// The same for a trashed note (DEL-5, NOTE-7).
  int trashDaysLeftForNote(Note note) => _daysLeftSince(note.deletedAt!);

  int _daysLeftSince(DateTime deletedAt) {
    final left = trashRetention.inDays - _clock().difference(deletedAt).inDays;
    return left < 1 ? 1 : left;
  }

  /// The account's balance today: its opening balance from the opening date,
  /// plus income, minus expense, minus transfers out, plus transfers in
  /// (ACC-4). Future-dated entries don't count yet (BAL-4).
  /// What the active accounts come to together (ACC-10). Archived accounts
  /// are money already put away and stay out of it (ACC-5).
  Money get accountsTotal {
    // Read once, not once per account: [_balances] re-checks the clock
    // against the day it was cached for every time it's read
    // (lifecycle-perf#10), so this keeps that check itself from scaling
    // with the number of accounts.
    final balances = _balances;
    var total = Money.zero;
    for (final account in activeAccounts) {
      total += balances[account.id] ?? Money.zero;
    }
    return total;
  }

  /// Every account's balance, in one pass over the transactions and
  /// transfers rather than one pass per account (ACC-4, ACC-10), built once
  /// per data change and reused until the next one, or until a day turns
  /// over while the app stays open and moves what counts as upcoming
  /// (perf lifecycle-perf#10).
  Map<String, Money> get _balances {
    final today = _today;
    final cached = _balanceCache;
    if (cached != null && _balanceCacheDay == today) return cached;
    final balances = <String, Money>{};
    for (final account in _accounts) {
      balances[account.id] = _dayOf(account.openingDate).isAfter(today)
          ? Money.zero
          : account.openingBalance;
    }
    for (final tx in _transactions) {
      if (_dayOf(tx.date).isAfter(today)) continue;
      final delta = tx.type == TransactionType.income ? tx.amount : -tx.amount;
      balances[tx.accountId] = (balances[tx.accountId] ?? Money.zero) + delta;
    }
    for (final transfer in _transfers) {
      if (_dayOf(transfer.date).isAfter(today)) continue;
      balances[transfer.fromAccountId] =
          (balances[transfer.fromAccountId] ?? Money.zero) - transfer.amount;
      balances[transfer.toAccountId] =
          (balances[transfer.toAccountId] ?? Money.zero) + transfer.amount;
    }
    _balanceCacheDay = today;
    return _balanceCache = balances;
  }

  Map<String, Money>? _balanceCache;
  DateTime? _balanceCacheDay;

  Money accountBalance(String id) => _balances[id] ?? Money.zero;

  DateTime get _today => _dayOf(_clock());

  /// Purges old trash (DEL-3), loads everything, and posts due occurrences of
  /// automatic recurring rules (RCR-4).
  /// [appLockOn] and [locale] shape reminder notifications rescheduled for
  /// open notes (NOTE-6): after a reboot clears the OS alarms, or a restore
  /// changes which notes are open, the next launch resyncs them.
  Future<void> load({
    bool appLockOn = false,
    Locale locale = const Locale('en'),
    NudgeSettings nudge = NudgeSettings.off,
  }) async {
    _dayLastSeen = _today;
    await _attachments.deleteAll(
      await _db.purgeDeletedBefore(_clock().subtract(trashRetention)),
    );
    _categories = await _db.fetchCategories();
    _accounts = await _db.fetchAccounts();
    _budgets = await _db.fetchBudgets();
    _rules = await _db.fetchRecurringRules();
    _notes = await _db.fetchNotes();
    final occurrences = await _db.fetchOccurrences();
    final loaded = await _db.fetchTransactions();
    final deleted = await _db.fetchDeletedTransactions();
    final transfers = await _db.fetchTransfers();
    final deletedTransfers = await _db.fetchDeletedTransfers();
    final deletedNotes = await _db.fetchDeletedNotes();
    // Everything above only reads the database; a shortcut or widget tap
    // waiting on [whenLoaded] (WID-3, ADD-3) must still be freed even if
    // something below throws -- a write failure in
    // _postAutomaticOccurrences (storage full, a locked database) or a
    // crash while building the schedule -- rather than waiting forever.
    try {
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
      // DEL-5: the trash keeps transfers across a launch, like transactions.
      _deletedTransfers
        ..clear()
        ..addAll(deletedTransfers);
      // DEL-5, NOTE-7: and notes, the same way.
      _deletedNotes
        ..clear()
        ..addAll(deletedNotes);
      _reopenedNotes.clear();
      await _postAutomaticOccurrences();
      await rescheduleReminders(
        appLockOn: appLockOn,
        locale: locale,
        nudge: nudge,
      );
      _loaded = true;
    } finally {
      if (!_loadDone.isCompleted) _loadDone.complete();
    }
    _changed();
  }

  /// Re-schedules every open note's reminder (NOTE-6). Settings calls this
  /// after a change to app lock or the app's language, so notifications
  /// already scheduled pick up the new [appLockOn] and [locale] instead of
  /// waiting for the next launch (LOCK-2).
  Future<void> rescheduleReminders({
    required bool appLockOn,
    required Locale locale,
    NudgeSettings nudge = NudgeSettings.off,
  }) async {
    _appLockOn = appLockOn;
    _locale = locale;
    _nudge = nudge;
    for (final note in _notes) {
      await _reminders.schedule(note, appLockOn: appLockOn, locale: locale);
    }
    // The app's own reminders are planned from what is due and what the
    // user has asked for, and replace whatever was scheduled before
    // (NUDGE-1).
    await _scheduleNudges(_nudgePlan());
  }

  NudgeSettings _nudge = NudgeSettings.off;
  List<PlannedReminder>? _plannedNudges;

  List<PlannedReminder> _nudgePlan() => planReminders(
    now: _clock(),
    due: dueOccurrences,
    upcoming: upcomingOccurrences,
    emptyDayOn: _nudge.on,
    emptyDayHour: _nudge.hour,
    emptyDayMinute: _nudge.minute,
    recordedToday: recordedToday,
  );

  /// Hands [plan] to the device and remembers it, so an unchanged plan is
  /// not sent again.
  Future<void> _scheduleNudges(List<PlannedReminder> plan) {
    _plannedNudges = plan;
    return _reminders.scheduleNudges(
      plan,
      appLockOn: _appLockOn,
      locale: _locale,
    );
  }

  /// Sets the first day of each month (PER-2) and shows the period that
  /// contains today.
  void setStartDay(int day) {
    if (day == _startDay) return;
    _startDay = day;
    _period = Period.containing(_clock(), startDay: day);
    _changed();
  }

  // Moving the period this way changes what a read is scoped to, not any
  // figure itself, so [dataVersion] — and anything keyed on it alone, like
  // the home-screen widget — doesn't move either (lifecycle-perf#9).

  void nextPeriod() {
    _period = _period.next;
    _changed(dataChanged: false);
  }

  void previousPeriod() {
    _period = _period.previous;
    _changed(dataChanged: false);
  }

  /// Shows one day on its own (DAY-1). A day outside the shown period moves
  /// the period to the one that contains it (DAY-3).
  void selectDay(DateTime day) {
    final target = _dayOf(day);
    final movedPeriod = !_period.contains(target);
    if (movedPeriod) {
      _period = Period.containing(target, startDay: _startDay);
    }
    _selectedDay = target;
    _daySelectionPeriod = _period;
    // Only a new period invalidates the cached totals, and moving it here
    // is the same period-scope change as nextPeriod/previousPeriod above.
    if (movedPeriod) {
      _changed(dataChanged: false);
    } else {
      notifyListeners();
    }
  }

  /// Goes back to every day in the period (DAY-5).
  void clearSelectedDay() {
    _selectedDay = null;
    _daySelectionPeriod = _period;
    notifyListeners();
  }

  /// Days from [from] to [to] inclusive that carry a transaction or a
  /// transfer, for the dots on the day strip (DAY-4).
  Set<DateTime> entryDaysIn(DateTime from, DateTime to) {
    final start = _dayOf(from);
    final end = _dayOf(to);
    final days = <DateTime>{};
    bool inRange(DateTime day) => !day.isBefore(start) && !day.isAfter(end);
    for (final tx in _transactions) {
      final day = _dayOf(tx.date);
      if (inRange(day)) days.add(day);
    }
    for (final transfer in _transfers) {
      final day = _dayOf(transfer.date);
      if (inRange(day)) days.add(day);
    }
    return days;
  }

  /// The date a new entry starts on: the day Home is showing, else today,
  /// either way at the current time of day (ADD-3, DAY-9).
  DateTime get newEntryDate {
    final now = _clock();
    final day = selectedDay;
    if (day == null || day == _dayOf(now)) return now;
    return DateTime(day.year, day.month, day.day, now.hour, now.minute);
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
      final old = _transactions[index];
      _transactions[index] = stamped;
      _transactions.sort(_newestFirst);
      // The write has already succeeded, so the cached totals move with it
      // regardless of what the cleanup below does (data-integrity#12):
      // otherwise a throw from it would leave them stale even though the
      // row itself is already saved.
      _changed();
      // A photo or voice note that was replaced leaves its file (ATT-5).
      await _attachments.deleteAll([
        if (old.photoFile != stamped.photoFile) old.photoFile,
        if (old.voiceFile != stamped.voiceFile) old.voiceFile,
      ]);
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
    // As in updateTransaction, ahead of the note side effect (NOTE-4)
    // rather than after it (data-integrity#12).
    _changed();
    await _reopenNoteFor(id);
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
    // Same ordering as delete and update, ahead of the note relink
    // (data-integrity#12).
    _changed();
    await _relinkNoteFor(id);
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

  /// [importIdentity] for everything the app holds, so a file imported once
  /// isn't imported again (IMP-8). Trashed records don't count: importing a
  /// row again is one way to get a deleted one back.
  Set<String> get importIdentities => {
    for (final tx in _transactions)
      importIdentity(
        date: tx.date,
        amount: tx.amount,
        type: tx.type == TransactionType.income
            ? ImportedType.income
            : ImportedType.expense,
        title: tx.title ?? '',
      ),
    for (final transfer in _transfers)
      importIdentity(
        date: transfer.date,
        amount: transfer.amount,
        type: ImportedType.transfer,
        title: '',
      ),
  };

  /// Writes everything [plan] said it would import, in one database
  /// transaction, and adds it to the lists (IMP-1, IMP-6). Returns how many
  /// records were written.
  ///
  /// [categoryIds] and [accountIds] give this app's ID for a name as the file
  /// wrote it: what matched by name, plus whatever the user chose on the
  /// preview (IMP-7). A name that isn't in them falls back to Other and the
  /// default account, as does a category of the wrong type — nothing is
  /// created. A transfer whose two names land on the same account isn't a
  /// transfer, so it is left out and not counted.
  Future<int> applyImport(
    ImportPlan plan, {
    Map<String, String> categoryIds = const {},
    Map<String, String> accountIds = const {},
  }) async {
    final fallbackAccount = defaultAccountId();
    if (fallbackAccount == null) return 0;
    final now = _clock().toUtc();

    String accountFor(String name) {
      final id = accountIds[name];
      return id != null && accountById(id) != null ? id : fallbackAccount;
    }

    String? categoryFor(String name, TransactionType type) {
      final chosen = categoryById(categoryIds[name] ?? '');
      if (chosen != null && chosen.type == type) return chosen.id;
      return otherCategoryId(type);
    }

    final transactions = <ExpenseTransaction>[];
    final transfers = <Transfer>[];
    for (final row in plan.importing) {
      final date = row.date;
      final amount = row.amount;
      if (date == null || amount == null) continue;

      if (row.type == ImportedType.transfer) {
        final from = accountFor(row.accountName);
        final to = accountFor(row.toAccountName);
        if (from == to) continue;
        transfers.add(
          Transfer(
            id: const Uuid().v4(),
            fromAccountId: from,
            toAccountId: to,
            amount: amount,
            date: date,
            note: _importedNote([row.title, row.note]),
            createdAt: now,
            updatedAt: now,
          ),
        );
        continue;
      }

      final type = row.type == ImportedType.income
          ? TransactionType.income
          : TransactionType.expense;
      final categoryId = categoryFor(row.categoryName, type);
      if (categoryId == null) continue;
      transactions.add(
        ExpenseTransaction(
          id: const Uuid().v4(),
          title: row.title.isEmpty ? null : row.title,
          amount: amount,
          categoryId: categoryId,
          accountId: accountFor(row.accountName),
          type: type,
          date: date,
          note: row.note.isEmpty ? null : row.note,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    if (transactions.isEmpty && transfers.isEmpty) return 0;
    await _db.insertImported(transactions: transactions, transfers: transfers);
    _transactions
      ..addAll(transactions)
      ..sort(_newestFirst);
    _transfers
      ..addAll(transfers)
      ..sort(_newestTransferFirst);
    _changed();
    return transactions.length + transfers.length;
  }

  /// The catch-all category for [type] (IMP-7), or the first one there is.
  /// What an imported name the app hasn't got becomes.
  String? otherCategoryId(TransactionType type) {
    for (final category in _categories) {
      if (category.type == type && category.defaultKey == 'other') {
        return category.id;
      }
    }
    final options = categoriesFor(type);
    return options.isEmpty ? null : options.first.id;
  }

  /// A transfer has no title of its own, so an imported one keeps both parts
  /// in its note rather than dropping either.
  static String? _importedNote(List<String> parts) {
    final kept = [
      for (final part in parts)
        if (part.isNotEmpty) part,
    ];
    return kept.isEmpty ? null : kept.join(' — ');
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
  /// account, or a recurring rule still posts to it (RCR-1).
  bool isAccountUsed(String id) =>
      _transactions.any((t) => t.accountId == id) ||
      _deleted.any((t) => t.accountId == id) ||
      [
        ..._transfers,
        ..._deletedTransfers,
      ].any((t) => t.fromAccountId == id || t.toAccountId == id) ||
      _rules.any((r) => r.accountId == id);

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
    int? color,
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
      // Carrying on through the palette rather than starting over, so two
      // categories added one after the other do not look alike (CAT-6).
      color:
          color ?? categoryPalette[_categories.length % categoryPalette.length],
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

  /// Whether any transaction, trashed ones included, uses the category, or a
  /// recurring rule still posts to it (RCR-1).
  bool isCategoryUsed(String id) =>
      _transactions.any((t) => t.categoryId == id) ||
      _deleted.any((t) => t.categoryId == id) ||
      _rules.any((r) => r.categoryId == id);

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

  /// [tx.title] and [tx.note] already folded for a search match, built once
  /// per data change instead of on every keystroke (lifecycle-perf#10):
  /// unlike a category or account name, neither depends on the locale a
  /// caller formats them with.
  Map<String, (String?, String?)>? _foldedCache;

  (String?, String?) _foldedTextOf(ExpenseTransaction tx) =>
      (_foldedCache ??= {})[tx.id] ??= (
        tx.title == null ? null : foldForSearch(tx.title!),
        tx.note == null ? null : foldForSearch(tx.note!),
      );

  /// Whether [tx] matches [filter]'s text, type, and category — the same
  /// narrowing [search] and its CSV export apply, kept separate from
  /// [filter]'s account and dates so a caller (the report opened from
  /// Search, PDF-1) can apply those on its own instead. Text matches the
  /// title, note, [categoryName], [accountName], or an equal amount,
  /// ignoring case and accents.
  bool matchesSearch(
    ExpenseTransaction tx,
    TransactionFilter filter, {
    required String Function(Category category) categoryName,
    required String Function(Account account) accountName,
    // Required rather than defaulted to '.': a caller that forgets this reads
    // a comma-decimal amount query as if the currency used '.', which silently
    // rejects a correctly-typed amount instead of matching it (CUR-2).
    required String decimalMark,
  }) => _matchesSearch(
    tx,
    filter,
    foldedQuery: foldForSearch(filter.query.trim()),
    queryAmount: Money.tryParse(filter.query, decimalMark: decimalMark),
    categoryName: categoryName,
    accountName: accountName,
    categoryFold: {},
    accountFold: {},
  );

  /// The core [matchesSearch] applies, taking the query already folded and
  /// the amount already parsed rather than redoing that per transaction, and
  /// memoizing a category or account's folded name in [categoryFold] /
  /// [accountFold] the first time [search] meets it (lifecycle-perf#10).
  bool _matchesSearch(
    ExpenseTransaction tx,
    TransactionFilter filter, {
    required String foldedQuery,
    required Money? queryAmount,
    required String Function(Category category) categoryName,
    required String Function(Account account) accountName,
    required Map<String, String> categoryFold,
    required Map<String, String> accountFold,
  }) {
    if (filter.type != null && tx.type != filter.type) return false;
    if (filter.categoryId != null && tx.categoryId != filter.categoryId) {
      return false;
    }
    if (foldedQuery.isEmpty || tx.amount == queryAmount) return true;
    final category = categoryById(tx.categoryId);
    final account = accountById(tx.accountId);
    final (foldedTitle, foldedNote) = _foldedTextOf(tx);
    return [
      foldedTitle,
      foldedNote,
      if (category != null)
        categoryFold[category.id] ??= foldForSearch(categoryName(category)),
      if (account != null)
        accountFold[account.id] ??= foldForSearch(accountName(account)),
    ].any((text) => text != null && text.contains(foldedQuery));
  }

  /// Transactions matching [filter], newest first.
  SearchResult search(
    TransactionFilter filter, {
    required String Function(Category category) categoryName,
    required String Function(Account account) accountName,
    // Required, not defaulted: see matchesSearch above (CUR-2).
    required String decimalMark,
  }) {
    final from = filter.from == null ? null : _dayOf(filter.from!);
    final to = filter.to == null ? null : _dayOf(filter.to!);
    final checkDay = from != null || to != null;
    // Folded and parsed once for the whole call, not once per transaction
    // (lifecycle-perf#10).
    final foldedQuery = foldForSearch(filter.query.trim());
    final queryAmount = Money.tryParse(filter.query, decimalMark: decimalMark);
    final today = _today;
    final categoryFold = <String, String>{};
    final accountFold = <String, String>{};

    final matches = <ExpenseTransaction>[];
    var income = Money.zero;
    var expense = Money.zero;
    for (final tx in _transactions) {
      if (filter.accountId != null && tx.accountId != filter.accountId) {
        continue;
      }
      // A DateTime is built here only when a date filter is actually set,
      // rather than for every transaction on every keystroke
      // (lifecycle-perf#10).
      if (checkDay) {
        final day = _dayOf(tx.date);
        if ((from != null && day.isBefore(from)) ||
            (to != null && day.isAfter(to))) {
          continue;
        }
      }
      if (!_matchesSearch(
        tx,
        filter,
        foldedQuery: foldedQuery,
        queryAmount: queryAmount,
        categoryName: categoryName,
        accountName: accountName,
        categoryFold: categoryFold,
        accountFold: accountFold,
      )) {
        continue;
      }
      matches.add(tx);
      if (_dayOf(tx.date).isAfter(today)) continue; // isUpcoming, cached today
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

  /// What every account spent in the period before the current one, for the
  /// overall budget's first figure (BUD-11, ACC-7). It does not follow the
  /// selected period: the budget it seeds starts from the current one.
  Money get lastPeriodExpense {
    final period = currentPeriod.previous;
    var total = Money.zero;
    for (final tx in _transactions) {
      if (tx.type == TransactionType.expense &&
          period.contains(tx.date) &&
          !isUpcoming(tx)) {
        total += tx.amount;
      }
    }
    return total;
  }

  /// Sets a budget, or removes it with a null [limit], from the current
  /// period onward; earlier periods keep their limits (BUD-5).
  ///
  /// A version that starts later inside the current period (one set before
  /// the month start day moved earlier in the calendar, PER-2) would keep
  /// outranking the new one, so it is removed: the new version always wins
  /// for the current period. It never applied to an earlier period, so none
  /// of them changes.
  Future<void> setBudget(String? categoryId, Money? limit) async {
    final current = currentPeriod;
    final from = current.start;
    final now = _clock().toUtc();
    Budget? existing;
    final superseded = <Budget>[];
    for (final budget in _budgets) {
      if (budget.categoryId != categoryId || budget.deletedAt != null) {
        continue;
      }
      if (budget.effectiveFrom == from) {
        existing = budget;
      } else if (budget.effectiveFrom.isAfter(from) &&
          budget.effectiveFrom.isBefore(current.end)) {
        superseded.add(budget);
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
    try {
      for (final budget in superseded) {
        await _db.updateBudget(budget.copyWith(deletedAt: now, updatedAt: now));
        _budgets = [
          for (final kept in _budgets)
            if (kept.id != budget.id) kept,
        ];
      }
    } finally {
      _changed();
    }
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

    // Every account, never the chosen one: see [_everyAccount] (ACC-7).
    final byCategory = _everyAccount.expenseByCategory;
    return [
      ?statusFor(null, _everyAccount.expense),
      for (final category in [
        ...categoriesFor(TransactionType.expense),
        // An archived category's budget has no tile left to change it on, so
        // it stops counting from the current period on; a past period still
        // shows the result it had (BUD-5, BUD-6, CAT-4).
        if (timing == PeriodTiming.past)
          ...archivedCategoriesFor(TransactionType.expense),
      ])
        ?statusFor(category.id, byCategory[category.id] ?? Money.zero),
    ];
  }

  /// The one number the summary card leads with (BAL-8).
  ///
  /// Every account, never the chosen one, because it is about the budget and
  /// a budget counts them all (ACC-7). Home shows it only while every account
  /// is on screen (BAL-9), so the two never sit side by side.
  HeroLine get heroLine {
    final today = _today;
    final timing = _period.timingOn(today);
    final start = DateTime.utc(
      _period.start.year,
      _period.start.month,
      _period.start.day,
    );
    final daysElapsed = timing == PeriodTiming.current
        ? DateTime.utc(
                today.year,
                today.month,
                today.day,
              ).difference(start).inDays +
              1
        : 0;
    return HeroLine.of(
      overall: budgetStatuses.where((s) => s.categoryId == null).firstOrNull,
      spent: _everyAccount.expense,
      daysElapsed: daysElapsed,
      timing: timing,
    );
  }

  Set<DateTime>? _daysUsedCache;

  /// The days anything was added on, at midnight local: when the person used
  /// the app, not what the entry is dated. Three of them is what the
  /// empty-day nudge is offered after (NUDGE-3), and one of them is what
  /// answers a nudge that has already fired (NUDGE-5). Built once per data
  /// change rather than on every read (lifecycle-perf#10).
  Set<DateTime> get daysUsed => _daysUsedCache ??= {
    for (final transaction in _transactions)
      DateTime(
        transaction.createdAt.year,
        transaction.createdAt.month,
        transaction.createdAt.day,
      ),
    for (final transfer in _transfers)
      DateTime(
        transfer.createdAt.year,
        transfer.createdAt.month,
        transfer.createdAt.day,
      ),
  };

  /// Whether today has anything dated to it, which is what keeps it from
  /// being told that it is empty (NUDGE-4).
  bool get recordedToday {
    final today = _today;
    return _transactions.any((t) => _isToday(t.date, today)) ||
        _transfers.any((t) => _isToday(t.date, today));
  }

  static bool _isToday(DateTime date, DateTime today) =>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day;

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

  /// What the expense rules come to in a month, added up (RCR-8). Income
  /// rules are left out: a figure running both ways at once answers nothing.
  Money get monthlyBills {
    final today = _today;
    var total = Money.zero;
    for (final rule in _rules) {
      if (rule.type != TransactionType.expense) continue;
      if (!rule.isActiveOn(today)) continue;
      total += rule.monthlyCost;
    }
    return total;
  }

  /// What falls next and is still waiting: one due today, else the first of
  /// the upcoming days (RCR-8).
  ///
  /// Null while anything is overdue, because the line would otherwise point
  /// a week ahead over a list of things already waiting, and "next in seven
  /// days" above six unhandled entries is a contradiction the reader has to
  /// resolve. The due list is directly underneath and says it better.
  ScheduledOccurrence? get nextScheduled {
    final today = _today;
    for (final occurrence in dueOccurrences) {
      if (_isToday(occurrence.date, today)) return occurrence;
      // Dated before today, and the list is oldest first, so anything left
      // is older still.
      return null;
    }
    final upcoming = upcomingOccurrences;
    return upcoming.isEmpty ? null : upcoming.first;
  }

  /// Whole days from today to [date], so a screen can say when something
  /// falls without a clock of its own.
  int daysUntil(DateTime date) {
    final today = _today;
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
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

  /// Saves an edited rule (RCR-5).
  ///
  /// An edit that leaves the schedule alone (amount, title, category and so
  /// on) reaches every occurrence not yet posted or skipped, including one
  /// already waiting in Due; only a start date moved later can push
  /// activeFrom forward, so such an edit never makes a due occurrence
  /// disappear on its own.
  ///
  /// An edit to the schedule (how often, the start, or the end) never posts
  /// or queues a date of the new schedule before today. An occurrence that
  /// was already waiting in Due stays waiting if it also falls on the new
  /// schedule; every other new date before today is skipped, the way a
  /// resume skips what fell due while paused (RCR-6). Extending a rule that
  /// had ended therefore picks up from today, not from where it stopped.
  Future<void> updateRecurringRule(RecurringRule rule) async {
    final old = recurringRuleById(rule.id);
    final now = _clock().toUtc();
    if (old == null || !_scheduleChanged(old, rule)) {
      final floor = old?.activeFrom ?? rule.activeFrom;
      await _saveRule(
        rule.copyWith(
          activeFrom: rule.startDate.isAfter(floor) ? rule.startDate : floor,
          updatedAt: now,
        ),
      );
      await _postAutomaticOccurrences();
      _changed();
      return;
    }

    final today = _today;
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final startDay = DateTime(
      rule.startDate.year,
      rule.startDate.month,
      rule.startDate.day,
    );
    final unbounded = rule.copyWith(activeFrom: startDay);
    // The old rule's unhandled occurrences before today that the new
    // schedule also has: these were waiting in Due and keep waiting.
    final kept = <DateTime>{
      for (final date in old.occurrencesBetween(old.activeFrom, yesterday))
        if (!_occurrences.containsKey(occurrenceKey(rule.id, date)) &&
            unbounded.occurrencesBetween(date, date).isNotEmpty)
          date,
    };
    final earliestKept = kept.isEmpty
        ? null
        : kept.reduce((a, b) => a.isBefore(b) ? a : b);
    var activeFrom = earliestKept ?? today;
    if (startDay.isAfter(activeFrom)) activeFrom = startDay;
    final updated = rule.copyWith(activeFrom: activeFrom, updatedAt: now);

    // Skip every other date of the new schedule before today, first, so a
    // failed save can never leave a rule that reaches back unguarded.
    for (final date in updated.occurrencesBetween(activeFrom, yesterday)) {
      final key = occurrenceKey(rule.id, date);
      if (_occurrences.containsKey(key) || kept.contains(date)) continue;
      final record = RecurringOccurrence(
        ruleId: rule.id,
        date: date,
        status: OccurrenceStatus.skipped,
        createdAt: now,
      );
      await _db.insertOccurrence(record);
      _occurrences[record.key] = record;
    }
    await _saveRule(updated);
    await _postAutomaticOccurrences();
    _changed();
  }

  static bool _scheduleChanged(RecurringRule a, RecurringRule b) =>
      a.frequency != b.frequency ||
      a.interval != b.interval ||
      !_sameDay(a.startDate, b.startDate) ||
      a.endType != b.endType ||
      a.endCount != b.endCount ||
      !_sameOptionalDay(a.endDate, b.endDate);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _sameOptionalDay(DateTime? a, DateTime? b) =>
      a == null || b == null ? a == b : _sameDay(a, b);

  Future<void> pauseRecurringRule(String id) async {
    final now = _clock().toUtc();
    await _saveRule(
      recurringRuleById(id)!.copyWith(pausedAt: now, updatedAt: now),
    );
    _changed();
  }

  /// Resumes a rule. Occurrences that fell due between the pause and now are
  /// skipped one by one, not caught up (RCR-6); an occurrence that was
  /// already waiting in Due before the pause started stays waiting (RCR-5).
  Future<void> resumeRecurringRule(String id) async {
    final rule = recurringRuleById(id)!;
    final pausedAt = rule.pausedAt;
    if (pausedAt != null) {
      final now = _clock().toUtc();
      for (final date in rule.occurrencesBetween(pausedAt, _today)) {
        final key = occurrenceKey(rule.id, date);
        if (_occurrences.containsKey(key)) continue;
        final record = RecurringOccurrence(
          ruleId: rule.id,
          date: date,
          status: OccurrenceStatus.skipped,
          createdAt: now,
        );
        await _db.insertOccurrence(record);
        _occurrences[record.key] = record;
      }
    }
    await _saveRule(rule.copyWith(pausedAt: null, updatedAt: _clock().toUtc()));
    await _postAutomaticOccurrences();
    _changed();
  }

  /// Deletes a rule; the transactions it posted stay (RCR-5). Returns the
  /// rule as it was, for [restoreRecurringRule] (DEL-2).
  Future<RecurringRule> deleteRecurringRule(String id) async {
    final rule = recurringRuleById(id)!;
    final now = _clock().toUtc();
    await _saveRule(rule.copyWith(deletedAt: now, updatedAt: now));
    _changed();
    return rule;
  }

  /// Brings back a rule deleted by [deleteRecurringRule], by clearing its
  /// deletedAt (DEL-2); automatic rules then post whatever fell due.
  Future<void> restoreRecurringRule(RecurringRule rule) async {
    if (recurringRuleById(rule.id) != null) return;
    final restored = rule.copyWith(
      deletedAt: null,
      updatedAt: _clock().toUtc(),
    );
    await _db.updateRecurringRule(restored);
    // Back in its place: rules are listed in the order they were created.
    final at = _rules.indexWhere((r) => r.createdAt.isAfter(rule.createdAt));
    _rules = [..._rules]..insert(at < 0 ? _rules.length : at, restored);
    await _postAutomaticOccurrences();
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

  /// [periodTransactions] across every account, whatever [accountFilterId]
  /// is set to. The CSV export reads these instead of [periodTransactions]:
  /// like budgets, it is one of the things the account choice must not
  /// reach, because a partial file that looks complete is worse than an
  /// extra step (ACC-7, BAK-5).
  List<ExpenseTransaction> get everyAccountPeriodTransactions =>
      _everyAccount.transactions;

  /// [periodTransfers] across every account (ACC-7, BAK-5).
  List<Transfer> get everyAccountPeriodTransfers => _everyAccount.transfers;

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

  List<PeriodTotals>? _trendCache;
  int? _trendCacheCount;
  DateTime? _trendCacheDay;

  /// Counted income and expense of the [count] periods that end with the
  /// selected one, oldest first. Follows the chosen account exactly as the
  /// other Insights views do, so a chart and the total above it are never
  /// about different money (INS-2, BAL-4, ACC-7).
  List<PeriodTotals> trend(int count) {
    assert(count > 0, 'A trend needs at least one period');
    final today = _today;
    // Built once per data change (or once a day turns over) and reused for
    // a re-read with the same count, rather than rescanning every
    // transaction again (lifecycle-perf#10).
    final cached = _trendCache;
    if (cached != null &&
        _trendCacheCount == count &&
        _trendCacheDay == today) {
      return cached;
    }
    final periods = [_period];
    while (periods.length < count) {
      periods.insert(0, periods.first.previous);
    }
    final account = accountFilterId;
    final income = List.filled(count, Money.zero);
    final expense = List.filled(count, Money.zero);
    for (final tx in _transactions) {
      if (_dayOf(tx.date).isAfter(today) ||
          tx.date.isBefore(periods.first.start) ||
          !tx.date.isBefore(_period.end) ||
          (account != null && tx.accountId != account)) {
        continue;
      }
      final index = periods.indexWhere((period) => period.contains(tx.date));
      if (tx.type == TransactionType.income) {
        income[index] += tx.amount;
      } else {
        expense[index] += tx.amount;
      }
    }
    final result = [
      for (var i = 0; i < count; i++)
        PeriodTotals(periods[i], income: income[i], expense: expense[i]),
    ];
    _trendCache = result;
    _trendCacheCount = count;
    _trendCacheDay = today;
    return result;
  }

  // The home-screen widget (WID-1–WID-6).

  /// Shows the period that contains today, whatever was selected before
  /// (WID-3). A shortcut or widget tap is a fresh start, so a day chosen on
  /// an earlier visit is brought forward to today first, the same as the
  /// app resuming does (DAY-1, DAY-9): otherwise a stale day survives within
  /// the same period and a new entry lands on it instead of today.
  void showCurrentPeriod() {
    returnToToday();
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
      // The home-screen widget is not Home: it shows the whole of the money
      // whatever account Home is filtered to (WID-1, ACC-6).
      null,
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

  /// Notifies, and invalidates the totals/balance/trend/search caches, for
  /// anything that changes what they'd compute. [dataChanged] additionally
  /// bumps [dataVersion] — the narrower signal a listener like
  /// [HomeWidgetUpdater] can key a refresh on instead of every notification,
  /// since a period or account-filter move alone changes no figure, only
  /// what the next read is scoped to (lifecycle-perf#9).
  void _changed({bool dataChanged = true}) {
    if (dataChanged) _dataVersion++;
    _summary = null;
    _everyAccountSummary = null;
    _previousSummary = null;
    _previousSummaryDay = null;
    _previousSummaryAccount = null;
    _balanceCache = null;
    _trendCache = null;
    _daysUsedCache = null;
    _foldedCache = null;
    _categoryIndex = null;
    _accountIndex = null;
    notifyListeners();
    // What the app's own reminders say follows the records: an entry made
    // today calls off tonight's empty-day nudge, and a due entry posted or
    // skipped stops being announced (NUDGE-4). Only a changed plan goes to
    // the device.
    if (!_loaded) return;
    final plan = _nudgePlan();
    if (!listEquals(plan, _plannedNudges)) unawaited(_scheduleNudges(plan));
  }

  /// The period before the selected one, bounded to the same number of days
  /// the selected one has had so far, for the comparison the category chart
  /// draws (INS-6, pr56+60#4): a partial current period is measured against
  /// an equally partial previous one, not the whole of it, so an early-month
  /// reading doesn't compare 3 days of spending against 31. It follows the
  /// chosen account exactly as the chart does (ACC-7), and like the others
  /// it is built at most once per change.
  _PeriodSummary? _previousSummary;
  DateTime? _previousSummaryDay;
  String? _previousSummaryAccount;

  _PeriodSummary get _previous {
    final today = _today;
    final account = accountFilterId;
    final cached = _previousSummary;
    if (cached != null &&
        _previousSummaryDay == today &&
        _previousSummaryAccount == account) {
      return cached;
    }
    final elapsedDays = today.difference(_period.start).inDays;
    final asOf = _period.previous.start.add(Duration(days: elapsedDays));
    _previousSummaryDay = today;
    _previousSummaryAccount = account;
    return _previousSummary = _PeriodSummary(
      _period.previous,
      asOf,
      _transactions,
      _transfers,
      _accounts,
      account,
    );
  }

  /// Last period's expense and income by category (INS-6).
  Map<String, Money> get previousExpenseByCategory =>
      _previous.expenseByCategory;
  Map<String, Money> get previousIncomeByCategory => _previous.incomeByCategory;

  /// Whether anything at all was recorded before the selected period, for
  /// the chosen account. The earliest period on record has nothing to
  /// compare itself with, and a comparison against nothing reads as "you
  /// spent nothing last month" (INS-6, ACC-7).
  bool get hasEarlierRecords {
    final account = accountFilterId;
    return _transactions.any(
      (tx) =>
          tx.date.isBefore(_period.start) &&
          (account == null || tx.accountId == account),
    );
  }

  /// The period across every account, whatever [accountFilterId] is set to.
  /// A budget is a limit on a category and has no account (BUD-1), so
  /// measuring one account's spending against it would report a limit nobody
  /// set -- on a card with no groceries on it, "0% used" of a grocery budget
  /// that is in fact more than half gone (ACC-7).
  _PeriodSummary get _everyAccount {
    if (accountFilterId == null) return _current;
    final today = _today;
    final cached = _everyAccountSummary;
    if (cached != null && cached.today == today) return cached;
    return _everyAccountSummary = _PeriodSummary(
      _period,
      today,
      _transactions,
      _transfers,
      _accounts,
      null,
    );
  }

  _PeriodSummary get _current {
    final today = _today;
    final account = accountFilterId;
    final cached = _summary;
    if (cached != null &&
        cached.today == today &&
        cached.accountId == account) {
      return cached;
    }
    return _summary = _PeriodSummary(
      _period,
      today,
      _transactions,
      _transfers,
      _accounts,
      account,
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
    this.accountId,
  ) {
    var openingBefore = Money.zero;
    var openingDuring = Money.zero;
    for (final account in accounts) {
      if (accountId != null && account.id != accountId) continue;
      // BAL-2, BAL-4, ACC-4: an opening date that hasn't arrived yet counts
      // nowhere, carried-forward included -- otherwise a future period
      // could carry forward a balance the account itself doesn't have yet.
      if (account.openingDate.isBefore(period.start) &&
          !_dayOf(account.openingDate).isAfter(today)) {
        openingBefore += account.openingBalance;
      } else if (period.contains(account.openingDate) &&
          !_dayOf(account.openingDate).isAfter(today)) {
        openingDuring += account.openingBalance;
      }
    }

    var netBefore = Money.zero;
    for (final tx in newestFirst) {
      if (accountId != null && tx.accountId != accountId) continue;
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

    // A transfer nets to zero across every account, which is why it is no
    // part of income or expense (BAL-1). Within one account it is money in or
    // out, exactly as that account's own balance counts it (ACC-4), so the
    // carried-forward and closing figures have to take it in (ACC-8).
    var transferBefore = Money.zero;
    var transferDuring = Money.zero;
    for (final transfer in newestTransfersFirst) {
      final into = transfer.toAccountId == accountId;
      final outOf = transfer.fromAccountId == accountId;
      if (accountId != null && !into && !outOf) continue;
      if (period.contains(transfer.date)) {
        transfers.add(transfer);
        transfersByDay
            .putIfAbsent(_dayOf(transfer.date), () => [])
            .add(transfer);
      }
      if (accountId == null) continue;
      // Upcoming transfers count nowhere until their date arrives (BAL-4).
      if (_dayOf(transfer.date).isAfter(today)) continue;
      // Both ends when an account transfers to itself, so it still nets zero.
      var signed = Money.zero;
      if (into) signed += transfer.amount;
      if (outOf) signed -= transfer.amount;
      if (period.contains(transfer.date)) {
        transferDuring += signed;
      } else if (transfer.date.isBefore(period.start)) {
        transferBefore += signed;
      }
    }

    carriedForward = openingBefore + netBefore + transferBefore;
    closingBalance =
        carriedForward + openingDuring + income - expense + transferDuring;
  }

  /// The account these totals are for, or null for every account (ACC-6).
  final String? accountId;
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
