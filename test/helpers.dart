import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/l10n/languages.dart';
import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/backup.dart';
import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/category.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/note.dart';
import 'package:monthly_expense_app/models/reminders.dart';
import 'package:monthly_expense_app/models/recurring_rule.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/models/transfer.dart';
import 'package:monthly_expense_app/providers/ads_provider.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/services/ad_service.dart';
import 'package:monthly_expense_app/services/ads_config.dart';
import 'package:monthly_expense_app/services/attachment_service.dart';
import 'package:monthly_expense_app/services/authenticator.dart';
import 'package:monthly_expense_app/services/backup_files.dart';
import 'package:monthly_expense_app/services/backup_service.dart';
import 'package:monthly_expense_app/services/purchase_service.dart';
import 'package:monthly_expense_app/services/reminder_service.dart';
import 'package:monthly_expense_app/services/review_service.dart';
import 'package:monthly_expense_app/services/update_service.dart';
import 'package:monthly_expense_app/services/shortcut_service.dart';

final _created = DateTime.utc(2026);

Money _money(num amount) => Money((amount * 1000).round());

/// A transaction with test defaults. [amount] is in whole currency units.
ExpenseTransaction testTx(
  String id,
  TransactionType type,
  num amount,
  DateTime date, {
  String? title,
  String? note,
  String? categoryId,
  String? accountId,
}) {
  return ExpenseTransaction(
    id: id,
    title: title ?? id,
    amount: _money(amount),
    categoryId:
        categoryId ??
        (type == TransactionType.income ? 'cat-salary' : 'cat-food'),
    accountId: accountId ?? Account.cashId,
    type: type,
    date: date,
    note: note,
    createdAt: _created,
    updatedAt: _created,
  );
}

/// A transfer of [amount] whole units from one account to another.
Transfer testTransfer(
  String id,
  String from,
  String to,
  num amount,
  DateTime date,
) {
  return Transfer(
    id: id,
    fromAccountId: from,
    toAccountId: to,
    amount: _money(amount),
    date: date,
    createdAt: _created,
    updatedAt: _created,
  );
}

/// A monthly Cash expense rule titled [id], for [amount] whole units, in the
/// Rent category, starting on [start].
RecurringRule testRule(
  String id,
  num amount,
  DateTime start, {
  bool autoPost = false,
}) {
  return RecurringRule(
    id: id,
    title: id,
    amount: _money(amount),
    categoryId: 'cat-rent',
    accountId: Account.cashId,
    type: TransactionType.expense,
    frequency: RecurrenceFrequency.month,
    interval: 1,
    startDate: start,
    endType: RecurrenceEnd.never,
    autoPost: autoPost,
    activeFrom: start,
    createdAt: _created,
    updatedAt: _created,
  );
}

/// An account named [id] whose opening balance ([opening], in whole units)
/// counts from [on].
Account testAccount(String id, {num opening = 0, DateTime? on}) {
  return Account(
    id: id,
    type: id == Account.cashId ? AccountType.cash : AccountType.bank,
    name: id,
    openingBalance: _money(opening),
    openingDate: on ?? DateTime(2026),
    sortOrder: 0,
    createdAt: _created,
    updatedAt: _created,
  );
}

/// A subset of the built-in categories, with the same IDs, in display order.
List<Category> testCategories() {
  const defaults = [
    ('cat-food', TransactionType.expense, 'food', '🍔'),
    ('cat-rent', TransactionType.expense, 'rent', '🏠'),
    ('cat-other', TransactionType.expense, 'other', '📦'),
    ('cat-salary', TransactionType.income, 'salary', '💼'),
    ('cat-income-other', TransactionType.income, 'other', '📦'),
  ];
  return [
    for (var i = 0; i < defaults.length; i++)
      Category(
        id: defaults[i].$1,
        type: defaults[i].$2,
        defaultKey: defaults[i].$3,
        icon: defaults[i].$4,
        // As the schema step hands them out, so a category's colour and its
        // place in the list are two different things in tests too (CAT-6).
        color: categoryPalette[i],
        sortOrder: i,
        createdAt: _created,
        updatedAt: _created,
      ),
  ];
}

