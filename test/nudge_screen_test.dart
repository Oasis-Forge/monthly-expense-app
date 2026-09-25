import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/reminders.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/home_screen.dart';
import 'package:monthly_expense_app/screens/settings_screen.dart';

import 'helpers.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;
  late FakeReminderService reminders;

  /// Entries added on [days] separate days, which is what the offer counts
  /// (NUDGE-3). Their dates are all today, so nothing is owed about an empty
  /// day either.
  FakeDB used(int days) => FakeDB(
    transactions: [
      for (var i = 0; i < days; i++)
        testTx(
          't$i',
          TransactionType.expense,
          5,
          DateTime(2026, 9, 15),
        ).copyWith(createdAt: DateTime(2026, 9, 10 + i)),
    ],
  );

  Future<void> start(
    WidgetTester tester, {
    int daysUsed = 0,
    Map<String, Object> saved = const {},
    bool permission = true,
  }) async {
    settings = await testSettings({
      'setup_done': true,
      'walkthrough_seen': true,
      ...saved,
    });
    fake = used(daysUsed);
    reminders = FakeReminderService(permissionGranted: permission);
    provider = TransactionProvider(
      db: fake,
      clock: () => DateTime(2026, 9, 15, 10),
      reminders: reminders,
    );
    // As the app does it: what is scheduled follows the settings
    // already saved (NUDGE-4, NUDGE-8).
    await provider.load(
      appLockOn: settings.appLock,
      nudge: settings.nudgeSettings,
    );
  }

  Future<void> showHome(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      testApp(provider, settings, const HomeScreen(), reminders: reminders),
    );
    await tester.pumpAndSettle();
  }

  group('the offer, once (NUDGE-3)', () {
    testWidgets('nothing is offered to someone who has barely started', (
      tester,
    ) async {
      await start(tester, daysUsed: 2);
      await showHome(tester);

      expect(find.text('A nudge on the days you forget?'), findsNothing);
    });

    testWidgets('after three days of use, Home asks once', (tester) async {
      await start(tester, daysUsed: 3);
      await showHome(tester);

      expect(find.text('A nudge on the days you forget?'), findsOneWidget);
    });

    testWidgets('saying yes turns it on and asks the phone first (NUDGE-7)', (
      tester,
    ) async {
      await start(tester, daysUsed: 3);
      await showHome(tester);

      await tester.tap(find.text('A nudge on the days you forget?'));
      await tester.pumpAndSettle();

      expect(reminders.permissionRequests, 1);
      expect(settings.emptyDayNudge, isTrue);
      expect(settings.nudgeOffered, isTrue);
      expect(find.text('A nudge on the days you forget?'), findsNothing);
    });

    testWidgets('a phone that refuses leaves it off and says so', (
      tester,
    ) async {
      await start(tester, daysUsed: 3, permission: false);
      await showHome(tester);

      await tester.tap(find.text('A nudge on the days you forget?'));
      await tester.pumpAndSettle();

      expect(settings.emptyDayNudge, isFalse);
      expect(
        find.text('Turn on notifications in system settings to get reminders.'),
        findsOneWidget,
      );
      // Asked once is asked once, however it went.
      expect(settings.nudgeOffered, isTrue);
    });

    testWidgets('saying no thanks is the end of it', (tester) async {
      await start(tester, daysUsed: 3);
      await showHome(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(settings.nudgeOffered, isTrue);
      expect(settings.emptyDayNudge, isFalse);
      expect(find.text('A nudge on the days you forget?'), findsNothing);
    });
  });

  group('what gets scheduled (NUDGE-1)', () {
    testWidgets('nothing at all while it is off and nothing is due', (
      tester,
    ) async {
      await start(tester, daysUsed: 1);
      await showHome(tester);

      expect(reminders.nudges, isEmpty);
    });

    testWidgets('turning it on schedules the nights ahead', (tester) async {
      await start(tester, daysUsed: 3);
      await showHome(tester);

      await tester.tap(find.text('A nudge on the days you forget?'));
      await tester.pumpAndSettle();

      expect(reminders.nudges, hasLength(reminderHorizonDays - 1));
      expect(
        reminders.nudges.every((r) => r.kind == ReminderKind.emptyDay),
        isTrue,
        reason: 'today already has an entry in it (NUDGE-4)',
      );
    });

    testWidgets('with app lock on they name nothing (NUDGE-8)', (tester) async {
      await start(
        tester,
        daysUsed: 3,
        saved: {'app_lock': true, 'empty_day_nudge': true},
      );
      await showHome(tester);

      expect(reminders.nudgesLocked, isTrue);
    });
  });

  group('the switch in Settings (NUDGE-5, NUDGE-7)', () {
    Future<void> showSettings(WidgetTester tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(
        testApp(
          provider,
          settings,
          const SettingsScreen(),
          reminders: reminders,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('it is there, and off to begin with', (tester) async {
      await start(tester);
      await showSettings(tester);

      await tester.scrollUntilVisible(
        find.text('Remind me on an empty day'),
        200,
      );
      final tile = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Remind me on an empty day'),
      );

      expect(tile.value, isFalse);
    });

    testWidgets('turning it on from Settings asks the phone and schedules '
        '(NUDGE-7)', (tester) async {
      await start(tester);
      await showSettings(tester);
      await tester.scrollUntilVisible(
        find.text('Remind me on an empty day'),
        200,
      );

      await tester.tap(find.text('Remind me on an empty day'));
      await tester.pumpAndSettle();

      expect(reminders.permissionRequests, 1);
      expect(settings.emptyDayNudge, isTrue);
      expect(reminders.nudges, isNotEmpty);
      // Asking here counts as the offer, so Home never asks as well.
      expect(settings.nudgeOffered, isTrue);
    });

    testWidgets('a phone that refuses leaves the switch alone', (tester) async {
      await start(tester, permission: false);
      await showSettings(tester);
      await tester.scrollUntilVisible(
        find.text('Remind me on an empty day'),
        200,
      );

      await tester.tap(find.text('Remind me on an empty day'));
      await tester.pumpAndSettle();

      expect(settings.emptyDayNudge, isFalse);
      expect(
        find.text('Turn on notifications in system settings to get reminders.'),
        findsOneWidget,
      );
    });

    testWidgets('turning it off takes back what was scheduled', (tester) async {
      await start(tester, saved: {'empty_day_nudge': true});
      await showSettings(tester);
      await tester.scrollUntilVisible(
        find.text('Remind me on an empty day'),
        200,
      );

      await tester.tap(find.text('Remind me on an empty day'));
      await tester.pumpAndSettle();

      expect(settings.emptyDayNudge, isFalse);
      expect(reminders.nudges, isEmpty);
      // Turning it off is not a permission question.
      expect(reminders.permissionRequests, 0);
    });

    testWidgets('the time it fires is shown while it is on (NUDGE-4)', (
      tester,
    ) async {
      await start(tester, saved: {'empty_day_nudge': true});
      await showSettings(tester);
      await tester.scrollUntilVisible(find.text('Reminder time'), 200);

      expect(find.text('9:00 PM'), findsOneWidget);
    });

    testWidgets('and not while it is off, since there is no time to show', (
      tester,
    ) async {
      await start(tester);
      await showSettings(tester);
      await tester.scrollUntilVisible(
        find.text('Remind me on an empty day'),
        200,
      );

      expect(find.text('Reminder time'), findsNothing);
    });

    testWidgets('one that gave up says why rather than looking switched off '
        '(NUDGE-5)', (tester) async {
      await start(tester, saved: {'empty_day_nudge_stopped': true});
      await showSettings(tester);

      await tester.scrollUntilVisible(
        find.text('Remind me on an empty day'),
        200,
      );

      expect(
        find.textContaining('after three went unanswered'),
        findsOneWidget,
      );
    });

    testWidgets(
      'a phone currently blocking notifications is flagged even though '
      'the switch stayed on (NUDGE-7)',
      (tester) async {
        await start(tester, saved: {'empty_day_nudge': true});
        settings.setNotificationsBlocked(true);
        await showSettings(tester);

        await tester.scrollUntilVisible(
          find.text('Remind me on an empty day'),
          200,
        );

        final tile = tester.widget<SwitchListTile>(
          find.widgetWithText(SwitchListTile, 'Remind me on an empty day'),
        );
        // NUDGE-7: the switch stays as the user left it -- this is not a
        // refusal, and turning it off is the user's call, not the app's.
        expect(tile.value, isTrue);
        expect(
          find.text(
            'Turn on notifications in system settings to get reminders.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'a phone that allows them again shows the ordinary row (NUDGE-7)',
      (tester) async {
        await start(tester, saved: {'empty_day_nudge': true});
        settings.setNotificationsBlocked(false);
        await showSettings(tester);

        await tester.scrollUntilVisible(
          find.text('Remind me on an empty day'),
          200,
        );

        expect(
          find.textContaining('Turn on notifications in system settings'),
          findsNothing,
        );
      },
    );
  });
}
