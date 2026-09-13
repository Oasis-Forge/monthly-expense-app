import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/budgets_screen.dart';
import 'package:monthly_expense_app/screens/home_screen.dart';
import 'package:monthly_expense_app/screens/recurring_screen.dart';
import 'package:monthly_expense_app/screens/search_screen.dart';
import 'package:monthly_expense_app/screens/settings_screen.dart';
import 'package:monthly_expense_app/screens/stats_screen.dart';
import 'package:monthly_expense_app/screens/transfer_screen.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 9, 15, 10);
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    fake = FakeDB(
      transactions: [
        testTx(
          'a',
          TransactionType.expense,
          12.5,
          DateTime(2026, 9, 15),
          title: 'Lunch',
        ),
        testTx(
          'b',
          TransactionType.expense,
          40,
          DateTime(2026, 9, 18),
          title: 'Concert',
        ),
      ],
    );
    provider = TransactionProvider(db: fake, clock: () => today);
    await provider.load();
    settings = await testSettings();
  });

  Future<void> showHome(WidgetTester tester) async {
    await tester.pumpWidget(testApp(provider, settings, const HomeScreen()));
    await tester.pump();
  }

  Future<void> swipe(WidgetTester tester, String text) async {
    await tester.drag(find.text(text), const Offset(-600, 0));
    await tester.pumpAndSettle();
  }

  /// Adds a bank account and a transfer to it on Sep 16.
  Future<void> addTransfer() async {
    fake.accounts.add(testAccount('bank'));
    fake.transfers.add(
      testTransfer('t', Account.cashId, 'bank', 50, DateTime(2026, 9, 16)),
    );
    await provider.load();
  }

  testWidgets('future-dated rows are marked upcoming and not counted', (
    tester,
  ) async {
    await showHome(tester);

    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Food · Upcoming'), findsOneWidget);
    // The expense total is only lunch; the concert hasn't happened yet.
    expect(find.text('\$12.50'), findsOneWidget);
  });

  testWidgets('the balance carries forward from earlier periods (BAL-2)', (
    tester,
  ) async {
    fake.rows.add(
      testTx('pay', TransactionType.income, 100, DateTime(2026, 8, 20)),
    );
    await provider.load();

    await showHome(tester);

    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Carried forward \$100.00'), findsOneWidget);
    expect(find.text('\$87.50'), findsOneWidget);
  });

  testWidgets('with carrying forward off, the card shows this period (BAL-3)', (
    tester,
  ) async {
    settings = await testSettings({'show_carried_forward': false});

    await showHome(tester);

    expect(find.text('This period'), findsOneWidget);
    expect(find.textContaining('Carried forward'), findsNothing);
  });

  testWidgets('amounts use the chosen currency (CUR-2)', (tester) async {
    settings = await testSettings({'currency_code': 'EUR'});

    await showHome(tester);

    expect(find.text('€12.50'), findsOneWidget);
  });

  testWidgets('the arrows move between periods', (tester) async {
    await showHome(tester);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('Lunch'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
  });

  testWidgets('a month starting on the 25th shows both dates (PER-3)', (
    tester,
  ) async {
    provider = TransactionProvider(db: fake, clock: () => today, startDay: 25);
    await provider.load();

    await showHome(tester);

    expect(find.text('Aug 25 – Sep 24'), findsOneWidget);
  });

  testWidgets('the app bar, menu, and add button open their screens', (
    tester,
  ) async {
    await showHome(tester);

    Future<void> openAndReturn(
      Future<void> Function() open,
      Type screen,
    ) async {
      await open();
      await tester.pumpAndSettle();
      expect(find.byType(screen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await openAndReturn(
      () => tester.tap(find.byTooltip('Search')),
      SearchScreen,
    );
    await openAndReturn(() => tester.tap(find.byTooltip('Stats')), StatsScreen);
    for (final (label, screen) in [
      ('Transfer', TransferScreen),
      ('Recurring', RecurringScreen),
      ('Budgets', BudgetsScreen),
      ('Settings', SettingsScreen),
    ]) {
      await openAndReturn(() async {
        await tester.tap(find.byTooltip('Show menu'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label));
      }, screen);
    }

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsOneWidget);
  });

  testWidgets('due recurring transactions show a notice (RCR-2)', (
    tester,
  ) async {
    fake.rules.add(testRule('Gym', 30, DateTime(2026, 9)));
    await provider.load();

    await showHome(tester);
    await tester.tap(find.text('1 recurring transaction is due'));
    await tester.pumpAndSettle();

    expect(find.byType(RecurringScreen), findsOneWidget);
  });

  testWidgets('budgets over their limit show a notice (BUD-4)', (tester) async {
    fake.budgets.add(
      Budget(
        id: 'food',
        categoryId: 'cat-food',
        limit: const Money(10000),
        effectiveFrom: DateTime(2026, 9),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );
    await provider.load();

    await showHome(tester);
    await tester.tap(find.text('1 budget is over its limit'));
    await tester.pumpAndSettle();

    expect(find.byType(StatsScreen), findsOneWidget);
  });

  testWidgets('tapping a row opens it for editing', (tester) async {
    await showHome(tester);

    await tester.tap(find.text('Lunch'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Transaction'), findsOneWidget);
  });

  testWidgets('swiping a row moves it to the trash with Undo (DEL-2)', (
    tester,
  ) async {
    await showHome(tester);
    await swipe(tester, 'Lunch');

    expect(find.text('Lunch'), findsNothing);
    expect(provider.deletedTransactions.single.id, 'a');
    expect(find.text('Transaction deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsOneWidget);
    expect(provider.deletedTransactions, isEmpty);
  });

  testWidgets('a failed undo shows an error', (tester) async {
    await showHome(tester);
    await swipe(tester, 'Lunch');
    fake.failWrites = true;

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't restore the transaction. Try again."),
      findsOneWidget,
    );
    expect(provider.deletedTransactions, hasLength(1));
  });

  testWidgets('a failed swipe delete keeps the row and shows an error', (
    tester,
  ) async {
    fake.failWrites = true;

    await showHome(tester);
    await swipe(tester, 'Lunch');

    expect(find.text('Lunch'), findsOneWidget);
    expect(provider.transactions, hasLength(2));
    expect(
      find.text("Couldn't delete the transaction. Try again."),
      findsOneWidget,
    );
  });

  testWidgets('transfers are listed, not counted, and open for editing', (
    tester,
  ) async {
    await addTransfer();
    await showHome(tester);

    expect(find.text('acc-cash → bank'), findsOneWidget);
    expect(find.text('\$50.00'), findsOneWidget);
    expect(find.text('\$12.50'), findsOneWidget);

    await tester.tap(find.text('acc-cash → bank'));
    await tester.pumpAndSettle();

    expect(find.text('Edit transfer'), findsOneWidget);
  });

  testWidgets('swiping a transfer deletes it with Undo', (tester) async {
    await addTransfer();
    await showHome(tester);

    await swipe(tester, 'acc-cash → bank');
    expect(provider.transfers, isEmpty);
    expect(find.text('Transfer deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(provider.transfers, hasLength(1));
    expect(find.text('acc-cash → bank'), findsOneWidget);
  });
}