/// A note with test defaults. [amount], when given, is in whole currency
/// units.
Note testNote(
  String id,
  String text, {
  DateTime? dueDate,
  DateTime? reminderAt,
  num? amount,
  String? categoryId,
  DateTime? doneAt,
}) {
  return Note(
    id: id,
    text: text,
    dueDate: dueDate,
    reminderAt: reminderAt,
    amount: amount == null ? null : _money(amount),
    categoryId: categoryId,
    doneAt: doneAt,
    createdAt: _created,
    updatedAt: _created,
  );
}

/// An in-memory [DBHelper] for tests that don't need sqflite. Set
/// [failWrites] to make every write throw.
class FakeDB extends DBHelper {
  FakeDB({
    List<ExpenseTransaction> transactions = const [],
    List<Transfer> transfers = const [],
    List<Category>? categories,
    List<Account>? accounts,
    List<Budget> budgets = const [],
    List<RecurringRule> rules = const [],
    List<Note> notes = const [],
  }) : rows = [...transactions],
       transfers = [...transfers],
       categories = categories ?? testCategories(),
       accounts = accounts ?? [testAccount(Account.cashId)],
       budgets = [...budgets],
       rules = [...rules],
       notes = [...notes];

  /// Every stored transaction, soft-deleted ones included.
  final List<ExpenseTransaction> rows;

  /// Every stored transfer, soft-deleted ones included.
  final List<Transfer> transfers;

  /// Every stored category, soft-deleted ones included.
  final List<Category> categories;

  /// Every stored account, soft-deleted ones included.
  final List<Account> accounts;

  /// Every stored budget version.
  final List<Budget> budgets;

  /// Every stored recurring rule, soft-deleted ones included.
  final List<RecurringRule> rules;

  /// Every stored note, soft-deleted ones included.
  final List<Note> notes;

  /// Every posted or skipped occurrence.
  final List<RecurringOccurrence> occurrences = [];

  /// Every ID ever purged from the trash, and its `updated_at` when purged
  /// (DEL-3, rules-1-5#7).
  final Map<String, String> purgedIds = {};
  bool failWrites = false;

  void _checkWrite() {
    if (failWrites) throw StateError('write failed');
  }

  @override
  Future<List<ExpenseTransaction>> fetchTransactions() async => [
    for (final row in rows)
      if (row.deletedAt == null) row,
  ];

