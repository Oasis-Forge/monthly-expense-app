import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/budgets_screen.dart';

import 'helpers.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    fake = FakeDB();
    provider = TransactionProvider(
      db: fake,
      clock: () => DateTime(2026, 9, 15),
    );
    await provider.load();
    settings = await testSettings();
  });

  Future<void> showBudgets(WidgetTester tester) async {
    await tester.pumpWidget(testApp(provider, settings, const BudgetsScreen()));
    await tester.pump();
  }

  Future<void> setLimit(WidgetTester tester, String name, String limit) async {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), limit);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('a limit is saved from the current period on (BUD-5)', (
    tester,
  ) async {
    await showBudgets(tester);
    expect(
      find.text(
        'Limits apply from September 2026 on; earlier periods keep theirs.',
      ),
      findsOneWidget,
    );

    await setLimit(tester, 'Food', '300');

    expect(find.text('\$300'), findsOneWidget);
    expect(
      provider.budgetLimit('cat-food', provider.currentPeriod),
      const Money(300000),
    );
    expect(fake.budgets.single.effectiveFrom, DateTime(2026, 9));
  });

  testWidgets('a limit must be a positive amount', (tester) async {
    await showBudgets(tester);

    await setLimit(tester, 'Food', '0');

    expect(find.text('Enter a valid amount'), findsOneWidget);
    expect(fake.budgets, isEmpty);
  });

  testWidgets('removing a budget clears it', (tester) async {
    await provider.setBudget(null, const Money(1000000));
    await showBudgets(tester);

    await tester.tap(find.text('Overall'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(provider.budgetLimit(null, provider.currentPeriod), isNull);
    // Overall plus the three expense categories.
    expect(find.text('No budget'), findsNWidgets(4));
  });

  testWidgets('a failed save shows an error', (tester) async {
    fake.failWrites = true;
    await showBudgets(tester);

    await setLimit(tester, 'Food', '50');

    expect(find.text("Couldn't save the budget. Try again."), findsOneWidget);
  });
}
