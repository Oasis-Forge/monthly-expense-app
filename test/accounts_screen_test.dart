import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/account_edit_screen.dart';
import 'package:monthly_expense_app/screens/accounts_screen.dart';
import 'package:monthly_expense_app/screens/transfer_screen.dart';

import 'helpers.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    fake = FakeDB(
      transactions: [
        testTx('pay', TransactionType.income, 100, DateTime(2026, 9, 1)),
      ],
    );
    provider = TransactionProvider(db: fake);
    await provider.load();
    settings = await testSettings();
  });

  Future<void> showAccounts(WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(provider, settings, const AccountsScreen()),
    );
    await tester.pump();
  }

  Future<void> addBank() async {
    fake.accounts.add(testAccount('bank'));
    await provider.load();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
  }

  testWidgets("lists accounts with today's balance (ACC-4)", (tester) async {
    await showAccounts(tester);

    expect(find.text('acc-cash'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('\$100.00'), findsOneWidget);
  });

  testWidgets('adds an account with an opening balance (ACC-1)', (
    tester,
  ) async {
    await showAccounts(tester);

    await tester.tap(find.byTooltip('Add account'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Savings',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Opening balance'),
      '250',
    );
    await save(tester);

    expect(find.byType(AccountEditScreen), findsNothing);
    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('\$250.00'), findsOneWidget);
    expect(provider.activeAccounts.last.type, AccountType.bank);
  });

  testWidgets('a name already in use is rejected', (tester) async {
    await showAccounts(tester);

    await tester.tap(find.byTooltip('Add account'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'ACC-CASH',
    );
    await save(tester);

    expect(find.text('That name is already used'), findsOneWidget);
    expect(provider.accounts, hasLength(1));
  });

  testWidgets('a used account can be archived; an unused one deleted', (
    tester,
  ) async {
    await addBank();
    await showAccounts(tester);

    await tester.tap(find.text('acc-cash'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Archive'), findsOneWidget);
    expect(find.byTooltip('Delete'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('bank'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(provider.accountById('bank'), isNull);
    expect(find.text('bank'), findsNothing);
  });

  testWidgets('archiving moves an account to the archived list (ACC-5)', (
    tester,
  ) async {
    await addBank();
    await showAccounts(tester);

    await tester.tap(find.text('bank'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Archived'), findsOneWidget);
    expect(provider.accountById('bank')!.archivedAt, isNotNull);

    await tester.tap(find.text('bank'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Unarchive'));
    await tester.pumpAndSettle();

    expect(provider.accountById('bank')!.archivedAt, isNull);
  });

  testWidgets('the only active account cannot be archived or deleted', (
    tester,
  ) async {
    await showAccounts(tester);

    await tester.tap(find.text('acc-cash'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Archive'), findsNothing);
    expect(find.byTooltip('Delete'), findsNothing);
  });

  testWidgets('the default Cash name stays translated unless renamed', (
    tester,
  ) async {
    fake = FakeDB(
      accounts: [
        Account(
          id: Account.cashId,
          type: AccountType.cash,
          defaultKey: 'cash',
          openingBalance: Money.zero,
          openingDate: DateTime(2026),
          sortOrder: 0,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      ],
    );
    provider = TransactionProvider(db: fake);
    await provider.load();
    await showAccounts(tester);

    // The title and the type both read "Cash".
    await tester.tap(find.text('Cash').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Opening balance'),
      '-20',
    );
    await save(tester);

    final saved = provider.accountById(Account.cashId)!;
    expect(saved.name, isNull);
    expect(saved.openingBalance, const Money(-20000));
  });

  testWidgets('the transfer button opens a transfer', (tester) async {
    await addBank();
    await showAccounts(tester);

    await tester.tap(find.byTooltip('Transfer'));
    await tester.pumpAndSettle();

    expect(find.byType(TransferScreen), findsOneWidget);
  });
}