  @override
  Future<List<ExpenseTransaction>> fetchDeletedTransactions() async => [
    for (final row in rows)
      if (row.deletedAt != null) row,
  ]..sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));

  /// Records a purge like the real `purged_records` table does: the LATEST
  /// `updated_at` for [id] wins, not the first (review-data-1). A purge
  /// with an earlier `updated_at` than one already on file leaves the
  /// existing, later tombstone in place.
  void _recordPurge(String id, String updatedAt) {
    final existing = purgedIds[id];
    if (existing == null || existing.compareTo(updatedAt) < 0) {
      purgedIds[id] = updatedAt;
    }
  }

  @override
  Future<List<String>> purgeDeletedBefore(DateTime cutoff) async {
    bool old(DateTime? deletedAt) => deletedAt?.isBefore(cutoff) ?? false;
    final going = [
      for (final row in rows)
        if (old(row.deletedAt)) row,
    ];
    for (final row in going) {
      _recordPurge(row.id, row.updatedAt.toUtc().toIso8601String());
    }
    for (final t in transfers) {
      if (old(t.deletedAt)) {
        _recordPurge(t.id, t.updatedAt.toUtc().toIso8601String());
      }
    }
    for (final n in notes) {
      if (old(n.deletedAt)) {
        _recordPurge(n.id, n.updatedAt.toUtc().toIso8601String());
      }
    }
    rows.removeWhere((row) => old(row.deletedAt));
    transfers.removeWhere((t) => old(t.deletedAt));
    notes.removeWhere((n) => old(n.deletedAt));
    return [
      for (final row in going) ...[?row.photoFile, ?row.voiceFile],
    ];
  }

  @override
  Future<Map<String, String>> fetchPurgedIds() async => {...purgedIds};

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
  Future<List<Category>> fetchCategories() async => [
    for (final category in categories)
      if (category.deletedAt == null) category,
  ];

  @override
  Future<void> insertCategory(Category category) async {
    _checkWrite();
    categories.add(category);
  }

  @override
  Future<void> updateCategories(List<Category> changed) async {
    _checkWrite();
    for (final category in changed) {
      categories[categories.indexWhere((c) => c.id == category.id)] = category;
    }
  }

  @override
  Future<List<Account>> fetchAccounts() async => [
    for (final account in accounts)
      if (account.deletedAt == null) account,
  ];

  @override
  Future<void> insertAccount(Account account) async {
    _checkWrite();
    accounts.add(account);
  }

  @override
  Future<void> updateAccounts(List<Account> changed) async {
    _checkWrite();
    for (final account in changed) {
      accounts[accounts.indexWhere((a) => a.id == account.id)] = account;
    }
  }

  @override
  Future<List<Transfer>> fetchTransfers() async => [
    for (final transfer in transfers)
      if (transfer.deletedAt == null) transfer,
  ];

  @override
  Future<List<Transfer>> fetchDeletedTransfers() async => [
    for (final transfer in transfers)
      if (transfer.deletedAt != null) transfer,
  ]..sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));

  @override
  Future<void> insertTransfer(Transfer transfer) async {
    _checkWrite();
    transfers.add(transfer);
  }

  @override
  Future<void> insertImported({
    required List<ExpenseTransaction> transactions,
    required List<Transfer> transfers,
  }) async {
    // One check, like the real one's single database transaction: either the
    // lot lands or none of it does (IMP-1).
    _checkWrite();
    rows.addAll(transactions);
    this.transfers.addAll(transfers);
  }

  @override
  Future<void> updateTransfer(Transfer transfer) async {
    _checkWrite();
    transfers[transfers.indexWhere((t) => t.id == transfer.id)] = transfer;
  }

  @override
  Future<List<Budget>> fetchBudgets() async => [
    for (final budget in budgets)
      if (budget.deletedAt == null) budget,
  ];

  @override
  Future<void> insertBudget(Budget budget) async {
    _checkWrite();
    budgets.add(budget);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    _checkWrite();
    budgets[budgets.indexWhere((b) => b.id == budget.id)] = budget;
  }

  @override
  Future<List<RecurringRule>> fetchRecurringRules() async => [
    for (final rule in rules)
      if (rule.deletedAt == null) rule,
  ];

  @override
  Future<void> insertRecurringRule(RecurringRule rule) async {
    _checkWrite();
    rules.add(rule);
  }

  @override
  Future<void> updateRecurringRule(RecurringRule rule) async {
    _checkWrite();
    rules[rules.indexWhere((r) => r.id == rule.id)] = rule;
  }

  @override
  Future<List<Note>> fetchNotes() async => [
    for (final note in notes)
      if (note.deletedAt == null) note,
  ];

  @override
  Future<List<Note>> fetchDeletedNotes() async => [
    for (final note in notes)
      if (note.deletedAt != null) note,
  ]..sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));

  @override
  Future<void> insertNote(Note note) async {
    _checkWrite();
    notes.add(note);
  }

  @override
  Future<void> updateNote(Note note) async {
    _checkWrite();
    notes[notes.indexWhere((n) => n.id == note.id)] = note;
  }

  @override
  Future<List<RecurringOccurrence>> fetchOccurrences() async => [
    ...occurrences,
  ];

  @override
  Future<void> insertOccurrence(RecurringOccurrence occurrence) async {
    _checkWrite();
    if (!occurrences.any((o) => o.key == occurrence.key)) {
      occurrences.add(occurrence);
    }
  }

  @override
  Future<void> postOccurrence(
    ExpenseTransaction tx,
    RecurringOccurrence occurrence,
  ) async {
    _checkWrite();
    if (occurrences.any((o) => o.key == occurrence.key)) {
      throw StateError('occurrence already handled');
    }
    occurrences.add(occurrence);
    rows.add(tx);
  }

  @override
  Future<BackupTables> exportTables() async => {
    'categories': [for (final category in categories) category.toMap()],
    'accounts': [for (final account in accounts) account.toMap()],
    'transactions': [for (final tx in rows) tx.toMap()],
    'transfers': [for (final transfer in transfers) transfer.toMap()],
    'budgets': [for (final budget in budgets) budget.toMap()],
    'recurring_rules': [for (final rule in rules) rule.toMap()],
    'recurring_occurrences': [
      for (final occurrence in occurrences) occurrence.toMap(),
    ],
    'notes': [for (final note in notes) note.toMap()],
  };

  @override
  Future<void> replaceAllData(BackupTables tables) async {
    _checkWrite();
    List<T> read<T>(String table, T Function(Map<String, Object?>) fromMap) => [
      for (final row in tables[table] ?? const []) fromMap(row),
    ];
    categories
      ..clear()
      ..addAll(read('categories', Category.fromMap));
    accounts
      ..clear()
      ..addAll(read('accounts', Account.fromMap));
    rows
      ..clear()
      ..addAll(read('transactions', ExpenseTransaction.fromMap));
    transfers
      ..clear()
      ..addAll(read('transfers', Transfer.fromMap));
    budgets
      ..clear()
      ..addAll(read('budgets', Budget.fromMap));
    rules
      ..clear()
      ..addAll(read('recurring_rules', RecurringRule.fromMap));
    occurrences
      ..clear()
      ..addAll(read('recurring_occurrences', RecurringOccurrence.fromMap));
    notes
      ..clear()
      ..addAll(read('notes', Note.fromMap));
  }

  @override
  Future<void> applyMerge(MergePlan plan) async {
    _checkWrite();
    final tables = await exportTables();
    for (final MapEntry(key: table, value: added) in plan.inserts.entries) {
      tables[table]!.addAll(added);
    }
    for (final MapEntry(key: table, value: updated) in plan.updates.entries) {
      final existing = tables[table]!;
      for (final row in updated) {
        existing[existing.indexWhere((r) => r['id'] == row['id'])] = row;
      }
    }
    await replaceAllData(tables);
  }

  @override
  Future<BackupTables> upgradeBackupTables(
    BackupTables tables,
    int fromVersion,
  ) async => tables;
}

