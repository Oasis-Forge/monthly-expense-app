import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/category.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';

final _created = DateTime.utc(2026);

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
    amount: Money((amount * 1000).round()),
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

/// An account whose opening balance ([opening], in whole units) counts from
/// [on].
Account testAccount(String id, {num opening = 0, DateTime? on}) {
  return Account(
    id: id,
    type: id == Account.cashId ? AccountType.cash : AccountType.bank,
    name: id,
    openingBalance: Money((opening * 1000).round()),
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
    List<Category>? categories,
    List<Account>? accounts,
  }) : rows = [...transactions],
       categories = categories ?? testCategories(),
       accounts = accounts ?? [testAccount(Account.cashId)];

  /// Every stored transaction, soft-deleted ones included.
  final List<ExpenseTransaction> rows;

  /// Every stored category, soft-deleted ones included.
  final List<Category> categories;
  final List<Account> accounts;
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
  Future<void> purgeDeletedBefore(DateTime cutoff) async =>
      rows.removeWhere((row) => row.deletedAt?.isBefore(cutoff) ?? false);

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
  Future<List<Account>> fetchAccounts() async => [...accounts];
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
