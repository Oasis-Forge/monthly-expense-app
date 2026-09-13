import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/stats_screen.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 9, 15);

  Future<void> showStats(
    WidgetTester tester,
    List<ExpenseTransaction> transactions,
  ) async {
    final provider = TransactionProvider(
      db: FakeDB(transactions: transactions),
      clock: () => today,
    );
    await provider.load();
    await tester.pumpWidget(testApp(provider, const StatsScreen()));
    await tester.pump();
  }

  testWidgets('shows the empty state when the period has no expenses', (
    tester,
  ) async {
    await showStats(tester, [
      testTx('s', TransactionType.income, 100, DateTime(2026, 9, 5)),
    ]);

    expect(find.text('Stats — September 2026'), findsOneWidget);
    expect(find.text('No expenses in this period yet.'), findsOneWidget);
  });

  testWidgets('lists spending by category with the total', (tester) async {
    await showStats(tester, [
      testTx('f', TransactionType.expense, 30, DateTime(2026, 9, 5)),
      testTx(
        'r',
        TransactionType.expense,
        10,
        DateTime(2026, 9, 6),
        categoryId: 'cat-rent',
      ),
    ]);

    // The list sits below the chart, outside the 800×600 test screen.
    expect(
      find.text('Total spent: \$40.00', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Food', skipOffstage: false), findsOneWidget);
    expect(find.text('Rent', skipOffstage: false), findsOneWidget);
  });
}