/// In-memory [BackupFiles]: records saved files and serves [toOpen] to the
/// open dialog.
class FakeBackupFiles implements BackupFiles {
  /// Files the user saved, by name.
  final Map<String, Uint8List> saved = {};

  /// Automatic backups kept on the "device", by name.
  final Map<String, String> kept = {};

  /// What the open dialog returns; null means the user cancels.
  Uint8List? toOpen;

  /// Makes the save dialog act as if the user cancelled.
  bool cancelSave = false;

  /// Makes saving and opening throw.
  bool fail = false;

  @override
  Future<bool> save(
    String fileName,
    Uint8List bytes, {
    required String mimeType,
  }) async {
    if (fail) throw StateError('save failed');
    if (cancelSave) return false;
    saved[fileName] = bytes;
    return true;
  }

  @override
  Future<Uint8List?> open() async {
    if (fail) throw StateError('open failed');
    return toOpen;
  }

  @override
  Future<List<String>> listKept() async => kept.keys.toList();

  @override
  Future<String> readKept(String name) async => kept[name]!;

  @override
  Future<void> writeKept(String name, String contents) async {
    if (fail) throw StateError('write failed');
    kept[name] = contents;
  }

  @override
  Future<void> deleteKept(String name) async {
    kept.remove(name);
  }
}

/// An [Authenticator] that answers with [result] when [available].
class FakeAuthenticator implements Authenticator {
  FakeAuthenticator({this.available = true, this.result = AuthResult.success});

  bool available;
  AuthResult result;

  /// How many times the user was asked to authenticate.
  int requests = 0;

