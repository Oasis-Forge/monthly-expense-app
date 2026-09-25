import 'dart:convert';

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

  testWidgets(
    'restoring a backup reschedules reminders with the real app lock, not '
    'the load() defaults (LOCK-2, NOTE-6, NUDGE-8, NUDGE-9, pr59#6)',
    (tester) async {
      final fake = FakeDB();
      final theseReminders = FakeReminderService();
      final theseProvider = TransactionProvider(
        db: fake,
        reminders: theseReminders,
      );
      await theseProvider.load();

      // The backup being restored carries an open note with a reminder.
      final other = FakeDB(
        notes: [
          testNote(
            'note-1',
            'Pay Dr. X 300',
            dueDate: DateTime(2026, 9, 20),
            reminderAt: DateTime(2026, 9, 20, 9),
          ),
        ],
      );
      final backupJson = (await testBackupService(
        other,
      ).create(await testSettings())).toJson();
      final files = FakeBackupFiles()..toOpen = utf8.encode(backupJson);
      final service = testBackupService(fake, files: files);
      // The real setting on this device: app lock on.
      final settings = await testSettings({
        'setup_done': true,
        'language': 'en',
        'app_lock': true,
      });

      await tester.pumpWidget(
        testApp(
          theseProvider,
          settings,
          const WalkthroughScreen(),
          reminders: theseReminders,
          backup: service,
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Restore a backup'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      expect(
        theseReminders.scheduled['note-1'],
        isTrue,
        reason:
            'the note reminder should be scheduled with the real app '
            'lock, not the false default',
      );
    },
  );

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
