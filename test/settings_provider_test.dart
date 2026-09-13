import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_expense_app/models/period.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';

void main() {
  Future<SharedPreferences> prefsWith(Map<String, Object> values) {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test(
    'defaults: device currency, system theme, month starts on the 1st',
    () async {
      final prefs = await prefsWith({});

      final british = SettingsProvider(prefs, deviceLocale: 'en_GB');
      expect(british.currencyCode, 'GBP');
      expect(british.themeMode, ThemeMode.system);
      expect(british.startDay, 1);
      expect(british.showCarriedForward, isTrue);

      expect(
        SettingsProvider(prefs, deviceLocale: 'xx_YY').currencyCode,
        'USD',
      );
    },
  );

  test('saved settings are read back, and changes persist', () async {
    final prefs = await prefsWith({
      'currency_code': 'JPY',
      'theme_mode': 'dark',
      'month_start_day': 25,
      'show_carried_forward': false,
    });

    final settings = SettingsProvider(prefs, deviceLocale: 'en_US');
    expect(
      (
        settings.currencyCode,
        settings.themeMode,
        settings.startDay,
        settings.showCarriedForward,
      ),
      ('JPY', ThemeMode.dark, 25, false),
    );

    await settings.setCurrencyCode('EUR');
    await settings.setThemeMode(ThemeMode.light);
    await settings.setStartDay(Period.lastDayOfMonth);
    await settings.setShowCarriedForward(true);

    final reread = SettingsProvider(prefs);
    expect(
      (
        reread.currencyCode,
        reread.themeMode,
        reread.startDay,
        reread.showCarriedForward,
      ),
      ('EUR', ThemeMode.light, Period.lastDayOfMonth, true),
    );
  });

  test('an invalid saved start day falls back to the 1st', () async {
    final prefs = await prefsWith({'month_start_day': 30});

    expect(SettingsProvider(prefs).startDay, 1);
  });

  test('the currency format uses its symbol and decimals (CUR-2)', () async {
    final settings = SettingsProvider(
      await prefsWith({'currency_code': 'JPY'}),
    );

    final yen = settings.currencyFormat('en');
    expect(yen.maximumFractionDigits, 0);
    expect(yen.format(1234), '¥1,234');

    await settings.setCurrencyCode('KWD');
    expect(settings.currencyFormat('en').maximumFractionDigits, 3);
  });

  test('the compact format shortens large amounts', () async {
    final settings = SettingsProvider(await prefsWith({}));

    expect(settings.compactCurrencyFormat('en').format(1200), '\$1.2K');
  });

  test('week start, backup reminder, and app lock persist '
      '(PER-4, BAK-7, LOCK-1)', () async {
    final prefs = await prefsWith({'week_start_day': 9});

    final settings = SettingsProvider(prefs);
    expect(
      (settings.weekStartDay, settings.backupReminder, settings.appLock),
      (null, true, false),
    );

    await settings.setWeekStartDay(1);
    await settings.setBackupReminder(false);
    await settings.setAppLock(true);
    final reread = SettingsProvider(prefs);
    expect(
      (reread.weekStartDay, reread.backupReminder, reread.appLock),
      (1, false, true),
    );

    await reread.setWeekStartDay(null);
    expect(SettingsProvider(prefs).weekStartDay, isNull);
  });

  test('the backup reminder waits for 20 transactions, a day, and 30 days '
      'between reminders (BAK-7)', () async {
    var now = DateTime(2026, 9, 1, 9);
    final prefs = await prefsWith({});
    final settings = SettingsProvider(prefs, clock: () => now);

    // Never on the day the app was first opened.
    expect(settings.backupReminderDue(50), isFalse);

    now = DateTime(2026, 9, 2, 10);
    expect(settings.backupReminderDue(19), isFalse);
    expect(settings.backupReminderDue(20), isTrue);

    await settings.recordBackup();
    now = DateTime(2026, 10, 1, 9);
    expect(settings.backupReminderDue(20), isFalse);
    now = DateTime(2026, 10, 2, 10);
    expect(settings.backupReminderDue(20), isTrue);

    await settings.snoozeBackupReminder();
    now = DateTime(2026, 10, 20);
    expect(settings.backupReminderDue(20), isFalse);

    // Both dates survive a restart.
    final reread = SettingsProvider(prefs, clock: () => now);
    expect(
      reread.lastBackupAt!.isAtSameMomentAs(DateTime(2026, 9, 2, 10)),
      isTrue,
    );
    expect(reread.backupReminderDue(20), isFalse);

    await settings.setBackupReminder(false);
    now = DateTime(2027);
    expect(settings.backupReminderDue(100), isFalse);
  });

  test('backups carry display settings, and restore only valid ones '
      '(BAK-1)', () async {
    final source = SettingsProvider(
      await prefsWith({
        'currency_code': 'EUR',
        'theme_mode': 'dark',
        'month_start_day': 25,
        'show_carried_forward': false,
        'week_start_day': 6,
        'app_lock': true,
      }),
    );
    final values = source.backupValues;
    expect(values, {
      'currency_code': 'EUR',
      'theme_mode': 'dark',
      'month_start_day': 25,
      'show_carried_forward': false,
      'week_start_day': 6,
    });

    final target = SettingsProvider(await prefsWith({}), deviceLocale: 'en_US');
    await target.restoreBackupValues(values);
    expect(
      (
        target.currencyCode,
        target.themeMode,
        target.startDay,
        target.showCarriedForward,
        target.weekStartDay,
        target.appLock,
      ),
      ('EUR', ThemeMode.dark, 25, false, 6, false),
    );

    await target.restoreBackupValues({
      'currency_code': 'euro',
      'month_start_day': 30,
      'week_start_day': 9,
      'show_carried_forward': 'yes',
    });
    expect(
      (
        target.currencyCode,
        target.startDay,
        target.weekStartDay,
        target.showCarriedForward,
      ),
      ('EUR', 25, 6, false),
    );

    await target.restoreBackupValues({'week_start_day': null});
    expect(target.weekStartDay, isNull);
  });
}