  /// What the last call passed, so a test can check the prompt is built
  /// from the caller's own translations rather than left in English
  /// (LANG-2, LOCK-1).
  String? lastReason;
  String? lastHint;
  String? lastCancelButton;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<AuthResult> authenticate(
    String reason, {
    String? hint,
    String? cancelButton,
  }) async {
    requests++;
    lastReason = reason;
    lastHint = hint;
    lastCancelButton = cancelButton;
    return available ? result : AuthResult.unavailable;
  }
}

/// A [ReminderService] that records calls instead of touching the device.
/// [permissionGranted] answers [requestPermission].
class FakeReminderService implements ReminderService {
  FakeReminderService({this.permissionGranted = true});

  bool permissionGranted;

  /// Notes currently scheduled, by ID, with the [appLockOn] they were
  /// scheduled with.
  final Map<String, bool> scheduled = {};

  /// How many times [requestPermission] was called.
  int permissionRequests = 0;

  /// The app's own reminders currently scheduled, in the order planned, and
  /// the [appLockOn] they were scheduled with (NUDGE-1).
  List<PlannedReminder> nudges = const [];
  bool nudgesLocked = false;

  /// How many times a plan replaced the one before it, so a test can tell a
  /// reschedule from a plan that simply stayed the same.
  int nudgePlans = 0;

  @override
  Future<void> scheduleNudges(
    List<PlannedReminder> plan, {
    required bool appLockOn,
    required Locale locale,
  }) async {
    nudges = plan;
    nudgesLocked = appLockOn;
    nudgePlans++;
  }

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  /// The same flag [requestPermission] answers with: a phone that already
  /// refuses new requests is also a phone whose existing notifications are
  /// blocked (NUDGE-7).
  @override
  Future<bool> areNotificationsEnabled() async => permissionGranted;

  @override
  Future<void> schedule(
    Note note, {
    required bool appLockOn,
    required Locale locale,
  }) async {
    if (note.reminderAt == null || note.isDone || note.deletedAt != null) {
      scheduled.remove(note.id);
    } else {
      scheduled[note.id] = appLockOn;
    }
  }

  @override
  Future<void> cancel(Note note) async {
    scheduled.remove(note.id);
  }
}

/// A [BackupService] over [db] with fake files and a fixed app version.
BackupService testBackupService(
  DBHelper db, {
  BackupFiles? files,
  DateTime Function()? clock,
  AttachmentService? attachments,
}) {
  return BackupService(
    db: db,
    files: files ?? FakeBackupFiles(),
    clock: clock,
    attachments: attachments ?? FakeAttachments(),
    appVersion: () async => '1.0.0+1',
  );
}

/// Settings over in-memory shared_preferences [values], for a US English
/// device, with [clock] as "now".
Future<SettingsProvider> testSettings([
  Map<String, Object> values = const {},
  DateTime Function()? clock,
]) async {
  SharedPreferences.setMockInitialValues(values);
  return SettingsProvider(
    await SharedPreferences.getInstance(),
    deviceLocale: 'en_US',
    clock: clock,
  );
}

/// Stands in for the ad network. Nothing fills unless [fills] is set, and
/// nothing is ever asked for unless [canStart] is true, so a test that says
/// nothing about ads sees none.
class FakeAdService implements AdService {
  FakeAdService({
    this.canStart = false,
    this.fills = false,
    this.height = 50,
    this.privacyOptionsRequired = false,
    this.interstitialFills = false,
  });

  /// What `start` answers: whether ads may be requested at all (ADS-4).
  bool canStart;

  /// Whether a request comes back with a banner, or empty (ADS-2).
  bool fills;
  double height;

  @override
  bool privacyOptionsRequired;

  /// Every placement asked for, in order, and how many are on screen now.
  final requested = <AdPlacement>[];
  int live = 0;
  int privacyOptionsShown = 0;
  bool started = false;

  @override
  Future<bool> start() async {
    started = true;
    return canStart;
  }

  @override
  Future<void> showPrivacyOptions() async => privacyOptionsShown++;

  /// Whether a full-screen request comes back with one (ADS-13).
  bool interstitialFills;

  /// How many full-screen ads were asked for, shown, and let go unshown.
  int interstitialsRequested = 0;
  int interstitialsShown = 0;
  int interstitialsDropped = 0;

