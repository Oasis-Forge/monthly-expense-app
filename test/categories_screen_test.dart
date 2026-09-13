import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/categories_screen.dart';

import 'helpers.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    // Food has a transaction; Rent and Other don't.
    fake = FakeDB(
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

  List<String> expenseIds() => [
    for (final c in provider.categoriesFor(TransactionType.expense)) c.id,
  ];

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
    expect(expenseIds(), hasLength(3));
  });

  testWidgets('cancelling the dialog changes nothing', (tester) async {
    await showCategories(tester);

    await tester.tap(find.byTooltip('Add category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(CategoryDialog), findsNothing);
    expect(expenseIds(), hasLength(3));
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

  testWidgets('the income tab lists income categories', (tester) async {
    await showCategories(tester);

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Rent'), findsNothing);
  });

  testWidgets('dragging a handle reorders categories (CAT-3)', (tester) async {
    await showCategories(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.drag_handle).last),
    );
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(expenseIds(), ['cat-other', 'cat-food', 'cat-rent']);
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

  testWidgets('an unused category can be deleted (CAT-4)', (tester) async {
    await showCategories(tester);

    await tester.tap(find.byTooltip('Show menu').at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(provider.categoryById('cat-rent'), isNull);
    expect(find.text('Rent'), findsNothing);
  });

  testWidgets('a failed change shows an error', (tester) async {
    await showCategories(tester);
    fake.failWrites = true;

    await tester.tap(find.byTooltip('Show menu').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't save the category. Try again."), findsOneWidget);
    expect(provider.categoryById('cat-food')!.archivedAt, isNull);
  });
}
