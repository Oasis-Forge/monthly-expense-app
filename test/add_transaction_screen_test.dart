import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';

import 'fake_db.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;

  setUp(() {
    fake = FakeDB();
    provider = TransactionProvider(db: fake);
  });

  /// Opens the add screen from a placeholder page, fills it in, and saves.
  Future<void> addLunch(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen(),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Lunch',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      '12.50',
    );
    final save = find.widgetWithText(FilledButton, 'Add Transaction');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
  }

  testWidgets('saving adds the transaction and closes the screen', (
    tester,
  ) async {
    await addLunch(tester);

    expect(provider.transactions.single.title, 'Lunch');
    expect(fake.rows, hasLength(1));
    expect(find.byType(AddTransactionScreen), findsNothing);
  });

  testWidgets('a failed save keeps the screen open and shows an error', (
    tester,
  ) async {
    fake.failWrites = true;

    await addLunch(tester);

    expect(provider.transactions, isEmpty);
    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(
      find.text("Couldn't save the transaction. Try again."),
      findsOneWidget,
    );
  });
}
