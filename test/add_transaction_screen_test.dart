import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';

import 'helpers.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    fake = FakeDB();
    provider = TransactionProvider(db: fake);
    await provider.load();
    settings = await testSettings();
  });

  /// Opens the add/edit screen from a placeholder page.
  Future<void> open(WidgetTester tester, {ExpenseTransaction? editing}) async {
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
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

  /// Stores a lunch expense in [fake] and reloads [provider].
  Future<ExpenseTransaction> addLunch() async {
    final lunch = testTx(
      'a',
      TransactionType.expense,
      12.5,
      DateTime(2026, 9, 13),
      note: 'with team',
    );
    fake.rows.add(lunch);
    await provider.load();
    return lunch;
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

  testWidgets('switching to income picks an income category', (tester) async {
    await open(tester);
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    expect(find.text('💼 Salary'), findsOneWidget);

    await enterAmount(tester, '1000');
    await tapButton(tester, 'Add Transaction');

    final saved = provider.transactions.single;
    expect(saved.type, TransactionType.income);
    expect(saved.categoryId, 'cat-salary');
  });

  testWidgets('the date picker sets the date', (tester) async {
    await open(tester);
    await tester.tap(find.text('Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await enterAmount(tester, '5');
    await tapButton(tester, 'Add Transaction');

    expect(provider.transactions.single.date.day, 10);
  });

  testWidgets('an empty amount asks for one', (tester) async {
    await open(tester);
    await tapButton(tester, 'Add Transaction');

    expect(find.text('Enter an amount'), findsOneWidget);
    expect(provider.transactions, isEmpty);
  });

  testWidgets('amounts allow only the currency decimals (CUR-2)', (
    tester,
  ) async {
    await open(tester);
    await enterAmount(tester, '12.345');
    await tapButton(tester, 'Add Transaction');

    expect(find.text('Enter a valid amount'), findsOneWidget);
    expect(provider.transactions, isEmpty);
  });

  testWidgets('a yen amount must be whole', (tester) async {
    settings = await testSettings({'currency_code': 'JPY'});

    await open(tester);
    expect(find.text('¥ '), findsOneWidget);
    await enterAmount(tester, '12.5');
    await tapButton(tester, 'Add Transaction');

    expect(find.text('Enter a valid amount'), findsOneWidget);
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
    final lunch = await addLunch();

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

  testWidgets('a transaction in an archived category keeps that category', (
    tester,
  ) async {
    final categories = testCategories();
    categories[0] = categories[0].copyWith(archivedAt: DateTime.utc(2026, 9));
    fake = FakeDB(categories: categories);
    provider = TransactionProvider(db: fake);
    final lunch = await addLunch();

    await open(tester, editing: lunch);
    expect(find.text('🍔 Food'), findsOneWidget);
    await enterAmount(tester, '20');
    await tapButton(tester, 'Save Changes');

    final saved = provider.transactions.single;
    expect(saved.categoryId, 'cat-food');
    expect(saved.amount, const Money(20000));
  });

  testWidgets('the delete button moves the transaction to the trash', (
    tester,
  ) async {
    final lunch = await addLunch();

    await open(tester, editing: lunch);
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionScreen), findsNothing);
    expect(provider.deletedTransactions.single.id, 'a');
    expect(find.text('Transaction deleted'), findsOneWidget);
  });

  testWidgets('a failed delete keeps the screen open and shows an error', (
    tester,
  ) async {
    final lunch = await addLunch();

    await open(tester, editing: lunch);
    fake.failWrites = true;
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(
      find.text("Couldn't delete the transaction. Try again."),
      findsOneWidget,
    );
  });
}
