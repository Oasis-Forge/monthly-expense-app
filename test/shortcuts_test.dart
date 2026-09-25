import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/main.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/transfer_screen.dart';
import 'package:monthly_expense_app/services/home_widget_service.dart';

import 'helpers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  /// The whole app, past setup, with the icon's menu in a list instead of on
  /// an icon. Deliberately not the device's services: no test reaches the
  /// platform.
  Future<void> startApp(
    WidgetTester tester,
    FakeShortcuts shortcuts, {
    Map<String, Object> values = const {},
  }) async {
    await tester.pumpWidget(
      MonthlyExpenseApp(
        settings: await testSettings({
          'setup_done': true,
          'walkthrough_seen': true,
          ...values,
        }),
        homeWidget: const NoopHomeWidgetService(),
        reviews: FakeReviews(supported: false),
        updates: FakeUpdates(supported: false),
        shortcuts: shortcuts,
        // Without these the real ad SDK is built, and it leaves a timer
        // running long after the test that started it.
        ads: FakeAdService(),
        purchases: FakePurchases(),
      ),
    );
    await tester.pump();
    // The app loads its real database in the background; without letting
    // that finish, sqflite's lock timer outlives the test that started it.
    // One fixed wait was too short on a slower machine. The database answers
    // in real time and the load goes on in the test's own, so give each its
    // turn until the load is in, then once more for what follows it.
    final transactions = tester
        .element(find.byType(MaterialApp))
        .read<TransactionProvider>();
    for (var i = 0; i < 200 && !transactions.isLoaded; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    expect(transactions.isLoaded, isTrue, reason: 'the database never loaded');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }

  group('the app icon long press (NAV-8)', () {
    testWidgets('offers the drawer three, in the words the drawer uses', (
      tester,
    ) async {
      final shortcuts = FakeShortcuts();
      await startApp(tester, shortcuts);

      expect(shortcuts.items.map((item) => item.type).toList(), [
        'add_expense',
        'add_income',
        'transfer',
      ]);
      expect(shortcuts.items.map((item) => item.label).toList(), [
        'Add expense',
        'Add income',
        'Transfer',
      ]);
    });

    testWidgets('and says it in the language the app is set to', (
      tester,
    ) async {
      final shortcuts = FakeShortcuts();
      await startApp(tester, shortcuts, values: {'language': 'fr'});

      expect(shortcuts.items, hasLength(3));
      expect(shortcuts.items.first.label, isNot('Add expense'));
    });

    testWidgets('a platform without one is offered nothing', (tester) async {
      final shortcuts = FakeShortcuts(supported: false);
      await startApp(tester, shortcuts);

      expect(shortcuts.items, isEmpty);
    });

    testWidgets('choosing one opens that form', (tester) async {
      final shortcuts = FakeShortcuts();
      await startApp(tester, shortcuts);

      shortcuts.choose('transfer');
      await tester.pumpAndSettle();
      expect(find.byType(TransferScreen), findsOneWidget);

      // Whatever was open before is not what was asked for, so the transfer
      // form goes rather than sitting underneath.
      shortcuts.choose('add_income');
      await tester.pumpAndSettle();
      expect(find.byType(TransferScreen), findsNothing);
      expect(find.byType(AddTransactionScreen), findsOneWidget);
    });
  });
}
