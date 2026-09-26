import 'dart:io';

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/note.dart';
import 'package:monthly_expense_app/models/reminders.dart';
import 'package:monthly_expense_app/services/reminder_service.dart';

import 'helpers.dart';

/// Direct unit tests for [reminderActionFor], the pure decision
/// [DeviceReminderService.schedule] and `FakeReminderService.schedule`
/// (test/helpers.dart) both defer to (pr59#9): a widget or provider test
/// that only drives the fake proves nothing about the device unless both
/// sides are known to agree, and this is what proves that.
void main() {
  // Needed below for TestDefaultBinaryMessengerBinding.instance, since this
  // file uses plain test() rather than testWidgets() (which does this on its
  // own).
  TestWidgetsFlutterBinding.ensureInitialized();

  final at = DateTime(2026, 9, 20, 9);

  group('reminderActionFor', () {
    test('a future time is scheduled', () {
      expect(
        reminderActionFor(
          testNote('a', 'Remind me', reminderAt: at),
          lastScheduledAt: null,
          now: at.subtract(const Duration(minutes: 1)),
        ),
        ReminderAction.schedule,
      );
    });

    test('a passed time within the grace window, unchanged, is kept', () {
      expect(
        reminderActionFor(
          testNote('a', 'Remind me', reminderAt: at),
          lastScheduledAt: at,
          now: at.add(const Duration(minutes: 1)),
        ),
        ReminderAction.keep,
      );
    });

    test('a passed time within the grace window, never scheduled before, is '
        'kept too -- there is simply nothing to cancel', () {
      expect(
        reminderActionFor(
          testNote('a', 'Remind me', reminderAt: at),
          lastScheduledAt: null,
          now: at.add(const Duration(minutes: 1)),
        ),
        ReminderAction.keep,
      );
    });

    test('a passed time that changed since it was last scheduled is '
        'cancelled, even within the grace window', () {
      expect(
        reminderActionFor(
          testNote('a', 'Remind me', reminderAt: at),
          lastScheduledAt: at.subtract(const Duration(hours: 1)),
          now: at.add(const Duration(minutes: 1)),
        ),
        ReminderAction.cancel,
      );
    });

    test('a time more than two hours past is cancelled', () {
      expect(
        reminderActionFor(
          testNote('a', 'Remind me', reminderAt: at),
          lastScheduledAt: at,
          now: at.add(const Duration(hours: 2, minutes: 1)),
        ),
        ReminderAction.cancel,
      );
    });

    test('a done note is cancelled, whatever its time', () {
      expect(
        reminderActionFor(
          testNote('a', 'Remind me', reminderAt: at, doneAt: at),
          lastScheduledAt: at,
          now: at.subtract(const Duration(minutes: 1)),
        ),
        ReminderAction.cancel,
      );
    });

    test('a deleted note is cancelled, whatever its time', () {
      expect(
        reminderActionFor(
          Note(
            id: 'a',
            text: 'Remind me',
            reminderAt: at,
            deletedAt: DateTime(2026, 9, 20, 10),
          ),
          lastScheduledAt: at,
          now: at.subtract(const Duration(minutes: 1)),
        ),
        ReminderAction.cancel,
      );
    });

    test('no reminder at all is cancelled', () {
      expect(
        reminderActionFor(
          testNote('a', 'No reminder'),
          lastScheduledAt: null,
          now: at,
        ),
        ReminderAction.cancel,
      );
    });
  });

  group('lockKeepActionFor (LOCK-2, x-reminder-lock-keep)', () {
    test(
      'app lock off leaves whatever the device has alone, active or not',
      () {
        for (final isActive in [true, false]) {
          for (final isPending in [true, false]) {
            expect(
              lockKeepActionFor(
                appLockOn: false,
                isActive: isActive,
                isPending: isPending,
              ),
              LockKeepAction.none,
              reason: 'isActive: $isActive, isPending: $isPending',
            );
          }
        }
      },
    );

    test('app lock on and already delivered: re-shown with the locked wording, '
        'which replaces it rather than adding a second one', () {
      expect(
        lockKeepActionFor(appLockOn: true, isActive: true, isPending: false),
        LockKeepAction.reshow,
      );
      // Active takes priority even if somehow also reported pending.
      expect(
        lockKeepActionFor(appLockOn: true, isActive: true, isPending: true),
        LockKeepAction.reshow,
      );
    });

    test('app lock on and still pending: cancelled and laid again with the '
        'locked wording, not shown this instant', () {
      expect(
        lockKeepActionFor(appLockOn: true, isActive: false, isPending: true),
        LockKeepAction.reschedule,
      );
    });

    test('app lock on but the device has nothing for it: nothing to do -- it '
        'was already delivered and dismissed, or never scheduled at all', () {
      expect(
        lockKeepActionFor(appLockOn: true, isActive: false, isPending: false),
        LockKeepAction.none,
      );
    });

    test('no memory of app lock is needed: a cold start decides purely from '
        'what the device reports, this call carrying no history at all', () {
      // Called exactly as a first call after a cold start would be, with
      // nothing remembered about whether app lock was already on.
      expect(
        lockKeepActionFor(appLockOn: true, isActive: true, isPending: false),
        LockKeepAction.reshow,
      );
    });

    test('already locked and active: nothing to do, so a delivered '
        'notification is not alerted again on every reschedule '
        '(x-reminder-lock-keep)', () {
      expect(
        lockKeepActionFor(
          appLockOn: true,
          isActive: true,
          isPending: false,
          alreadyLocked: true,
        ),
        LockKeepAction.none,
      );
    });

    test('already locked and pending: nothing to do, so a still-pending '
        'alarm is not cancelled and re-laid a minute out on every '
        'reschedule (x-reminder-lock-keep)', () {
      expect(
        lockKeepActionFor(
          appLockOn: true,
          isActive: false,
          isPending: true,
          alreadyLocked: true,
        ),
        LockKeepAction.none,
      );
    });
  });

  group('FakeReminderService.schedule mirrors the device on a cold-start '
      'keep (x-reminder-lock-keep, pr59#9)', () {
    test('records the time it kept, so a later edit is told apart from an '
        'unchanged passed time the same way DeviceReminderService does', () {
      // now is fixed 30 minutes after `at`, so both `at` and the edited,
      // earlier time below are passed times, well inside the grace window.
      final fake = FakeReminderService(
        now: () => at.add(const Duration(minutes: 30)),
      );
      // Stands in for a reminder the device already has pending from
      // before a cold start -- the fake's own bookkeeping (_lastScheduledAt)
      // starts out empty regardless, exactly as it does after one.
      fake.scheduled['a'] = false;
      final note = testNote('a', 'Remind me', reminderAt: at);

      // The cold-start keep: nothing was ever scheduled before (as far as
      // this instance's memory goes), so this keeps without touching
      // `scheduled` -- but must still remember `at`, as
      // DeviceReminderService always does after a keep.
      fake.schedule(note, appLockOn: false, locale: const Locale('en'));
      expect(fake.scheduled.containsKey('a'), isTrue);

      // The note is then edited to an earlier time. A real device would
      // see its own last-scheduled time no longer match and cancel the
      // stale alarm outright; a fake that forgot the time it just kept
      // would instead see "never scheduled" again and wrongly keep it.
      final edited = testNote(
        'a',
        'Remind me',
        reminderAt: at.subtract(const Duration(minutes: 45)),
      );
      fake.schedule(edited, appLockOn: false, locale: const Locale('en'));

      expect(fake.scheduled.containsKey('a'), isFalse);
    });
  });

  group(
    'DeviceReminderService on iOS and macOS (NOTE-6, NUDGE-1, NUDGE-7)',
    () {
      const channel = MethodChannel(
        'dexterous.com/flutter/local_notifications',
      );
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      late List<MethodCall> calls;
      var grant = true;
      var enabled = true;

      setUp(() {
        calls = [];
        grant = true;
        enabled = true;
        messenger.setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'initialize':
              return true;
            case 'getNotificationAppLaunchDetails':
              return null;
            case 'requestPermissions':
              return grant;
            case 'checkPermissions':
              return {'isEnabled': enabled};
            default:
              return null;
          }
        });
      });

      tearDown(() {
        messenger.setMockMethodCallHandler(channel, null);
        debugDefaultTargetPlatformOverride = null;
      });

      // The plugin picks its platform implementation off
      // defaultTargetPlatform, exactly as the device does; nothing here is
      // iOS/macOS-specific beyond that switch (pr59_7).
      for (final platform in [TargetPlatform.iOS, TargetPlatform.macOS]) {
        void useThisPlatform() {
          debugDefaultTargetPlatformOverride = platform;
          FlutterLocalNotificationsPlatform.instance =
              platform == TargetPlatform.iOS
              ? IOSFlutterLocalNotificationsPlugin()
              : MacOSFlutterLocalNotificationsPlugin();
        }

        group(platform.name, () {
          test(
            'initializing asks the OS for no permission up front, so it '
            'does not prompt before any reminder is ever turned on',
            () async {
              useThisPlatform();
              await DeviceReminderService().requestPermission();

              final init = calls.singleWhere((c) => c.method == 'initialize');
              final settings = init.arguments as Map<dynamic, dynamic>;
              expect(settings['requestAlertPermission'], isFalse);
              expect(settings['requestSoundPermission'], isFalse);
              expect(settings['requestBadgePermission'], isFalse);
            },
          );

          test('turning on a reminder asks for alert, sound and badge -- the '
              'same moment Android is asked for POST_NOTIFICATIONS', () async {
            useThisPlatform();
            final granted = await DeviceReminderService().requestPermission();

            expect(granted, isTrue);
            final request = calls.singleWhere(
              (c) => c.method == 'requestPermissions',
            );
            expect(request.arguments, {
              'sound': true,
              'alert': true,
              'badge': true,
              'provisional': false,
              'critical': false,
              // CarPlay is iOS-only; MacOSFlutterLocalNotificationsPlugin's
              // requestPermissions() has no such parameter at all.
              if (platform == TargetPlatform.iOS) 'carPlay': false,
              'providesAppNotificationSettings': false,
            });
          });

          test('a refusal is reported back as false, the same as a refusal on '
              'Android is', () async {
            grant = false;
            useThisPlatform();

            expect(await DeviceReminderService().requestPermission(), isFalse);
          });

          test('areNotificationsEnabled follows the live OS permission, the '
              'same way it already does on Android, so a refusal or a later '
              'revoke in Settings shows as blocked instead of always enabled '
              '(NUDGE-7)', () async {
            useThisPlatform();
            final service = DeviceReminderService();

            enabled = false;
            expect(await service.areNotificationsEnabled(), isFalse);

            enabled = true;
            expect(await service.areNotificationsEnabled(), isTrue);

            expect(
              calls.where((c) => c.method == 'checkPermissions'),
              isNotEmpty,
            );
          });
        });
      }
    },
  );

  group('AppDelegate sets the notification delegate (NOTE-6, NUDGE-1)', () {
    test(
      'UNUserNotificationCenter has a delegate, so a tapped note reminder '
      'or nudge on iOS reaches the app instead of doing nothing (pr59_7)',
      () {
        final appDelegate = File('ios/Runner/AppDelegate.swift')
            .readAsStringSync();
        expect(
          appDelegate,
          contains('UNUserNotificationCenter.current().delegate'),
          reason:
              'Without this, flutter_local_notifications never learns a '
              'notification was tapped on iOS.',
        );
      },
    );
  });

  group('nudgeBody (NUDGE-2, rules-23-26-34#9)', () {
    late AppLocalizations l10n;
    final currency = NumberFormat.simpleCurrency(locale: 'en_US');

    setUpAll(() async {
      await initializeDateFormatting('en');
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('a single due-today entry names the amount and says "today"', () {
      final body = nudgeBody(
        l10n,
        PlannedReminder(
          kind: ReminderKind.dueEntry,
          at: DateTime(2026, 9, 20, 9),
          title: 'Rent',
          dueDate: DateTime(2026, 9, 20),
          amount: const Money(1200000),
        ),
        currency: currency,
      );

      expect(body, 'Rent (-\$1,200) was due today and is still waiting.');
    });

    test('an entry carried over from an earlier day names that day instead of '
        'claiming it is today\'s', () {
      final body = nudgeBody(
        l10n,
        PlannedReminder(
          kind: ReminderKind.dueEntry,
          // Fires this morning...
          at: DateTime(2026, 9, 23, 9),
          title: 'Rent',
          // ...but really fell due three days earlier.
          dueDate: DateTime(2026, 9, 20),
          amount: const Money(1200000),
        ),
        currency: currency,
      );

      expect(body, contains('Sep 20, 2026'));
      expect(body, isNot(contains('today')));
    });

    test('income is signed with a plus, an expense with a minus (CUR-5)', () {
      final income = nudgeBody(
        l10n,
        PlannedReminder(
          kind: ReminderKind.dueEntry,
          at: DateTime(2026, 9, 20, 9),
          title: 'Salary',
          dueDate: DateTime(2026, 9, 20),
          amount: const Money(500000),
          isIncome: true,
        ),
        currency: currency,
      );
      expect(income, contains('+\$500'));

      final expense = nudgeBody(
        l10n,
        PlannedReminder(
          kind: ReminderKind.dueEntry,
          at: DateTime(2026, 9, 20, 9),
          title: 'Rent',
          dueDate: DateTime(2026, 9, 20),
          amount: const Money(500000),
        ),
        currency: currency,
      );
      expect(expense, contains('-\$500'));
    });

    test('an untitled entry still names the amount and the right day', () {
      final body = nudgeBody(
        l10n,
        PlannedReminder(
          kind: ReminderKind.dueEntry,
          at: DateTime(2026, 9, 23, 9),
          dueDate: DateTime(2026, 9, 21),
          amount: const Money(75000),
        ),
        currency: currency,
      );

      expect(body, startsWith('A repeating entry (-\$75)'));
      expect(body, contains('Sep 21, 2026'));
    });

    test('several due the same day are a count, with no amount or date at all '
        '(NUDGE-2)', () {
      final body = nudgeBody(
        l10n,
        PlannedReminder(
          kind: ReminderKind.dueEntry,
          at: DateTime(2026, 9, 20, 9),
          count: 2,
        ),
        currency: currency,
      );

      expect(body, '2 repeating entries were due today.');
    });

    test('a group with one overdue occurrence carried over says "waiting", '
        'not "due today" (rules-23-26-34#9)', () {
      final body = nudgeBody(
        l10n,
        PlannedReminder(
          kind: ReminderKind.dueEntry,
          at: DateTime(2026, 9, 20, 9),
          count: 2,
          anyOverdue: true,
        ),
        currency: currency,
      );

      expect(body, '2 repeating entries are waiting.');
      expect(body, isNot(contains('today')));
    });

    test('an empty day carries no amount at all', () {
      final body = nudgeBody(
        l10n,
        PlannedReminder(
          kind: ReminderKind.emptyDay,
          at: DateTime(2026, 9, 20, 21),
        ),
        currency: currency,
      );

      expect(body, l10n.emptyDayReminderBody);
    });
  });
}
