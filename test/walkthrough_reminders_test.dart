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

  testWidgets('the app asks first; a yes then asks the phone and turns the '
      'empty day on (NUDGE-3, NUDGE-7)', (tester) async {
    await build();
    final settings = await afterSetup();

    await reachTheEnd(tester, settings);
    final plansBefore = reminders.nudgePlans;

    // Ours before Android's: nothing has been asked of the phone yet.
    expect(find.text('A nudge on the days you forget?'), findsOneWidget);
    expect(reminders.permissionRequests, 0);

    await tester.tap(find.text('Yes, remind me'));
    await tester.pumpAndSettle();

    expect(reminders.permissionRequests, 1);
    expect(settings.emptyDayNudge, isTrue);
    // Scheduled at once, not left for the next launch.
    expect(reminders.nudgePlans, greaterThan(plansBefore));
  });

  testWidgets('a no never troubles the phone at all (NUDGE-7)', (tester) async {
    await build();
    final settings = await afterSetup();

    await reachTheEnd(tester, settings);
    await tester.tap(find.text('No thanks'));
    await tester.pumpAndSettle();

    // Android shows its dialog once for the life of the install, so somebody
    // who wants no reminder keeps it unspent for the day they do.
    expect(reminders.permissionRequests, 0);
    expect(settings.emptyDayNudge, isFalse);
    // Asked once, here; the Home notice is for people this never reached.
    expect(settings.nudgeOfferPending, isFalse);
  });

  testWidgets('a yes the phone refuses leaves the reminder off (NUDGE-7)', (
    tester,
  ) async {
    await build(granted: false);
    final settings = await afterSetup();

    await reachTheEnd(tester, settings);
    final plansBefore = reminders.nudgePlans;
    await tester.tap(find.text('Yes, remind me'));
    await tester.pumpAndSettle();

    expect(reminders.permissionRequests, 1);
    // Off rather than set to something the phone will swallow.
    expect(settings.emptyDayNudge, isFalse);
    expect(reminders.nudgePlans, plansBefore);
  });

  testWidgets('either way the walkthrough ends (RUN-5)', (tester) async {
    await build(granted: false);
    final settings = await afterSetup();

    await reachTheEnd(tester, settings);
    await tester.tap(find.text('No thanks'));
    await tester.pumpAndSettle();

    expect(settings.walkthroughSeen, isTrue);
  });

  testWidgets('a replay asks nothing at all (RUN-5)', (tester) async {
    await build();
    final settings = await afterSetup();

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
