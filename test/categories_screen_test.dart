import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/categories_screen.dart';

import 'helpers.dart';

void main() {
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    // Food has a transaction; Rent and Other don't.
    final fake = FakeDB(
      transactions: [
        testTx('a', TransactionType.expense, 5, DateTime(2026, 9, 1)),
      ],
    );
    provider = TransactionProvider(
      db: fake,
      clock: () => DateTime(2026, 9, 15),
    );
    await provider.load();
    settings = await testSettings();
  });

  Future<void> showCategories(WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(provider, settings, const CategoriesScreen()),
    );
    await tester.pump();
  }

  testWidgets('adds a custom category with an icon (CAT-3)', (tester) async {
    await showCategories(tester);

    await tester.tap(find.byTooltip('Add category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Coffee');
    await tester.tap(find.text('☕'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final added = provider.categoriesFor(TransactionType.expense).last;
    expect((added.name, added.icon), ('Coffee', '☕'));
    expect(find.text('Coffee'), findsOneWidget);
  });

  testWidgets('a name already in use is rejected', (tester) async {
    await showCategories(tester);

    await tester.tap(find.byTooltip('Add category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'food');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('That name is already used'), findsOneWidget);
    expect(provider.categoriesFor(TransactionType.expense), hasLength(3));
  });

  testWidgets('renaming a default keeps its ID', (tester) async {
    await showCategories(tester);

    await tester.tap(find.text('Rent'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Housing');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(provider.categoryById('cat-rent')!.name, 'Housing');
    expect(find.text('Housing'), findsOneWidget);
  });

  testWidgets('a used category can be archived but not deleted (CAT-4)', (
    tester,
  ) async {
    await showCategories(tester);

    await tester.tap(find.byTooltip('Show menu').first);
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsNothing);
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(provider.categoryById('cat-food')!.archivedAt, isNotNull);
    expect(find.text('Archived'), findsOneWidget);

    await tester.tap(find.text('Unarchive'));
    await tester.pumpAndSettle();

    expect(provider.categoryById('cat-food')!.archivedAt, isNull);
  });
}