  @override
  Future<LoadedInterstitial?> loadInterstitial() async {
    interstitialsRequested++;
    if (!canStart || !interstitialFills) return null;
    return LoadedInterstitial(
      show: () async => interstitialsShown++,
      dispose: () async => interstitialsDropped++,
    );
  }

  @override
  Future<double?> bannerHeight(double width) async => canStart ? height : null;

  /// Set to make a request hang until [deliver] is called, which is how the
  /// races are tested: a screen closed, or resized, while an ad is in flight.
  bool holdLoads = false;
  final _waiting = <Completer<LoadedBanner?>>[];

  /// Answers every held request.
  void deliver() {
    for (final request in _waiting) {
      request.complete(fills ? _banner() : null);
    }
    _waiting.clear();
  }

  LoadedBanner _banner({AdPlacement placement = AdPlacement.home}) {
    live++;
    return LoadedBanner(
      // A real banner is a platform view, which a widget test can't host, so
      // this stands in for one at the same height.
      view: SizedBox(key: ValueKey('ad-${placement.name}'), height: height),
      height: height,
      dispose: () async => live--,
    );
  }

  @override
  Future<LoadedBanner?> loadBanner(AdPlacement placement, double width) async {
    requested.add(placement);
    if (holdLoads) {
      final request = Completer<LoadedBanner?>();
      _waiting.add(request);
      return request.future;
    }
    if (!fills) return null;
    return _banner(placement: placement);
  }
}

/// Stands in for the store (PAY-1, PAY-8). Starts with nothing to sell, the
/// way a device with no product configured answers.
class FakePurchases extends PurchaseService {
  FakePurchases({
    this.stage = PurchaseStage.unavailable,
    this.price,
    this.error,
    this.owns = false,
  });

  /// What the store turns out to know once it is actually asked: [start]
  /// settles to owned before it returns, which is the only ordering a device
  /// ever produces — a receipt is never in hand before the store answers
  /// (PAY-5). Being born owned is the ordering no device has.
  bool owns;

  @override
  PurchaseStage stage;

  @override
  String? price;

  /// What [lastError] answers.
  String? error;

  int buys = 0;
  int restores = 0;
  bool started = false;

  @override
  String? get lastError => error;

  /// Moves the store on, as the purchase stream would.
  void settle(PurchaseStage next, {String? error}) {
    stage = next;
    this.error = error;
    notifyListeners();
  }

  @override
  Future<void> start() async {
    started = true;
    // The contract on PurchaseService.start: it does not return until the
    // store has answered (ADS-8).
    if (owns) settle(PurchaseStage.owned);
  }

  @override
  Future<void> buy() async => buys++;

  @override
  Future<void> restore() async => restores++;
}

/// [home] inside a localized [MaterialApp] with the app's providers above
/// it. [backup] and [authenticator] default to fakes.
Widget testApp(
  TransactionProvider provider,
  SettingsProvider settings,
  Widget home, {
  BackupService? backup,
  Authenticator? authenticator,
  ReminderService? reminders,
  AttachmentService? attachments,
  AdService? ads,
  PurchaseService? purchases,
  ReviewService? reviews,
  UpdateService? updates,
  ValueListenable<bool>? locked,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: provider),
      ChangeNotifierProvider(
        create: (_) => AdsProvider(
          settings,
          ads: ads ?? FakeAdService(),
          purchases: purchases ?? FakePurchases(),
          locked: locked,
        )..start(),
      ),
      Provider<BackupService>.value(
        value: backup ?? testBackupService(FakeDB()),
      ),
      Provider<Authenticator>.value(
        value: authenticator ?? FakeAuthenticator(),
      ),
      Provider<ReminderService>.value(
        value: reminders ?? FakeReminderService(),
      ),
      Provider<AttachmentService>.value(
        value: attachments ?? FakeAttachments(),
      ),
      // RATE-5: nothing asks for a rating unless a test says it may.
      Provider<ReviewService>.value(
        value: reviews ?? FakeReviews(supported: false),
      ),
      Provider<UpdateService>.value(
        value: updates ?? FakeUpdates(supported: false),
      ),
    ],
    // Like the app, the language follows the settings (LANG-1).
    child: Consumer<SettingsProvider>(
      builder: (context, settings, _) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: settings.locale,
        localeListResolutionCallback: (locales, _) => resolveAppLocale(locales),
        home: home,
      ),
    ),
  );
}

