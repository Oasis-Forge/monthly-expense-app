import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/recurring_rule.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/empty_state.dart';
import 'package:monthly_expense_app/screens/insights_screen.dart';
import 'package:monthly_expense_app/screens/recurring_rule_screen.dart';
import 'package:monthly_expense_app/screens/recurring_screen.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 9, 24);

  Future<TransactionProvider> loaded({
    List<RecurringRule> rules = const [],
    List<ExpenseTransaction> transactions = const [],
  }) async {
    final provider = TransactionProvider(
      db: FakeDB(rules: rules, transactions: transactions),
      clock: () => today,
    );
    await provider.load();
    return provider;
  }

  group('Recurring (EMPTY-1, EMPTY-2, EMPTY-3)', () {
    testWidgets('with no rules it says what the screen is for, and offers '
        'the one action that fills it', (tester) async {
      final provider = await loaded();
      await tester.pumpWidget(
        testApp(provider, await testSettings(), const RecurringScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No recurring transactions yet.'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Add a recurring transaction'),
        findsOneWidget,
      );
      // EMPTY-2: one sentence and one button, and nothing else.
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('the button opens the form for a new rule', (tester) async {
      final provider = await loaded();
      await tester.pumpWidget(
        testApp(provider, await testSettings(), const RecurringScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(FilledButton, 'Add a recurring transaction'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RecurringRuleScreen), findsOneWidget);
    });

    testWidgets('with a rule the list is shown and the empty state is not', (
      tester,
    ) async {
      final provider = await loaded(rules: [testRule('r1', 1200, today)]);
      await tester.pumpWidget(
        testApp(provider, await testSettings(), const RecurringScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsNothing);
      expect(find.text('No recurring transactions yet.'), findsNothing);
    });
  });

  group('the trend (EMPTY-4)', () {
    testWidgets('with everything in one period it says a trend needs more, '
        'and offers nothing', (tester) async {
      final provider = await loaded(
        transactions: [testTx('t1', TransactionType.expense, 20, today)],
      );
      await tester.pumpWidget(
        testApp(provider, await testSettings(), const InsightsScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trend'));
      await tester.pumpAndSettle();

      expect(
        find.text('A trend needs more than one period. Come back next month.'),
        findsOneWidget,
      );
      // EMPTY-4: a report, not an invitation.
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('with an earlier period the chart is drawn instead', (
      tester,
    ) async {
      final provider = await loaded(
        transactions: [
          testTx('t1', TransactionType.expense, 20, today),
          testTx('t0', TransactionType.expense, 30, DateTime(2026, 7, 10)),
        ],
      );
      await tester.pumpWidget(
        testApp(provider, await testSettings(), const InsightsScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trend'));
      await tester.pumpAndSettle();

      expect(
        find.text('A trend needs more than one period. Come back next month.'),
        findsNothing,
      );
    });
  });
}
