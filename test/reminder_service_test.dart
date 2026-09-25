import 'package:flutter/widgets.dart' show Locale;
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
