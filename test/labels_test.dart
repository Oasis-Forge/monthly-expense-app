import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/l10n/labels.dart';
import 'package:monthly_expense_app/models/category.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'a row falls back from title to note to category name (ADD-1)',
    () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final now = DateTime(2026, 9, 15);

      ExpenseTransaction tx({String? title, String? note}) =>
          ExpenseTransaction(
            id: 'tx',
            title: title,
            note: note,
            amount: const Money(1000),
            categoryId: 'cat-food',
            accountId: 'acc-cash',
            type: TransactionType.expense,
            date: now,
            createdAt: now,
            updatedAt: now,
          );

      final food = Category(
        id: 'cat-food',
        type: TransactionType.expense,
        defaultKey: 'food',
        icon: 'restaurant',
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );

      // A title wins over everything else.
      expect(tx(title: 'Lunch', note: 'with team').label(food, l10n), 'Lunch');

      // No title: the note shows.
      expect(tx(note: 'with team').label(food, l10n), 'with team');

      // No title and no note: the category name shows.
      expect(tx().label(food, l10n), l10n.categoryFood);

      // No title, no note, and no category (deleted, CAT-4): empty string.
      expect(tx().label(null, l10n), '');
    },
  );
}
