// Basic smoke test for the Monthly Expense app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/main.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/services/home_widget_service.dart';

import 'helpers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  /// Starts the whole app over [values]. Deliberately not the device's
  /// services: no test should reach the platform (RUN-3, NAV-8), and a fresh
  /// in-memory [db] each time means leftover data from another test, or from
  /// `flutter run` on the same machine, can never change what this one sees.
  /// Closed on teardown: sqflite serialises opens of the same in-memory
  /// path, so an unclosed one left over from an earlier test hangs the
  /// next open. Closing while the app's own background load is still
  /// reading from it leaves that same lock stuck, so this waits for the
  /// load to finish first, the same way [waitForRealLoad] does.
  Future<void> startApp(
    WidgetTester tester, [
    Map<String, Object> values = const {},
    FakeShortcuts? shortcuts,
  ]) async {
    final db = DBHelper(path: inMemoryDatabasePath);
    addTearDown(db.close);
    await tester.pumpWidget(
      MonthlyExpenseApp(
        settings: await testSettings(values),
        db: db,
        homeWidget: const NoopHomeWidgetService(),
        // Neither plugin exists in a test, and both would throw if asked.
        reviews: FakeReviews(supported: false),
        updates: FakeUpdates(supported: false),
        shortcuts: shortcuts ?? FakeShortcuts(),
        // Without these the real ad SDK is built on the default 'android'
        // test platform, and it leaves a timer running past the test.
        ads: FakeAdService(),
        purchases: FakePurchases(),
      ),
    );
    await tester.pump();
    await waitForRealLoad(tester);
  }

  testWidgets('App starts and shows the home screen', (
    WidgetTester tester,
  ) async {
    await startApp(tester, {'setup_done': true, 'walkthrough_seen': true});

    expect(find.text('Monthly Expenses'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('A first launch starts at setup instead (RUN-3)', (
    WidgetTester tester,
  ) async {
    await startApp(tester);

    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets(
    'a fresh in-memory DBHelper never carries another one\'s data, which is '
    'what keeps this file\'s startApp isolated per test (test-quality#9)',
    (tester) async {
      await tester.runAsync(() async {
        final first = DBHelper(path: inMemoryDatabasePath);
        await first.insertTransaction(
          testTx('leftover', TransactionType.expense, 10, DateTime(2026, 1, 1)),
        );
        expect(await first.fetchTransactions(), hasLength(1));
        await first.close();

        final second = DBHelper(path: inMemoryDatabasePath);
        expect(
          await second.fetchTransactions(),
          isEmpty,
          reason:
              'a fresh DBHelper instance must not see another instance\'s '
              'data, or startApp\'s per-test db: override would not '
              'actually isolate tests from each other',
        );
        await second.close();
      });
    },
  );
}
