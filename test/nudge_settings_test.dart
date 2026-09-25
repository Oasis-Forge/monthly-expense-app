import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_expense_app/models/reminders.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';

import 'helpers.dart';

void main() {
  group('the offer, made once (NUDGE-3)', () {
    test('not before three days have been recorded on', () async {
      final settings = await testSettings();

      expect(settings.nudgeOfferDue(2), isFalse);
      expect(settings.nudgeOfferDue(3), isTrue);
    });

    test('not once it has been made, whatever the answer', () async {
      final settings = await testSettings();

      await settings.markNudgeOffered();

      expect(settings.nudgeOfferDue(10), isFalse);
      expect(settings.nudgeOfferPending, isFalse);
    });

    test('not to someone who already has it on', () async {
      final settings = await testSettings();

      await settings.setEmptyDayNudge(true);

      expect(settings.nudgeOfferDue(10), isFalse);
    });

    test('it survives a restart', () async {
      final settings = await testSettings({'empty_day_nudge_offered': true});

      expect(settings.nudgeOfferDue(10), isFalse);
    });
  });

  group('the time it fires (NUDGE-4, NUDGE-6)', () {
    test('nine in the evening until it is changed', () async {
      final settings = await testSettings();

      expect(settings.nudgeHour, SettingsProvider.nudgeDefaultHour);
      expect(settings.nudgeMinute, 0);
    });

    test('a waking hour is kept as chosen', () async {
      final settings = await testSettings();

      await settings.setNudgeTime(8, 30);

      expect(settings.nudgeHour, 8);
      expect(settings.nudgeMinute, 30);
    });

    test('three in the morning is not', () async {
      final settings = await testSettings();

      await settings.setNudgeTime(3, 0);

      expect(settings.nudgeHour, SettingsProvider.nudgeDefaultHour);
    });

    test('nor is ten at night', () async {
      final settings = await testSettings();

      await settings.setNudgeTime(quietFromHour, 0);

      expect(settings.nudgeHour, SettingsProvider.nudgeDefaultHour);
    });

    test('a stored hour outside them is ignored too, so an old setting '
        'cannot wake anyone at three', () async {
      final settings = await testSettings({'empty_day_nudge_hour': 2});

      expect(settings.nudgeHour, SettingsProvider.nudgeDefaultHour);
    });

    test('what it is set to is what gets scheduled', () async {
      final settings = await testSettings();

      await settings.setEmptyDayNudge(true);
      await settings.setNudgeTime(20, 15);

      expect(
        settings.nudgeSettings,
        const NudgeSettings(on: true, hour: 20, minute: 15),
      );
    });
  });

  group('three ignored and it stops itself (NUDGE-5)', () {
    test('two is not enough', () async {
      final settings = await testSettings();
      await settings.setEmptyDayNudge(true);

      await settings.recordNudgesIgnored(2, DateTime(2026, 9, 24));

      expect(settings.emptyDayNudge, isTrue);
      expect(settings.nudgeStopped, isFalse);
    });

    test('three turns it off and says why', () async {
      final settings = await testSettings();
      await settings.setEmptyDayNudge(true);

      await settings.recordNudgesIgnored(3, DateTime(2026, 9, 24));

      expect(settings.emptyDayNudge, isFalse);
      expect(settings.nudgeStopped, isTrue);
      expect(settings.nudgeSettings.on, isFalse);
    });

    test('turning it back on clears the count and the reason', () async {
      final settings = await testSettings();
      await settings.setEmptyDayNudge(true);
      await settings.recordNudgesIgnored(3, DateTime(2026, 9, 24));

      await settings.setEmptyDayNudge(true);

      expect(settings.emptyDayNudge, isTrue);
      expect(settings.nudgeStopped, isFalse);
      expect(settings.nudgeIgnored, 0);
    });

    test(
      'an answer starts the count again without turning anything off',
      () async {
        final settings = await testSettings();
        await settings.setEmptyDayNudge(true);
        await settings.recordNudgesIgnored(2, DateTime(2026, 9, 24));

        await settings.answerNudge();

        expect(settings.nudgeIgnored, 0);
        expect(settings.emptyDayNudge, isTrue);
      },
    );

    test('it never stops one that was already off', () async {
      final settings = await testSettings();

      await settings.recordNudgesIgnored(5, DateTime(2026, 9, 24));

      expect(settings.nudgeStopped, isFalse, reason: 'nothing to stop');
    });

    test('when it was last counted is remembered, so a day is not counted '
        'twice', () async {
      final settings = await testSettings();

      await settings.recordNudgesIgnored(1, DateTime(2026, 9, 24, 22));

      expect(settings.nudgeCheckedAt, isNotNull);
    });
  });

  group('a phone blocking notifications (NUDGE-7)', () {
    test('not blocked to start with', () async {
      final settings = await testSettings();

      expect(settings.notificationsBlocked, isFalse);
    });

    test('a live check can flag it, and clear it again', () async {
      final settings = await testSettings();

      settings.setNotificationsBlocked(true);
      expect(settings.notificationsBlocked, isTrue);

      settings.setNotificationsBlocked(false);
      expect(settings.notificationsBlocked, isFalse);
    });

    test(
      'is not persisted: it reflects a live check, not a remembered one',
      () async {
        var settings = await testSettings();
        settings.setNotificationsBlocked(true);

        // A fresh instance over the same store, as a relaunch would build.
        settings = SettingsProvider(
          await SharedPreferences.getInstance(),
          deviceLocale: 'en_US',
        );

        expect(settings.notificationsBlocked, isFalse);
      },
    );
  });

  group('marking a check done without moving the count (NUDGE-5, NUDGE-7)', () {
    test(
      'records when, and leaves the ignored count and stopped flag alone',
      () async {
        final settings = await testSettings();
        await settings.setEmptyDayNudge(true);
        await settings.recordNudgesIgnored(2, DateTime(2026, 9, 22));

        await settings.recordNudgeCheckedAt(DateTime(2026, 9, 24));

        expect(settings.nudgeCheckedAt, DateTime(2026, 9, 24));
        expect(settings.nudgeIgnored, 2);
        expect(settings.nudgeStopped, isFalse);
        expect(settings.emptyDayNudge, isTrue);
      },
    );
  });
}