/// Sizes the test screen like a phone (360×800), where forms with the keypad
/// are laid out as users see them. Resets after the test.
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Scrolls the open form from the top until [finder] is built and visible.
/// Forms are lazy lists, so fields off screen may not exist yet.
Future<void> revealInForm(WidgetTester tester, Finder finder) async {
  final scrollable = find
      .descendant(of: find.byType(Form), matching: find.byType(Scrollable))
      .first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(finder, 100, scrollable: scrollable);
  await tester.pumpAndSettle();
}

/// [AttachmentFiles] over a temporary folder, standing in for the photo
/// picker and the microphone (ATT-2).
class FakeAttachmentFiles implements AttachmentFiles {
  FakeAttachmentFiles(this.dir);

  final Directory dir;

  /// The path the picker hands back; null means the user backed out.
  String? toPick;

  /// Whether the microphone is allowed.
  bool micAllowed = true;

  /// Where each photo was asked for, in order.
  final List<PhotoSource> picked = [];

  String? recordingTo;
  bool cancelled = false;

  @override
  Future<String?> pickPhoto(PhotoSource source) async {
    picked.add(source);
    return toPick;
  }

  @override
  Future<bool> startRecording(String path) async {
    if (!micAllowed) return false;
    recordingTo = path;
    await File(path).writeAsBytes(const [1, 2, 3]);
    return true;
  }

  @override
  Future<String?> stopRecording() async => recordingTo;

  @override
  Future<void> play(String path) async {
    played.add(path);
    playingNow.add(true);
  }

  @override
  Future<void> pausePlaying() async => playingNow.add(false);

  @override
  Stream<bool> get playing => playingNow.stream;

  /// Paths played, in order.
  final List<String> played = [];

  final playingNow = StreamController<bool>.broadcast();

  @override
  Future<void> cancelRecording() async {
    cancelled = true;
  }

  @override
  Future<Directory> directory() async => dir.create(recursive: true);
}

/// An [AttachmentService] over [dir], with the fake picker and recorder it
/// uses so a test can steer them. Names count up: file1.jpg, file2.m4a.
({AttachmentService service, FakeAttachmentFiles files}) testAttachments(
  Directory dir,
) {
  final files = FakeAttachmentFiles(dir);
  var next = 0;
  return (
    service: AttachmentService(files: files, newName: () => 'file${++next}'),
    files: files,
  );
}

/// An [AttachmentService] that keeps its files in memory, for widget tests:
/// a pumped test can't wait on real file I/O. [filePath] is what [path]
/// hands back, so an [Image] in the tree has something real to load.
class FakeAttachments implements AttachmentService {
  FakeAttachments({this.filePath = 'no-such-photo.jpg'});

  final String filePath;
  final Map<String, List<int>> stored = {};

  /// Where each photo was asked for, and each voice note played, in order.
  final List<PhotoSource> picked = [];
  final List<String> played = [];

  /// Whether the picker has a photo, and the microphone is allowed.
  bool hasPhoto = true;
  bool micAllowed = true;

  final _playing = StreamController<bool>.broadcast();
  String? _recording;
  int _next = 0;

  /// Whether a recording in progress was ever cancelled (ATT-4, ATT-5).
  bool cancelled = false;

  /// Makes [stopRecording] throw once, the way a `PlatformException` from
  /// the recorder plugin would after an audio-focus loss or a phone call
  /// (review-money-5).
  bool stopThrows = false;

  String _name(String extension) => 'file${++_next}.$extension';

  @override
  Future<String?> addPhoto(PhotoSource source) async {
    picked.add(source);
    if (!hasPhoto) return null;
    final name = _name('jpg');
    stored[name] = const [1];
    return name;
  }

