import 'package:flutter/material.dart' show ChangeNotifier, ThemeMode;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/period.dart';

/// App settings kept in shared_preferences: currency (CUR-1–CUR-3), theme
/// mode, and the first day of the month (PER-2).
class SettingsProvider extends ChangeNotifier {
  /// Reads saved settings from [_prefs]. Without a saved currency, the
  /// currency of [deviceLocale] (such as `en_GB`) is preselected.
  SettingsProvider(this._prefs, {String? deviceLocale})
    : _currencyCode =
          _prefs.getString(_currencyKey) ?? defaultCurrencyFor(deviceLocale),
      _themeMode = _themeModeNamed(_prefs.getString(_themeKey)),
      _startDay = _validStartDay(_prefs.getInt(_startDayKey));

  static const _currencyKey = 'currency_code';
  static const _themeKey = 'theme_mode';
  static const _startDayKey = 'month_start_day';

  final SharedPreferences _prefs;
  String _currencyCode;
  ThemeMode _themeMode;
  int _startDay;

  String get currencyCode => _currencyCode;
  ThemeMode get themeMode => _themeMode;

  /// 1–28, or [Period.lastDayOfMonth].
  int get startDay => _startDay;

  /// The currency [locale] uses, or USD when intl doesn't know the locale.
  static String defaultCurrencyFor(String? locale) {
    try {
      return NumberFormat.simpleCurrency(locale: locale).currencyName ?? 'USD';
    } on ArgumentError {
      return 'USD';
    }
  }

  /// Formats amounts in the chosen currency for [locale], with that
  /// currency's decimals (CUR-2).
  NumberFormat currencyFormat(String locale) =>
      NumberFormat.simpleCurrency(locale: locale, name: _currencyCode);

  /// Changes the currency label only; stored amounts never change (CUR-3).
  Future<void> setCurrencyCode(String code) async {
    if (code == _currencyCode) return;
    await _prefs.setString(_currencyKey, code);
    _currencyCode = code;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    await _prefs.setString(_themeKey, mode.name);
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> setStartDay(int day) async {
    assert(_validStartDay(day) == day, 'Invalid month start day: $day');
    if (day == _startDay) return;
    await _prefs.setInt(_startDayKey, day);
    _startDay = day;
    notifyListeners();
  }

  static ThemeMode _themeModeNamed(String? name) {
    for (final mode in ThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return ThemeMode.system;
  }

  static int _validStartDay(int? day) =>
      day != null && ((day >= 1 && day <= 28) || day == Period.lastDayOfMonth)
      ? day
      : 1;
}
