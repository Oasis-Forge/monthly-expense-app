// Verifies the real wiring behind ADS-5/ADS-9/LOCK-2, not just the unit
// tests in ads_provider_test.dart that pass a `ValueNotifier<bool>` in by
// hand: main.dart has to pass `locked: appIsLocked` to AdsProvider, and
// AppLock.initState has to set `appIsLocked` before AdsProvider.start()'s
// first check runs. Either wiring could be dropped while every other test
// still passes, so this pumps the full MonthlyExpenseApp and drives the
// lock screen the way a person would.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/main.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/services/authenticator.dart';
import 'package:monthly_expense_app/services/home_widget_service.dart';

import 'helpers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final locked = find.text('Monthly Expenses is locked');

  testWidgets('a locked launch holds ads back, and unlocking starts them once '
      '(ADS-5, ADS-9, LOCK-2)', (tester) async {
    final authenticator = FakeAuthenticator(result: AuthResult.failed);
    final ads = FakeAdService(canStart: true);

    await tester.pumpWidget(
      MonthlyExpenseApp(
        settings: await testSettings({
          'setup_done': true,
          'walkthrough_seen': true,
          'app_lock': true,
        }),
        // In-memory, not the real app database: this is one of the very
        // few tests in the suite that pumps the full app widget, and it
        // must never touch the file `flutter run` uses.
        db: DBHelper(path: inMemoryDatabasePath),
        homeWidget: const NoopHomeWidgetService(),
        authenticator: authenticator,
        reviews: FakeReviews(supported: false),
        updates: FakeUpdates(supported: false),
        shortcuts: FakeShortcuts(),
        ads: ads,
        purchases: FakePurchases(),
      ),
    );
    await tester.pump();
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
    await tester.pump();

    // The lock is up from the first frame (app_lock is on and the
    // authenticator fails), and the consent/ad start this app_lock gate
    // guards must not have run underneath it.
    expect(locked, findsOneWidget);
    expect(
      ads.started,
      isFalse,
      reason: 'the ad SDK must never start while the app is locked',
    );

    authenticator.result = AuthResult.success;
    await tester.tap(find.text('Unlock'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(locked, findsNothing);
    expect(ads.startCalls, 1);
  });
}
