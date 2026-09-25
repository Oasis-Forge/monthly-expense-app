import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_expense_app/models/app_theme.dart';
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
    await settings.setTheme(AppTheme.light);
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
      expect(riyal.format(46223.34), '\u200F\u206646,223.34\u2069\u00A0ر.س.');
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

    test('the figures carry the sign, and the symbol is left where the '
        'language puts it (LANG-5)', () async {
      final settings = SettingsProvider(
        await prefsWith({'currency_code': 'SAR'}),
      );
      // Arabic writes the figures first and the symbol after them, so only
      // the figures are isolated and the symbol is left to right-to-left
      // order, which carries it to the left of the line.
      expect(
        settings.currencyFormat('ar').format(-132),
        '\u200F\u2066-132.00\u2069\u00A0ر.س.',
      );

      await settings.setCurrencyCode('USD');
      // Urdu writes the symbol first, where it already falls on the left, so
      // the whole amount travels as one piece.
      expect(settings.currencyFormat('ur').format(-5), '\u2066-\$5.00\u2069');
      // Left-to-right languages need no marks at all.
      expect(settings.currencyFormat('en').format(-5), '-\$5.00');
    });

    test(
      'a symbol spelled in letters is kept off the digits (LANG-5)',
      () async {
        final settings = SettingsProvider(
          await prefsWith({'currency_code': 'PKR'}),
        );
        // CLDR's currencySpacing, which intl does not carry: `Rs12` and `Rp12`
        // read as one word, so a no-break space goes between.
        expect(
          settings.currencyFormat('ur').format(12),
          contains('Rs\u00A012'),
        );

        await settings.setCurrencyCode('IDR');
        expect(settings.currencyFormat('id').format(12), 'Rp\u00A012');

        // A sign needs none: the rule is for letters meeting digits.
        await settings.setCurrencyCode('USD');
        expect(settings.currencyFormat('en').format(12), '\$12.00');

        // CLDR looks at the one character that touches the digits, not at
        // whether the symbol has a letter in it somewhere: `R$` ends in a
        // sign, so it stays against the number.
        await settings.setCurrencyCode('BRL');
        expect(
          settings.currencyFormat('en').format(12),
          isNot(contains('\u00A0')),
          reason: settings.currencyFormat('en').format(12),
        );

        // The short form takes a symbol rather than a pattern, and has to
        // carry the same space, or the calendar disagrees with the total
        // printed above it.
        await settings.setCurrencyCode('IDR');
        expect(
          settings.compactCurrencyFormat('id').format(1234.5),
          startsWith('Rp\u00A0'),
        );
        await settings.setCurrencyCode('USD');
        expect(
          settings.compactCurrencyFormat('en').format(1234.5),
          isNot(contains('\u00A0')),
        );
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

    testWidgets('Arabic reads the figures first and the symbol after, so the '
        'symbol sits on the left (LANG-5)', (tester) async {
      final settings = SettingsProvider(
        await prefsWith({'currency_code': 'SAR'}),
      );
      final text = settings.currencyFormat('ar').format(-132);

      double leftOf(Pattern part) {
        final painter = TextPainter(
          text: TextSpan(text: text),
          textDirection: TextDirection.rtl,
        )..layout();
        addTearDown(painter.dispose);
        final at = text.indexOf(part);
        return painter
            .getBoxesForSelection(
              TextSelection(baseOffset: at, extentOffset: at + 1),
            )
            .first
            .left;
      }

      // Read from the right, that is the figures and then the symbol, which
      // is how Arabic writes an amount.
      expect(leftOf('ر'), lessThan(leftOf('1')));
      // The sign stays against its figures instead of being carried off to
      // the far end of the line.
      expect(leftOf('-'), lessThan(leftOf('1')));
      expect(leftOf('-'), greaterThan(leftOf('ر')));
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

  test('the currency preselected at setup is saved, not re-derived every '
      'launch (CUR-1, CUR-3, RUN-3, rules-11-13-20-21#6)', () async {
    final prefs = await prefsWith({});
    final setup = SettingsProvider(prefs, deviceLocale: 'ar_EG');
    expect(setup.currencyCode, 'EGP');

    // Continue on the setup page only calls completeSetup: most people
    // never open the currency picker (RUN-3).
    await setup.completeSetup();

    // The device's language changes later; the currency chosen at setup
    // must not silently follow it.
    final relaunched = SettingsProvider(prefs, deviceLocale: 'en_US');
    expect(relaunched.currencyCode, 'EGP');
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

  test('the summary card remembers being collapsed (BAL-6)', () async {
    final settings = SettingsProvider(await prefsWith({}));
    expect(settings.summaryCollapsed, isFalse);

    await settings.setSummaryCollapsed(true);
    expect(settings.summaryCollapsed, isTrue);

    // It is a view of this device, so it comes back from the phone's own
    // storage rather than from a backup.
    final reopened = SettingsProvider(
      await prefsWith({'summary_collapsed': true}),
    );
    expect(reopened.summaryCollapsed, isTrue);
  });
}
