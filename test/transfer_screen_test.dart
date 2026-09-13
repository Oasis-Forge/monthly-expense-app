import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transfer.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/account_edit_screen.dart';
import 'package:monthly_expense_app/screens/transfer_screen.dart';

import 'helpers.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  final amountField = find.widgetWithText(TextFormField, 'Amount');

  setUp(() async {
    fake = FakeDB(accounts: [testAccount(Account.cashId), testAccount('bank')]);
    provider = TransactionProvider(db: fake);
    await provider.load();
    settings = await testSettings();
  });

  /// Opens the transfer screen from a placeholder page on a phone screen.
  Future<void> open(WidgetTester tester, {Transfer? editing}) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TransferScreen(editing: editing),
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

  Future<void> enterAmount(WidgetTester tester, String amount) async {
    await revealInForm(tester, amountField);
    await tester.enterText(amountField, amount);
  }

  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.widgetWithText(FilledButton, label);
    await revealInForm(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Transfer lunchMoney() =>
      testTransfer('t', Account.cashId, 'bank', 30, DateTime(2026, 9, 3));

  testWidgets('moves money between two accounts (ACC-3)', (tester) async {
    await open(tester);
    await enterAmount(tester, '50');
    await tapButton(tester, 'Add Transfer');

    final transfer = provider.transfers.single;
    expect(
      (transfer.fromAccountId, transfer.toAccountId, transfer.amount),
      (Account.cashId, 'bank', const Money(50000)),
    );
    expect(provider.accountBalance('bank'), const Money(50000));
    expect(find.byType(TransferScreen), findsNothing);
  });

  testWidgets('the same account on both sides is rejected', (tester) async {
    await open(tester);
    await enterAmount(tester, '50');
    final toField = find.byType(DropdownButtonFormField<String>).last;
    await revealInForm(tester, toField);
    await tester.tap(toField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('acc-cash').last);
    await tester.pumpAndSettle();
    await tapButton(tester, 'Add Transfer');

    await revealInForm(tester, find.text('Choose two different accounts'));
    expect(find.text('Choose two different accounts'), findsOneWidget);
    expect(provider.transfers, isEmpty);
  });

  testWidgets('asks for a second account first', (tester) async {
    fake = FakeDB();
    provider = TransactionProvider(db: fake);
    await provider.load();

    await open(tester);
    expect(
      find.text('Add a second account to move money between accounts.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Add account'));
    await tester.pumpAndSettle();

    expect(find.byType(AccountEditScreen), findsOneWidget);
  });

  testWidgets('editing saves a new amount', (tester) async {
    fake.transfers.add(lunchMoney());
    await provider.load();

    await open(tester, editing: lunchMoney());
    expect(find.text('Edit transfer'), findsOneWidget);
    await enterAmount(tester, '45');
    await tapButton(tester, 'Save Changes');

    expect(fake.transfers.single.amount, const Money(45000));
  });

  testWidgets('editing a transfer can delete it, with Undo', (tester) async {
    fake.transfers.add(lunchMoney());
    await provider.load();

    await open(tester, editing: lunchMoney());
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(provider.transfers, isEmpty);
    expect(find.text('Transfer deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(provider.transfers, hasLength(1));
  });

  testWidgets('a failed save keeps the screen open and shows an error', (
    tester,
  ) async {
    fake.failWrites = true;

    await open(tester);
    await enterAmount(tester, '50');
    await tapButton(tester, 'Add Transfer');

    expect(find.byType(TransferScreen), findsOneWidget);
    expect(find.text("Couldn't save the transfer. Try again."), findsOneWidget);
  });
}
