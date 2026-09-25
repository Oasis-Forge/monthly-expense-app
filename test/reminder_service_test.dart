import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/note.dart';
import 'package:monthly_expense_app/services/reminder_service.dart';

import 'helpers.dart';

/// Direct unit tests for [reminderActionFor], the pure decision
/// [DeviceReminderService.schedule] and `FakeReminderService.schedule`
/// (test/helpers.dart) both defer to (pr59#9): a widget or provider test
/// that only drives the fake proves nothing about the device unless both
/// sides are known to agree, and this is what proves that.
void main() {
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
  });
}
