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

  group('amounts in right-to-left languages', () {
    test('Arabic writes the Arab currencies in Arabic (LANG-3)', () async {
      final settings = SettingsProvider(
        await prefsWith({'currency_code': 'SAR'}),
      );

      final riyal = settings.currencyFormat('ar');
      expect(riyal.currencySymbol, 'ر.س.');
      expect(riyal.format(46223.34), '\u206646,223.34\u00A0ر.س.\u2069');
      expect(
        settings.compactCurrencyFormat('ar').format(1200),
        contains('ر.س.'),
      );
      // Other languages keep intl's symbol.
      expect(settings.currencyFormat('en').currencySymbol, isNot('ر.س.'));

      // The currency's own decimals still hold (CUR-2).
      await settings.setCurrencyCode('KWD');
      expect(settings.currencyFormat('ar').format(1), contains('1.000'));
    });

    test(
      'an amount is one left-to-right piece, sign included (LANG-5)',
      () async {
        final settings = SettingsProvider(
          await prefsWith({'currency_code': 'SAR'}),
        );
        expect(
          settings.currencyFormat('ar').format(-132),
          '\u2066-132.00\u00A0ر.س.\u2069',
        );

        await settings.setCurrencyCode('USD');
        expect(settings.currencyFormat('ur').format(-5), '\u2066-\$5.00\u2069');
        // Left-to-right languages need no marks.
        expect(settings.currencyFormat('en').format(-5), '-\$5.00');
      },
    );

    test('the PDF report gets the symbol without the marks', () async {
      final settings = SettingsProvider(
        await prefsWith({'currency_code': 'SAR'}),
      );

      final report = settings.currencyFormat('ar', isolated: false);
      expect(report.format(5), contains('ر.س.'));
      expect(report.format(5), isNot(contains('\u2066')));
    });

    testWidgets('an amount looks the same in left-to-right and right-to-left '
        'text (LANG-5)', (tester) async {
      final settings = SettingsProvider(
        await prefsWith({'currency_code': 'SAR'}),
      );
      final currency = settings.currencyFormat('ar');

      // The characters as they sit on screen, from left to right.
      String onScreen(String text, TextDirection direction) {
        final painter = TextPainter(
          text: TextSpan(text: text),
          textDirection: direction,
        )..layout();
        addTearDown(painter.dispose);
        final left = <int, double>{};
        for (var i = 0; i < text.length; i++) {
          final boxes = painter.getBoxesForSelection(
            TextSelection(baseOffset: i, extentOffset: i + 1),
          );
          if (boxes.isNotEmpty && boxes.first.right > boxes.first.left) {
            left[i] = boxes.first.left;
          }
        }
        final order = left.keys.toList()
          ..sort((a, b) => left[a]!.compareTo(left[b]!));
        return order.map((i) => text[i]).join();
      }

      // The summary and most screens show an amount inside Arabic text.
      for (final amount in [46223.34, -132]) {
        final text = currency.format(amount);
        expect(
          onScreen(text, TextDirection.rtl),
          onScreen(text, TextDirection.ltr),
          reason: text,
        );
      }
      // The list draws its amounts left to right with its own sign in front,
      // and must match a negative amount anywhere else.
      expect(
        onScreen('-${currency.format(132)}', TextDirection.ltr),
        onScreen(currency.format(-132), TextDirection.rtl),
      );
      // Without the marks the order does change: the summary put the symbol
      // on one side of the amount and the list on the other.
      final unmarked = settings.currencyFormat('ar', isolated: false);
      expect(
        onScreen(unmarked.format(46223.34), TextDirection.rtl),
        isNot(onScreen(unmarked.format(46223.34), TextDirection.ltr)),
      );
    });
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
      'language': null,
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

  test('setup and the walkthrough wait for a first launch, not an update '
      '(RUN-5)', () async {
    final fresh = await prefsWith({});
    final first = SettingsProvider(fresh);
    expect((first.setupDone, first.walkthroughSeen), (false, false));

    // Closed on the setup page: the next launch is not an update.
    await Future<void>.delayed(Duration.zero);
    final again = SettingsProvider(fresh);
    expect((again.setupDone, again.walkthroughSeen), (false, false));

    await again.completeSetup();
    await again.completeWalkthrough();
    final settled = SettingsProvider(fresh);
    expect((settled.setupDone, settled.walkthroughSeen), (true, true));

    // A phone that used an older version has a first-opened date already.
    final old = SettingsProvider(
      await prefsWith({'first_opened_at': '2026-01-04T08:00:00.000Z'}),
    );
    expect((old.setupDone, old.walkthroughSeen), (true, true));
  });

  test('language follows the device until one is chosen (LANG-1)', () async {
    final prefs = await prefsWith({'language': 'xx'});
    final settings = SettingsProvider(prefs);
    expect((settings.languageCode, settings.locale), (null, null));

    await settings.setLanguageCode('tr');
    expect(SettingsProvider(prefs).locale, const Locale('tr'));
    expect(settings.backupValues['language'], 'tr');

    await settings.setLanguageCode(null);
    expect(SettingsProvider(prefs).languageCode, isNull);

    await settings.restoreBackupValues({'language': 'ar'});
    expect(settings.languageCode, 'ar');
    await settings.restoreBackupValues({'language': 'klingon'});
    await settings.restoreBackupValues({'currency_code': 'EUR'});
    expect(settings.languageCode, 'ar');
    await settings.restoreBackupValues({'language': null});
    expect(settings.languageCode, isNull);
  });
}
