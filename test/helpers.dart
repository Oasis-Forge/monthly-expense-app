import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/category.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/recurring_rule.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/models/transfer.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';

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
}) {
  return ExpenseTransaction(
    id: id,
    title: title ?? id,
    amount: _money(amount),
    categoryId:
        categoryId ??
        (type == TransactionType.income ? 'cat-salary' : 'cat-food'),
    accountId: Account.cashId,
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
        sortOrder: i,
        createdAt: _created,
        updatedAt: _created,
      ),
  ];
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
  }) : rows = [...transactions],
       transfers = [...transfers],
       categories = categories ?? testCategories(),
       accounts = accounts ?? [testAccount(Account.cashId)],
       budgets = [...budgets],
       rules = [...rules];

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

  /// Every posted or skipped occurrence.
  final List<RecurringOccurrence> occurrences = [];
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

  @override
  Future<void> purgeDeletedBefore(DateTime cutoff) async {
    rows.removeWhere((row) => row.deletedAt?.isBefore(cutoff) ?? false);
    transfers.removeWhere((t) => t.deletedAt?.isBefore(cutoff) ?? false);
  }

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
  Future<void> insertTransfer(Transfer transfer) async {
    _checkWrite();
    transfers.add(transfer);
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
}

/// Settings over in-memory shared_preferences [values], for a US English
/// device.
Future<SettingsProvider> testSettings([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return SettingsProvider(
    await SharedPreferences.getInstance(),
    deviceLocale: 'en_US',
  );
}

/// [home] inside a localized [MaterialApp] with both providers above it.
Widget testApp(
  TransactionProvider provider,
  SettingsProvider settings,
  Widget home,
) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: provider),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
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
