import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/main.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/services/home_widget_service.dart';

import 'helpers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  /// The whole app, past setup, with the empty-day nudge already on and
  /// [reminders] standing in for the phone's own notification permission.
  Future<SettingsProvider> startWithNudgeOn(
    WidgetTester tester,
    FakeReminderService reminders, {
    Map<String, Object> values = const {},
  }) async {
    final settings = await testSettings({
      'setup_done': true,
      'walkthrough_seen': true,
      'empty_day_nudge': true,
      ...values,
    });
    await tester.pumpWidget(
      MonthlyExpenseApp(
        db: DBHelper(path: inMemoryDatabasePath),
        settings: settings,
        homeWidget: const NoopHomeWidgetService(),
        reviews: FakeReviews(supported: false),
        updates: FakeUpdates(supported: false),
        shortcuts: FakeShortcuts(),
        ads: FakeAdService(),
        purchases: FakePurchases(),
        reminders: reminders,
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
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    return settings;
  }

  group('a phone blocking notifications, checked live (NUDGE-7, pr59#8)', () {
    testWidgets('is noticed on launch when the nudge is on', (tester) async {
      final reminders = FakeReminderService(permissionGranted: false);
      final settings = await startWithNudgeOn(tester, reminders);

      expect(settings.notificationsBlocked, isTrue);
    });

    testWidgets('is not raised when the phone allows them', (tester) async {
      final reminders = FakeReminderService();
      final settings = await startWithNudgeOn(tester, reminders);

      expect(settings.notificationsBlocked, isFalse);
    });

    testWidgets('is checked again on resume, not only at launch', (
      tester,
    ) async {
      final reminders = FakeReminderService();
      final settings = await startWithNudgeOn(tester, reminders);
      expect(settings.notificationsBlocked, isFalse);

      // The user blocks notifications in the phone's own settings while the
      // app sits in the background, then comes back to it.
      reminders.permissionGranted = false;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      // Resume also starts returnToToday on the real database, so under a
      // loaded full-suite run a fixed pair of pumps isn't always enough.
      for (var i = 0; i < 100 && !settings.notificationsBlocked; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }

      expect(settings.notificationsBlocked, isTrue);
    });

    testWidgets(
      'a stretch spent blocked is not later counted as ignored nudges '
      '(NUDGE-5, pr59#8)',
      (tester) async {
        final reminders = FakeReminderService(permissionGranted: false);
        // Several days with the nudge's own hour already well behind
        // "now", every one of them: without the blocked-phone guard this
        // alone would be enough to give up on the nudge (see the mirror
        // case below), so the test actually exercises the guard rather
        // than passing because nothing was ever checked before.
        final checkedAt = DateTime.now().subtract(const Duration(days: 5));
        final settings = await startWithNudgeOn(
          tester,
          reminders,
          values: {
            'empty_day_nudge_checked': checkedAt.toUtc().toIso8601String(),
          },
        );

        expect(settings.notificationsBlocked, isTrue);
        // Nothing here ever moved the ignored count or gave up on the
        // nudge, because a blocked phone never had a chance to see one.
        expect(settings.nudgeIgnored, 0);
        expect(settings.nudgeStopped, isFalse);
        expect(settings.emptyDayNudge, isTrue);
      },
    );

    testWidgets(
      'the same stretch with the phone allowing notifications would have '
      'given up on the nudge, proving the guard above is doing something '
      '(NUDGE-5, pr59#8)',
      (tester) async {
        final reminders = FakeReminderService(permissionGranted: true);
        final checkedAt = DateTime.now().subtract(const Duration(days: 5));
        final settings = await startWithNudgeOn(
          tester,
          reminders,
          values: {
            'empty_day_nudge_checked': checkedAt.toUtc().toIso8601String(),
          },
        );

        expect(settings.notificationsBlocked, isFalse);
        expect(settings.nudgeStopped, isTrue);
      },
    );
  });
}
