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
    });

    final settings = SettingsProvider(prefs, deviceLocale: 'en_US');
    expect(
      (settings.currencyCode, settings.themeMode, settings.startDay),
      ('JPY', ThemeMode.dark, 25),
    );

    await settings.setCurrencyCode('EUR');
    await settings.setThemeMode(ThemeMode.light);
    await settings.setStartDay(Period.lastDayOfMonth);

    final reread = SettingsProvider(prefs);
    expect(
      (reread.currencyCode, reread.themeMode, reread.startDay),
      ('EUR', ThemeMode.light, Period.lastDayOfMonth),
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
}
