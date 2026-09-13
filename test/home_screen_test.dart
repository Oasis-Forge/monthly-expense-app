import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/home_screen.dart';

import 'fake_db.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;

  setUp(() async {
    fake = FakeDB([
      ExpenseTransaction(
        id: 'a',
        title: 'Lunch',
        amount: 12.5,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime.now(),
      ),
    ]);
    provider = TransactionProvider(db: fake);
    await provider.load();
  });

  Future<void> swipeLunch(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.drag(find.text('Lunch'), const Offset(-600, 0));
    await tester.pumpAndSettle();
  }

  testWidgets('swiping a row deletes the transaction', (tester) async {
    await swipeLunch(tester);

    expect(find.text('Lunch'), findsNothing);
    expect(provider.transactions, isEmpty);
    expect(fake.rows, isEmpty);
  });

  testWidgets('a failed swipe delete keeps the row and shows an error', (
    tester,
  ) async {
    fake.failWrites = true;

    await swipeLunch(tester);

    expect(find.text('Lunch'), findsOneWidget);
    expect(provider.transactions, hasLength(1));
    expect(
      find.text("Couldn't delete the transaction. Try again."),
      findsOneWidget,
    );
  });
}