  @override
  Future<bool> startRecording() async {
    if (!micAllowed) return false;
    _recording = _name('m4a');
    return true;
  }

  @override
  Future<String?> stopRecording() async {
    if (stopThrows) {
      stopThrows = false;
      throw StateError('stop failed');
    }
    final name = _recording;
    _recording = null;
    if (name != null) stored[name] = const [2];
    return name;
  }

  @override
  Future<void> cancelRecording() async {
    cancelled = true;
    stored.remove(_recording);
    _recording = null;
  }

  @override
  Future<void> play(String name) async {
    played.add(name);
    _playing.add(true);
  }

  @override
  Future<void> pausePlaying() async => _playing.add(false);

  @override
  Stream<bool> get playing => _playing.stream;

  @override
  Future<String> path(String name) async => filePath;

  @override
  Future<bool> exists(String name) async => stored.containsKey(name);

  @override
  Future<Uint8List> read(String name) async =>
      Uint8List.fromList(stored[name]!);

  @override
  Future<void> write(String name, List<int> bytes) async =>
      stored[name] = bytes;

  @override
  Future<void> delete(String? name) async => stored.remove(name);

  @override
  Future<void> deleteAll(Iterable<String?> names) async {
    names.forEach(stored.remove);
  }

  @override
  Future<int> totalBytes() async =>
      stored.values.fold<int>(0, (total, bytes) => total + bytes.length);
}

/// Records the haptic feedback the app asks the phone for (HAP-1–HAP-4),
/// newest last, as `HapticFeedbackType.selectionClick` and the like. The
/// channel is put back at the end of the test.
List<String> captureHaptics() {
  final asked = <String>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'HapticFeedback.vibrate') {
      asked.add(call.arguments as String);
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return asked;
}

/// The store's rating sheet, counted rather than shown (RATE-2). Unsupported
/// by default, so a test only meets it when it asks to.
class FakeReviews implements ReviewService {
  FakeReviews({this.supported = true, this.appVersion = '1.0.0+1'});

  @override
  final bool supported;

  /// What [version] answers, which is what "once per version" is counted
  /// against (RATE-4).
  final String appVersion;

  /// How many times the sheet was asked for.
  int asked = 0;

  @override
  Future<String> version() async => appVersion;

  @override
  Future<void> ask() async => asked++;
}

/// Play's flexible update flow, answered from fields instead of from the
/// store (UPD-1). Unsupported by default, so a test only meets it when it
/// asks to.
class FakeUpdates implements UpdateService {
  FakeUpdates({
    this.supported = true,
    this.offered = false,
    this.downloads = true,
    bool downloaded = false,
  }) : alreadyDownloaded = downloaded;

  @override
  final bool supported;

  /// Whether Play is holding a newer version.
  final bool offered;

  /// Whether the background download finishes, rather than being declined
  /// or failing.
  final bool downloads;

  /// Whether Play already has a finished download waiting from an earlier
  /// run (UPD-1), so [download] should never be called.
  final bool alreadyDownloaded;

  /// How many times Play was asked whether anything is waiting.
  int checked = 0;

  /// How many times the download was started.
  int started = 0;

  /// How many times the restart was asked for.
  int installed = 0;

  @override
  Future<bool> available() async {
    checked++;
    return offered;
  }

  @override
  Future<bool> download() async {
    started++;
    return downloads;
  }

  @override
  Future<bool> downloaded() async => alreadyDownloaded;

  @override
  Future<void> install() async => installed++;
}

/// The app icon's long-press menu, kept in a list instead of on an icon
/// (NAV-8).
class FakeShortcuts implements ShortcutService {
  FakeShortcuts({this.supported = true});

  @override
  final bool supported;

  /// The menu as it was last written, newest set only.
  List<Shortcut> items = const [];

  void Function(String type)? _chosen;

  @override
  void onSelected(void Function(String type) handler) => _chosen = handler;

  @override
  Future<void> setItems(List<Shortcut> items) async => this.items = items;

  /// Chooses one of them, as a long press on the icon would.
  void choose(String type) => _chosen?.call(type);
}
