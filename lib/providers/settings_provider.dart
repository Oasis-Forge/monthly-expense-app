import 'dart:async' show unawaited;

import 'package:flutter/material.dart' show ChangeNotifier, Locale, ThemeMode;
import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart' show numberFormatSymbols;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminders.dart';

import '../l10n/languages.dart';
import '../models/currencies.dart' show arabicCurrencySymbols;
import '../models/period.dart';

/// App settings kept in shared_preferences: language (LANG-1), currency
/// (CUR-1–CUR-3), theme mode, the first day of the month (PER-2) and of the
/// week (PER-4), whether Home carries the balance forward (BAL-3), the backup
/// reminder (BAK-7), and app lock (LOCK-1).
class SettingsProvider extends ChangeNotifier {
  /// Reads saved settings from [_prefs]. Without a saved currency, the
  /// currency of [deviceLocale] (such as `en_GB`) is preselected. [clock]
  /// supplies "now"; tests pass a fixed time.
  SettingsProvider(
    this._prefs, {
    String? deviceLocale,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       _languageCode = _validLanguage(_prefs.getString(_languageKey)),
       _currencyCode =
           _prefs.getString(_currencyKey) ?? defaultCurrencyFor(deviceLocale),
       _themeMode = _themeModeNamed(_prefs.getString(_themeKey)),
       _startDay = _validStartDay(_prefs.getInt(_startDayKey)),
       _showCarriedForward = _prefs.getBool(_carriedForwardKey) ?? true,
       _summaryCollapsed = _prefs.getBool(_summaryCollapsedKey) ?? false,
       _accountFilterId = _prefs.getString(_accountFilterKey),
       _weekStartDay = _validWeekDay(_prefs.getInt(_weekStartKey)),
       _backupReminder = _prefs.getBool(_backupReminderKey) ?? true,
       _lastBackupAt = _dateOrNull(_prefs.getString(_lastBackupKey)),
       _reminderSnoozedAt = _dateOrNull(_prefs.getString(_snoozedKey)),
       _emptyDayNudge = _prefs.getBool(_nudgeOnKey) ?? false,
       _nudgeHour = _awakeHour(_prefs.getInt(_nudgeHourKey)),
       _nudgeMinute = _prefs.getInt(_nudgeMinuteKey) ?? 0,
       _nudgeOffered = _prefs.getBool(_nudgeOfferedKey) ?? false,
       _nudgeIgnored = _prefs.getInt(_nudgeIgnoredKey) ?? 0,
       _nudgeStopped = _prefs.getBool(_nudgeStoppedKey) ?? false,
       _nudgeCheckedAt = _dateOrNull(_prefs.getString(_nudgeCheckedKey)),
       _lastInterstitialAt = _dateOrNull(
         _prefs.getString(_lastInterstitialKey),
       ),
       _appLock = _prefs.getBool(_appLockKey) ?? false,
       _showWidgetAmounts = _prefs.getBool(_showWidgetAmountsKey) ?? false {
    final firstOpened = _dateOrNull(_prefs.getString(_firstOpenedKey));
    _firstOpenedAt = firstOpened ?? _clock();
    if (firstOpened == null) {
      unawaited(_prefs.setString(_firstOpenedKey, _stamp(_firstOpenedAt)));
    }
    // RUN-5: only a first-ever launch has neither `first_opened_at` nor these
    // two, so an update onto a device that has used the app before shows
    // neither the setup page nor the walkthrough, and keeps its settings.
    final usedBefore = firstOpened != null;
    _setupDone = _prefs.getBool(_setupDoneKey) ?? usedBefore;
    _walkthroughSeen = _prefs.getBool(_walkthroughSeenKey) ?? usedBefore;
    // Saved as they stand, so a first launch closed halfway through setup
    // opens it again next time instead of looking like an update (RUN-5).
    if (!_prefs.containsKey(_setupDoneKey)) {
      unawaited(_prefs.setBool(_setupDoneKey, _setupDone));
    }
    if (!_prefs.containsKey(_walkthroughSeenKey)) {
      unawaited(_prefs.setBool(_walkthroughSeenKey, _walkthroughSeen));
    }
  }

  static const _languageKey = 'language';
  static const _currencyKey = 'currency_code';
  static const _themeKey = 'theme_mode';
  static const _startDayKey = 'month_start_day';
  static const _carriedForwardKey = 'show_carried_forward';
  static const _summaryCollapsedKey = 'summary_collapsed';
  static const _accountFilterKey = 'account_filter_id';
  static const _weekStartKey = 'week_start_day';
  static const _backupReminderKey = 'backup_reminder';
  static const _nudgeOnKey = 'empty_day_nudge';
  static const _nudgeHourKey = 'empty_day_nudge_hour';
  static const _nudgeMinuteKey = 'empty_day_nudge_minute';
  static const _nudgeOfferedKey = 'empty_day_nudge_offered';
  static const _nudgeIgnoredKey = 'empty_day_nudge_ignored';
  static const _nudgeStoppedKey = 'empty_day_nudge_stopped';
  static const _nudgeCheckedKey = 'empty_day_nudge_checked';
  static const _lastInterstitialKey = 'last_interstitial';
  static const _lastBackupKey = 'last_backup_at';
  static const _snoozedKey = 'backup_reminder_snoozed_at';
  static const _firstOpenedKey = 'first_opened_at';
  static const _appLockKey = 'app_lock';
  static const _showWidgetAmountsKey = 'show_widget_amounts';
  static const _setupDoneKey = 'setup_done';
  static const _walkthroughSeenKey = 'walkthrough_seen';

  /// Transactions needed before the first backup reminder (BAK-7).
  static const backupReminderThreshold = 20;

  /// The shortest gap between backup reminders (BAK-7).
  static const backupReminderInterval = Duration(days: 30);

  /// How many separate days a person has to have recorded on before the
  /// empty-day nudge is offered at all (NUDGE-3).
  static const nudgeOfferThreshold = 3;

  /// How many go unanswered in a row before it stops itself (NUDGE-5).
  static const nudgeGiveUpAfter = 3;

  /// When it fires until the user says otherwise (NUDGE-4).
  static const nudgeDefaultHour = 21;

  /// How many transactions the app wants behind it before a full-screen ad
  /// may appear (ADS-12).
  static const interstitialThreshold = 10;

  final SharedPreferences _prefs;
  final DateTime Function() _clock;
  String? _languageCode;
  String _currencyCode;
  ThemeMode _themeMode;
  int _startDay;
  bool _showCarriedForward;
  bool _summaryCollapsed;
  String? _accountFilterId;
  int? _weekStartDay;
  bool _backupReminder;
  DateTime? _lastBackupAt;
  DateTime? _reminderSnoozedAt;
  bool _emptyDayNudge;
  int _nudgeHour;
  int _nudgeMinute;
  bool _nudgeOffered;
  int _nudgeIgnored;
  bool _nudgeStopped;
  DateTime? _nudgeCheckedAt;
  DateTime? _lastInterstitialAt;
  late final DateTime _firstOpenedAt;
  bool _appLock;
  bool _showWidgetAmounts;
  late bool _setupDone;
  late bool _walkthroughSeen;

  /// The chosen language code, or null to follow the device (LANG-1).
  String? get languageCode => _languageCode;

  /// The locale the app shows, or null to follow the device.
  Locale? get locale => switch (_languageCode) {
    final code? => Locale(code),
    null => null,
  };

  String get currencyCode => _currencyCode;
  ThemeMode get themeMode => _themeMode;

  /// 1–28, or [Period.lastDayOfMonth].
  int get startDay => _startDay;

  /// Whether Home shows the closing balance, carried forward from earlier
  /// periods, instead of only this period's net. On by default.
  bool get showCarriedForward => _showCarriedForward;

  /// Whether Home's summary card is the balance alone (BAL-6). It is how
  /// this device is set up to look, so a backup doesn't carry it.
  bool get summaryCollapsed => _summaryCollapsed;

  Future<void> setSummaryCollapsed(bool collapsed) async {
    if (collapsed == _summaryCollapsed) return;
    await _prefs.setBool(_summaryCollapsedKey, collapsed);
    _summaryCollapsed = collapsed;
    notifyListeners();
  }

  /// The account Home is showing, or null for every account (ACC-6). Like
  /// [summaryCollapsed] it is how this device is set up to look rather than a
  /// record of anything, so a backup doesn't carry it.
  String? get accountFilterId => _accountFilterId;

  Future<void> setAccountFilterId(String? id) async {
    if (id == _accountFilterId) return;
    if (id == null) {
      await _prefs.remove(_accountFilterKey);
    } else {
      await _prefs.setString(_accountFilterKey, id);
    }
    _accountFilterId = id;
    notifyListeners();
  }

  /// The first day of the week, from 0 (Sunday) to 6 (Saturday), or null to
  /// follow the device locale (PER-4).
  int? get weekStartDay => _weekStartDay;

  /// Whether Home reminds the user to back up (BAK-7). On by default.
  bool get backupReminder => _backupReminder;

  /// When the user last saved a backup file.
  DateTime? get lastBackupAt => _lastBackupAt;

  /// Whether the app asks for the device's biometrics or screen lock
  /// (LOCK-1). Off by default.
  bool get appLock => _appLock;

  /// Whether the home-screen widget still shows amounts while app lock is on
  /// (WID-4). Off by default, so turning app lock on takes them off the home
  /// screen too.
  bool get showWidgetAmounts => _showWidgetAmounts;

  /// Whether the setup page is behind us (RUN-3). It shows until it is
  /// finished, so an app closed halfway through opens it again (RUN-5).
  bool get setupDone => _setupDone;

  /// Whether the walkthrough has run, seen through or skipped (RUN-4). It
  /// shows once; Settings replays it without changing this (RUN-5).
  bool get walkthroughSeen => _walkthroughSeen;

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
  ///
  /// In Arabic and Urdu each amount is one left-to-right piece, sign and
  /// symbol included, so it reads the same inside right-to-left text as on
  /// its own (LANG-5). [isolated] false leaves that out, for the PDF report,
  /// which lays out its own text.
  NumberFormat currencyFormat(String locale, {bool isolated = true}) {
    final simple = NumberFormat.simpleCurrency(
      locale: locale,
      name: _currencyCode,
    );
    final symbol = _localSymbol(locale);
    final rtl = isolated && rightToLeftLanguages.contains(_language(locale));
    if (symbol == null && !rtl) return simple;
    return NumberFormat.currency(
      locale: locale,
      name: _currencyCode,
      symbol: symbol ?? simple.currencySymbol,
      decimalDigits: simple.decimalDigits,
      customPattern: rtl ? _leftToRightPattern(locale) : null,
    );
  }

  /// Short amounts like `$1.2K`, for small spaces such as calendar days.
  NumberFormat compactCurrencyFormat(String locale) {
    final symbol = _localSymbol(locale);
    return symbol == null
        ? NumberFormat.compactSimpleCurrency(
            locale: locale,
            name: _currencyCode,
          )
        : NumberFormat.compactCurrency(
            locale: locale,
            name: _currencyCode,
            symbol: symbol,
          );
  }

  static String _language(String locale) => locale.split(RegExp('[-_]')).first;

  /// The currency's symbol as [locale]'s language writes it, where intl's
  /// short one is in another script.
  String? _localSymbol(String locale) =>
      _language(locale) == 'ar' ? arabicCurrencySymbols[_currencyCode] : null;

  /// [locale]'s currency pattern with each half, positive and negative,
  /// isolated as left to right (U+2066 … U+2069). The marks intl puts in for
  /// right-to-left text would reorder the amount around its sign and symbol.
  static String _leftToRightPattern(String locale) {
    final symbols =
        numberFormatSymbols[Intl.verifiedLocale(
          locale,
          NumberFormat.localeExists,
        )]!;
    final halves = symbols.CURRENCY_PATTERN
        .replaceAll(RegExp('[\u200E\u200F]'), '')
        .split(';');
    final positive = halves.first;
    final negative = halves.length > 1 ? halves[1] : '-$positive';
    return '\u2066$positive\u2069;\u2066$negative\u2069';
  }

  /// Changes the currency label only; stored amounts never change (CUR-3).
  Future<void> setCurrencyCode(String code) async {
    if (code == _currencyCode) return;
    await _prefs.setString(_currencyKey, code);
    _currencyCode = code;
    notifyListeners();
  }

  /// Shows the app in [code], or follows the device again with null. The
  /// app switches at once (LANG-1).
  Future<void> setLanguageCode(String? code) async {
    assert(
      code == null || appLanguages.containsKey(code),
      'Unknown language: $code',
    );
    if (code == _languageCode) return;
    if (code == null) {
      await _prefs.remove(_languageKey);
    } else {
      await _prefs.setString(_languageKey, code);
    }
    _languageCode = code;
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

  Future<void> setShowCarriedForward(bool show) async {
    if (show == _showCarriedForward) return;
    await _prefs.setBool(_carriedForwardKey, show);
    _showCarriedForward = show;
    notifyListeners();
  }

  /// Sets the first day of the week, or follows the locale again with null.
  Future<void> setWeekStartDay(int? day) async {
    assert(day == null || _validWeekDay(day) == day, 'Invalid week day: $day');
    if (day == _weekStartDay) return;
    if (day == null) {
      await _prefs.remove(_weekStartKey);
    } else {
      await _prefs.setInt(_weekStartKey, day);
    }
    _weekStartDay = day;
    notifyListeners();
  }

  Future<void> setBackupReminder(bool on) async {
    if (on == _backupReminder) return;
    await _prefs.setBool(_backupReminderKey, on);
    _backupReminder = on;
    notifyListeners();
  }

  /// Records that the user just saved a backup file.
  Future<void> recordBackup() async {
    final now = _clock();
    await _prefs.setString(_lastBackupKey, _stamp(now));
    _lastBackupAt = now;
    notifyListeners();
  }

  /// Hides the backup reminder for [backupReminderInterval].
  Future<void> snoozeBackupReminder() async {
    final now = _clock();
    await _prefs.setString(_snoozedKey, _stamp(now));
    _reminderSnoozedAt = now;
    notifyListeners();
  }

  /// Whether Home should remind the user to back up (BAK-7): only with at
  /// least [backupReminderThreshold] transactions, never within a day of
  /// first opening the app, and at most every [backupReminderInterval] since
  /// the last backup or dismissal.
  bool backupReminderDue(int transactionCount) {
    final now = _clock();
    if (!_backupReminder ||
        transactionCount < backupReminderThreshold ||
        now.difference(_firstOpenedAt) < const Duration(days: 1)) {
      return false;
    }
    final last = switch ((_lastBackupAt, _reminderSnoozedAt)) {
      (final backup?, final snoozed?) =>
        backup.isAfter(snoozed) ? backup : snoozed,
      (final backup, final snoozed) => backup ?? snoozed,
    };
    return last == null || now.difference(last) >= backupReminderInterval;
  }

  // The empty-day nudge (NUDGE-3 to NUDGE-5).

  /// Whether the app may say a day ended with nothing in it.
  bool get emptyDayNudge => _emptyDayNudge;

  int get nudgeHour => _nudgeHour;

  int get nudgeMinute => _nudgeMinute;

  /// What the empty-day nudge is set to, for the provider that schedules it
  /// (NUDGE-4).
  NudgeSettings get nudgeSettings =>
      NudgeSettings(on: _emptyDayNudge, hour: _nudgeHour, minute: _nudgeMinute);

  /// Whether it has already been offered once, however that went (NUDGE-3).
  bool get nudgeOffered => _nudgeOffered;

  /// Whether the offer is still to come, before counting anything (NUDGE-3).
  bool get nudgeOfferPending => !_nudgeOffered && !_emptyDayNudge;

  /// How many have gone unanswered in a row (NUDGE-5).
  int get nudgeIgnored => _nudgeIgnored;

  /// Whether it turned itself off, so Settings can say why (NUDGE-5).
  bool get nudgeStopped => _nudgeStopped;

  /// When the unanswered ones were last counted, so the same day is never
  /// counted twice.
  DateTime? get nudgeCheckedAt => _nudgeCheckedAt;

  /// Whether Home should offer it (NUDGE-3): once only, and only to someone
  /// who has recorded on [nudgeOfferThreshold] separate days, so it reaches
  /// a person who has shown they want the habit.
  bool nudgeOfferDue(int daysRecordedOn) =>
      !_nudgeOffered &&
      !_emptyDayNudge &&
      daysRecordedOn >= nudgeOfferThreshold;

  /// Turns it on or off. Turning it on is also an answer to a nudge that had
  /// given up, so the count starts again (NUDGE-5).
  Future<void> setEmptyDayNudge(bool on) async {
    if (on == _emptyDayNudge) return;
    _emptyDayNudge = on;
    await _prefs.setBool(_nudgeOnKey, on);
    if (on) {
      _nudgeIgnored = 0;
      _nudgeStopped = false;
      await _prefs.setInt(_nudgeIgnoredKey, 0);
      await _prefs.setBool(_nudgeStoppedKey, false);
    }
    notifyListeners();
  }

  /// The time of day it fires, kept inside the hours the app may speak in
  /// (NUDGE-6), so a stored setting can never put one at three in the
  /// morning.
  Future<void> setNudgeTime(int hour, int minute) async {
    final kept = _awakeHour(hour);
    if (kept == _nudgeHour && minute == _nudgeMinute) return;
    _nudgeHour = kept;
    _nudgeMinute = minute;
    await _prefs.setInt(_nudgeHourKey, kept);
    await _prefs.setInt(_nudgeMinuteKey, minute);
    notifyListeners();
  }

  /// Remembers that the offer was made, whatever the answer (NUDGE-3).
  Future<void> markNudgeOffered() async {
    if (_nudgeOffered) return;
    _nudgeOffered = true;
    await _prefs.setBool(_nudgeOfferedKey, true);
    notifyListeners();
  }

  /// Records what [countIgnoredNudges] found, and stops the nudge once
  /// [nudgeGiveUpAfter] have gone unanswered in a row (NUDGE-5).
  Future<void> recordNudgesIgnored(int ignored, DateTime checkedAt) async {
    _nudgeIgnored = ignored;
    _nudgeCheckedAt = checkedAt;
    await _prefs.setInt(_nudgeIgnoredKey, ignored);
    await _prefs.setString(_nudgeCheckedKey, _stamp(checkedAt));
    if (ignored >= nudgeGiveUpAfter && _emptyDayNudge) {
      _emptyDayNudge = false;
      _nudgeStopped = true;
      await _prefs.setBool(_nudgeOnKey, false);
      await _prefs.setBool(_nudgeStoppedKey, true);
    }
    notifyListeners();
  }

  /// A tap, or an entry on the day of one, is an answer (NUDGE-5).
  Future<void> answerNudge() async {
    if (_nudgeIgnored == 0) return;
    _nudgeIgnored = 0;
    await _prefs.setInt(_nudgeIgnoredKey, 0);
    notifyListeners();
  }

  /// Keeps an hour inside the waking ones (NUDGE-6).
  static int _awakeHour(int? hour) {
    if (hour == null || hour < quietUntilHour || hour >= quietFromHour) {
      return nudgeDefaultHour;
    }
    return hour;
  }

  /// Whether a seam may show a full-screen ad now (ADS-12): at most one in
  /// a day, counted by the device's own day, and none before
  /// [interstitialThreshold] transactions have been recorded.
  bool interstitialDue(int transactionCount) {
    final now = _clock();
    if (transactionCount < interstitialThreshold) {
      return false;
    }
    // The device's own day, not the UTC one it was stored as.
    final last = _lastInterstitialAt?.toLocal();
    return last == null ||
        last.year != now.year ||
        last.month != now.month ||
        last.day != now.day;
  }

  /// Counts the day's one showing. Called when an ad has really been on
  /// screen, never when one was merely asked for (ADS-13).
  Future<void> markInterstitialShown() async {
    final now = _clock();
    await _prefs.setString(_lastInterstitialKey, _stamp(now));
    _lastInterstitialAt = now;
  }

  Future<void> setAppLock(bool on) async {
    if (on == _appLock) return;
    await _prefs.setBool(_appLockKey, on);
    _appLock = on;
    notifyListeners();
  }

  Future<void> setShowWidgetAmounts(bool show) async {
    if (show == _showWidgetAmounts) return;
    await _prefs.setBool(_showWidgetAmountsKey, show);
    _showWidgetAmounts = show;
    notifyListeners();
  }

  /// Records that setup is finished (RUN-3, RUN-5).
  Future<void> completeSetup() async {
    if (_setupDone) return;
    await _prefs.setBool(_setupDoneKey, true);
    _setupDone = true;
    notifyListeners();
  }

  /// Records that the walkthrough has had its turn, whether it was read or
  /// skipped (RUN-4, RUN-5).
  Future<void> completeWalkthrough() async {
    if (_walkthroughSeen) return;
    await _prefs.setBool(_walkthroughSeenKey, true);
    _walkthroughSeen = true;
    notifyListeners();
  }

  /// Settings that travel with a backup (BAK-1). App lock, the widget, and
  /// the backup reminder belong to the device, so they stay out.
  Map<String, Object?> get backupValues => {
    _languageKey: _languageCode,
    _currencyKey: _currencyCode,
    _themeKey: _themeMode.name,
    _startDayKey: _startDay,
    _carriedForwardKey: _showCarriedForward,
    _weekStartKey: _weekStartDay,
  };

  /// Applies settings from a backup. Missing or invalid values are ignored.
  Future<void> restoreBackupValues(Map<String, Object?> values) async {
    if (values.containsKey(_languageKey)) {
      final language = values[_languageKey];
      if (language == null ||
          (language is String && _validLanguage(language) == language)) {
        await setLanguageCode(language as String?);
      }
    }
    final currency = values[_currencyKey];
    if (currency is String && RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      await setCurrencyCode(currency);
    }
    final theme = values[_themeKey];
    if (theme is String) await setThemeMode(_themeModeNamed(theme));
    final startDay = values[_startDayKey];
    if (startDay is int && _validStartDay(startDay) == startDay) {
      await setStartDay(startDay);
    }
    final carry = values[_carriedForwardKey];
    if (carry is bool) await setShowCarriedForward(carry);
    if (values.containsKey(_weekStartKey)) {
      final week = values[_weekStartKey];
      if (week == null || (week is int && _validWeekDay(week) == week)) {
        await setWeekStartDay(week as int?);
      }
    }
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

  static String? _validLanguage(String? code) =>
      appLanguages.containsKey(code) ? code : null;

  static int? _validWeekDay(int? day) =>
      day != null && day >= 0 && day <= 6 ? day : null;

  static DateTime? _dateOrNull(String? value) =>
      value == null ? null : DateTime.tryParse(value);

  static String _stamp(DateTime moment) => moment.toUtc().toIso8601String();
}
