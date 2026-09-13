import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/home_screen.dart';
import 'package:monthly_expense_app/screens/settings_screen.dart';
import 'package:monthly_expense_app/screens/stats_screen.dart';

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

  Future<void> swipeLunch(WidgetTester tester) async {
    await tester.drag(find.text('Lunch'), const Offset(-600, 0));
    await tester.pumpAndSettle();
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

  testWidgets('the app bar and add button open their screens', (tester) async {
    await showHome(tester);

    await tester.tap(find.byTooltip('Stats'));
    await tester.pumpAndSettle();
    expect(find.byType(StatsScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsOneWidget);
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
    await swipeLunch(tester);

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
    await swipeLunch(tester);
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
    await swipeLunch(tester);

    expect(find.text('Lunch'), findsOneWidget);
    expect(provider.transactions, hasLength(2));
    expect(
      find.text("Couldn't delete the transaction. Try again."),
      findsOneWidget,
    );
  });
}
