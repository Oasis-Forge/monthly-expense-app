import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/category.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
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

/// A subset of the built-in categories, with the same IDs.
List<Category> testCategories() {
  Category category(String id, TransactionType type, String key, String icon) {
    return Category(
      id: id,
      type: type,
      defaultKey: key,
      icon: icon,
      sortOrder: 0,
      createdAt: _created,
      updatedAt: _created,
    );
  }

  return [
    category('cat-food', TransactionType.expense, 'food', '🍔'),
    category('cat-rent', TransactionType.expense, 'rent', '🏠'),
    category('cat-other', TransactionType.expense, 'other', '📦'),
    category('cat-salary', TransactionType.income, 'salary', '💼'),
    category('cat-income-other', TransactionType.income, 'other', '📦'),
  ];
}

/// An in-memory [DBHelper] for tests that don't need sqflite. Set
/// [failWrites] to make every insert and update throw.
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
  Future<List<Category>> fetchCategories() async => [...categories];

  @override
  Future<List<Account>> fetchAccounts() async => [...accounts];

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
}

/// [home] inside a localized [MaterialApp] with [provider] above it.
Widget testApp(TransactionProvider provider, Widget home) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}
