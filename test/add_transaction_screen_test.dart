import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';

import 'helpers.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;

  setUp(() async {
    fake = FakeDB();
    provider = TransactionProvider(db: fake);
    await provider.load();
  });

  /// Opens the add/edit screen from a placeholder page.
  Future<void> open(WidgetTester tester, {ExpenseTransaction? editing}) async {
    await tester.pumpWidget(
      testApp(
        provider,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(editing: editing),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> enterAmount(WidgetTester tester, String amount) =>
      tester.enterText(find.widgetWithText(TextFormField, 'Amount'), amount);

  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.widgetWithText(FilledButton, label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('saving without a title adds the transaction and closes', (
    tester,
  ) async {
    await open(tester);
    await enterAmount(tester, '12.50');
    await tapButton(tester, 'Add Transaction');

    final saved = provider.transactions.single;
    expect(saved.amount, const Money(12500));
    expect(saved.title, isNull);
    expect(saved.categoryId, 'cat-food');
    expect(saved.accountId, Account.cashId);
    expect(find.byType(AddTransactionScreen), findsNothing);
  });

  testWidgets('an amount with more than three decimals is rejected', (
    tester,
  ) async {
    await open(tester);
    await enterAmount(tester, '12.3456');
    await tapButton(tester, 'Add Transaction');

    expect(find.text('Enter a valid amount'), findsOneWidget);
    expect(provider.transactions, isEmpty);
  });

  testWidgets('a failed save keeps the screen open and shows an error', (
    tester,
  ) async {
    fake.failWrites = true;

    await open(tester);
    await enterAmount(tester, '12.50');
    await tapButton(tester, 'Add Transaction');

    expect(provider.transactions, isEmpty);
    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(
      find.text("Couldn't save the transaction. Try again."),
      findsOneWidget,
    );
  });

  testWidgets('editing can clear the note', (tester) async {
    final lunch = testTx(
      'a',
      TransactionType.expense,
      12.5,
      DateTime(2026, 9, 13),
      note: 'with team',
    );
    fake.rows.add(lunch);
    await provider.load();

    await open(tester, editing: lunch);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Note (optional)'),
      '',
    );
    await tapButton(tester, 'Save Changes');

    final saved = provider.transactions.single;
    expect(saved.note, isNull);
    expect(saved.amount, const Money(12500));
    expect(find.byType(AddTransactionScreen), findsNothing);
  });
}
