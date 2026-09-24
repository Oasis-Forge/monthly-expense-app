import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/walkthrough_screen.dart';

import 'helpers.dart';

void main() {
  late TransactionProvider provider;
  late FakeReminderService reminders;

  /// One service for both the provider and the tree, so a reschedule the
  /// walkthrough asks for is the one the test can see.
  Future<void> build({bool granted = true}) async {
    reminders = FakeReminderService(permissionGranted: granted);
    provider = TransactionProvider(db: FakeDB(), reminders: reminders);
    await provider.load();
  }

  /// Settings as they stand when the walkthrough opens: setup done, the
  /// walkthrough not yet seen.
  Future<SettingsProvider> afterSetup() =>
      testSettings({'setup_done': true, 'language': 'en'});

  Future<void> reachTheEnd(
    WidgetTester tester,
    SettingsProvider settings,
  ) async {
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        const WalkthroughScreen(),
        reminders: reminders,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
  }

  testWidgets('the walkthrough asks the phone, then asks the user, and a '
      'yes turns the empty day on (NUDGE-3, NUDGE-7)', (tester) async {
    final settings = await afterSetup();
    await build();

    await reachTheEnd(tester, settings);

    expect(reminders.permissionRequests, 1);
    expect(find.text('A nudge on the days you forget?'), findsOneWidget);

    await tester.tap(find.text('Yes, remind me'));
    await tester.pumpAndSettle();

    expect(settings.emptyDayNudge, isTrue);
    // The plan is scheduled at once, not left for the next launch.
    expect(reminders.nudgePlans, greaterThan(0));
  });

  testWidgets('a no leaves it off, and Home never asks again (NUDGE-3)', (
    tester,
  ) async {
    final settings = await afterSetup();
    await build();

    await reachTheEnd(tester, settings);
    await tester.tap(find.text('No thanks'));
    await tester.pumpAndSettle();

    expect(settings.emptyDayNudge, isFalse);
    // Asked once, here; the Home notice is for people this never reached.
    expect(settings.nudgeOfferPending, isFalse);
  });

  testWidgets('a refused phone is asked nothing further (NUDGE-7)', (
    tester,
  ) async {
    final settings = await afterSetup();
    await build(granted: false);

    await reachTheEnd(tester, settings);

    expect(reminders.permissionRequests, 1);
    // No point asking whether somebody wants a reminder the phone will not
    // deliver.
    expect(find.text('A nudge on the days you forget?'), findsNothing);
    expect(settings.emptyDayNudge, isFalse);
    expect(settings.nudgeOfferPending, isFalse);
  });

  testWidgets('either way the walkthrough ends (RUN-5)', (tester) async {
    final settings = await afterSetup();
    await build(granted: false);

    await reachTheEnd(tester, settings);

    expect(settings.walkthroughSeen, isTrue);
  });

  testWidgets('a replay asks nothing at all (RUN-5)', (tester) async {
    final settings = await afterSetup();
    await build();

    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        const WalkthroughScreen(replay: true),
        reminders: reminders,
      ),
    );
    await tester.pumpAndSettle();
    // A replay has no way out but the end of it.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();

    expect(reminders.permissionRequests, 0);
    expect(find.text('A nudge on the days you forget?'), findsNothing);
  });
}
