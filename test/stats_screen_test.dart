import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/budgets_screen.dart';
import 'package:monthly_expense_app/screens/stats_screen.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 9, 15);

  Future<void> showStats(
    WidgetTester tester,
    List<ExpenseTransaction> transactions, {
    List<Budget> budgets = const [],
  }) async {
    final provider = TransactionProvider(
      db: FakeDB(transactions: transactions, budgets: budgets),
      clock: () => today,
    );
    await provider.load();
    final settings = await testSettings();
    await tester.pumpWidget(testApp(provider, settings, const StatsScreen()));
    await tester.pump();
  }

  Budget budget(String? categoryId, int limit) {
    return Budget(
      id: categoryId ?? 'overall',
      categoryId: categoryId,
      limit: Money(limit * 1000),
      effectiveFrom: DateTime(2026, 9),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  final spending = [
    testTx('f', TransactionType.expense, 30, DateTime(2026, 9, 5)),
    testTx(
      'r',
      TransactionType.expense,
      10,
      DateTime(2026, 9, 6),
      categoryId: 'cat-rent',
    ),
  ];

  testWidgets('shows the empty state when the period has no expenses', (
    tester,
  ) async {
    await showStats(tester, [
      testTx('s', TransactionType.income, 100, DateTime(2026, 9, 5)),
    ]);

    expect(find.text('Stats — September 2026'), findsOneWidget);
    expect(find.text('No expenses in this period yet.'), findsOneWidget);
    expect(find.text('Budgets'), findsNothing);
  });

  testWidgets('lists spending by category with the total', (tester) async {
    await showStats(tester, spending);

    // The list sits below the chart, outside the 800×600 test screen.
    expect(
      find.text('Total spent: \$40.00', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Food', skipOffstage: false), findsOneWidget);
    expect(find.text('Rent', skipOffstage: false), findsOneWidget);
  });

  testWidgets('budget bars show what is left per day or how much is over', (
    tester,
  ) async {
    await showStats(
      tester,
      spending,
      budgets: [
        budget(null, 1000),
        budget('cat-food', 46),
        budget('cat-rent', 5),
      ],
    );

    expect(find.text('Budgets'), findsOneWidget);
    // September 15–30 is 16 days, today included.
    expect(find.text('\$960.00 left · \$60.00 a day'), findsOneWidget);
    expect(find.text('\$30.00 of \$46.00'), findsOneWidget);
    expect(find.text('\$16.00 left · \$1.00 a day'), findsOneWidget);
    expect(find.text('Over by \$5.00'), findsOneWidget);
  });

  testWidgets('the budgets button opens the budgets screen', (tester) async {
    await showStats(tester, spending);

    await tester.tap(find.byTooltip('Budgets'));
    await tester.pumpAndSettle();

    expect(find.byType(BudgetsScreen), findsOneWidget);
  });
}
