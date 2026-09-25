import 'dart:async' show unawaited;

import 'package:flutter/material.dart' show ChangeNotifier, Locale, ThemeMode;

import '../models/app_theme.dart';

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
       _theme = AppTheme.named(_prefs.getString(_themeKey)),
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
       _adActivity = _prefs.getInt(_adActivityKey) ?? 0,
       _adActivityDay = _dateOrNull(_prefs.getString(_adActivityDayKey)),
       _appLock = _prefs.getBool(_appLockKey) ?? false,
       _showWidgetAmounts = _prefs.getBool(_showWidgetAmountsKey) ?? false {
    final firstOpened = _dateOrNull(_prefs.getString(_firstOpenedKey));
    _firstOpenedAt = firstOpened ?? _clock();
    // ADS-12: whatever someone does on the run that installs the app,
    // they are not interrupted during it.
    _firstSession = firstOpened == null;
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
  static const _ratingAskedKey = 'rating_asked_version';
  static const _updateAskedKey = 'update_asked_on';
  static const _nudgeIgnoredKey = 'empty_day_nudge_ignored';
  static const _nudgeStoppedKey = 'empty_day_nudge_stopped';
  static const _nudgeCheckedKey = 'empty_day_nudge_checked';
  static const _adActivityKey = 'ad_activity';
  static const _adActivityDayKey = 'ad_activity_day';
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

  /// How many things done in a day earn a full-screen ad (ADS-12): an entry
  /// saved, or a screen opened.
  static const adActivityThreshold = 10;

  final SharedPreferences _prefs;
  final DateTime Function() _clock;
  String? _languageCode;
  String _currencyCode;
  AppTheme _theme;
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
  int _adActivity;
  DateTime? _adActivityDay;

  /// Whether this run is the one that installed the app: the only
  /// launch with no `first_opened_at` behind it (ADS-12, RUN-5).
  late final bool _firstSession;
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

  /// The choice the Theme row offers (THEME-1).
  AppTheme get appTheme => _theme;

  /// The brightness that choice asks for; black asks for dark.
  ThemeMode get themeMode => _theme.themeMode;

  /// Whether dark surfaces are true black (THEME-1).
  bool get blackBackground => _theme.isBlack;

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
  /// The figures, and the sign in front of them, are isolated left to right
  /// so bidi cannot part them; the symbol is left where the language puts it,
  /// which in Arabic is before the figures (LANG-5). [isolated] false leaves
  /// the isolate out, for the PDF report, which lays out its own text.
  NumberFormat currencyFormat(String locale, {bool isolated = true}) {
    final simple = NumberFormat.simpleCurrency(
      locale: locale,
      name: _currencyCode,
    );
    final symbol = _localSymbol(locale) ?? simple.currencySymbol;
    final pattern = _amountPattern(locale, symbol, isolated: isolated);
    if (_localSymbol(locale) == null && pattern == null) return simple;
    return NumberFormat.currency(
      locale: locale,
      name: _currencyCode,
      symbol: symbol,
      decimalDigits: simple.decimalDigits,
      customPattern: pattern,
    );
  }

  /// Short amounts like `$1.2K`, for small spaces such as calendar days. It
  /// takes a symbol rather than a pattern, so CLDR's spacing goes on the
  /// symbol itself; without it the calendar would read `Rp1,2 rb` beside a
  /// total of `Rp 1.235` on the same screen (LANG-5).
  NumberFormat compactCurrencyFormat(String locale) {
    final plain =
        _localSymbol(locale) ??
        NumberFormat.simpleCurrency(
          locale: locale,
          name: _currencyCode,
        ).currencySymbol;
    return NumberFormat.compactCurrency(
      locale: locale,
      name: _currencyCode,
      symbol: _spacedSymbol(locale, plain),
    );
  }

  static String _language(String locale) => locale.split(RegExp('[-_]')).first;

  /// The currency's symbol as [locale]'s language writes it, where intl's
  /// short one is in another script.
  String? _localSymbol(String locale) =>
      _language(locale) == 'ar' ? arabicCurrencySymbols[_currencyCode] : null;

  /// The figures of a currency pattern, with the sign that belongs to them.
  static final RegExp _figures = RegExp('[-+]?[#0][#0.,]*');

  /// CLDR asks for a no-break space between the digits and the symbol only
  /// where the character that touches them is not itself a sign
  /// (`currencySpacing`, `currencyMatch: [[:^S:]&[:^Z:]]`). So `Rs` and `Rp`
  /// take one and `$`, `€` and `R$` do not — it is the touching character
  /// that decides, not whether the symbol has a letter in it anywhere.
  static final RegExp _sign = RegExp(r'[\p{S}\p{Z}]', unicode: true);

  /// Whether [symbol] needs that space, given that it stands in front of the
  /// figures ([leading]) or after them.
  static bool _needsSpacing(String symbol, {required bool leading}) {
    if (symbol.isEmpty) return false;
    final touching = String.fromCharCode(
      leading ? symbol.runes.last : symbol.runes.first,
    );
    return !_sign.hasMatch(touching);
  }

  /// Whether [locale] writes the symbol in front of the figures.
  static bool _symbolLeads(String pattern) {
    final symbol = pattern.indexOf('\u00A4');
    final figure = pattern.indexOf(RegExp('[#0]'));
    return symbol >= 0 && figure >= 0 && symbol < figure;
  }

  static String _cldrPattern(String locale) =>
      numberFormatSymbols[Intl.verifiedLocale(
            locale,
            NumberFormat.localeExists,
          )]!
          .CURRENCY_PATTERN;

  /// [symbol] carrying CLDR's spacing itself, for the compact format, which
  /// takes a symbol where the others take a pattern.
  static String _spacedSymbol(String locale, String symbol) {
    final leading = _symbolLeads(_cldrPattern(locale));
    if (!_needsSpacing(symbol, leading: leading)) return symbol;
    return leading ? '$symbol\u00A0' : '\u00A0$symbol';
  }

  /// [locale]'s currency pattern, mended in the two places intl leaves to
  /// us, or null where it needs neither.
  ///
  /// The figures and their sign are isolated left to right (U+2066 … U+2069)
  /// so that bidi cannot part them, but the symbol is left outside, where the
  /// language puts it: CLDR writes Arabic as figures first, symbol after, and
  /// in right-to-left text that reads with the symbol on the left (LANG-5).
  static String? _amountPattern(
    String locale,
    String symbol, {
    required bool isolated,
  }) {
    final cldr = _cldrPattern(locale);
    // A pattern we cannot read is left exactly as it is rather than guessed at.
    if (!cldr.contains('\u00A4') || !cldr.contains(RegExp('[#0]'))) {
      return null;
    }
    final leads = _symbolLeads(cldr);
    final spaced = _needsSpacing(symbol, leading: leads)
        ? (leads
              ? cldr.replaceAll(RegExp('\u00A4(?=[#0])'), '\u00A4\u00A0')
              : cldr.replaceAll(RegExp('(?<=[#0])\u00A4'), '\u00A0\u00A4'))
        : cldr;
    final isolate =
        isolated && rightToLeftLanguages.contains(_language(locale));
    if (!isolate) return spaced == cldr ? null : spaced;
    final halves = spaced.split(';');
    // Where the symbol already stands in front of the figures, the whole
    // amount is one left-to-right piece and the symbol falls on the left of
    // its own accord. Where it follows them, as Arabic writes it, only the
    // figures are isolated, so right-to-left order can carry the symbol over
    // to the left where it belongs (LANG-5).
    final negative = halves.length > 1
        ? halves[1]
        : leads
        ? '-${halves.first}'
        : halves.first.replaceFirstMapped(_figures, (m) => '-${m[0]}');
    return [halves.first, negative]
        .map(
          (h) => leads
              ? '\u2066$h\u2069'
              : h.replaceFirstMapped(_figures, (m) => '\u2066${m[0]}\u2069'),
        )
        .join(';');
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

  Future<void> setTheme(AppTheme theme) async {
    if (theme == _theme) return;
    await _prefs.setString(_themeKey, theme.name);
    _theme = theme;
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

  /// When the app was first opened on this device, which is the week in
  /// RATE-1 and the first session in ADS-12.
  DateTime get firstOpenedAt => _firstOpenedAt;

  /// The version this device was last asked to rate, or null for never
  /// (RATE-4).
  String? get ratingAskedVersion => _prefs.getString(_ratingAskedKey);

  /// Remembers that [version] has now asked. Written before the sheet is
  /// requested, because the store never says what became of it (RATE-4).
  Future<void> markRatingAsked(String version) async {
    await _prefs.setString(_ratingAskedKey, version);
  }

  /// The day this device was last offered an update, or null for never
  /// (UPD-4).
  DateTime? get updateAskedOn => _dateOrNull(_prefs.getString(_updateAskedKey));

  /// Remembers that [day] has now offered one. Written before Play is
  /// given the chance to say no, because it never says what became of it
  /// (UPD-4).
  Future<void> markUpdateAsked(DateTime day) async {
    await _prefs.setString(_updateAskedKey, _stamp(day));
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

  /// Whether a seam may show a full-screen ad now (ADS-12): ten things done
  /// today, and not during the run that installed the app.
  bool get adActivityEarned =>
      !_firstSession && _activityToday >= adActivityThreshold;

  /// How many things have been done today, for a test to read.
  int get adActivity => _activityToday;

  int get _activityToday {
    final day = _adActivityDay;
    if (day == null) return 0;
    final now = _clock();
    final same =
        day.toLocal().year == now.year &&
        day.toLocal().month == now.month &&
        day.toLocal().day == now.day;
    return same ? _adActivity : 0;
  }

  /// Counts one thing done — an entry saved, or a screen opened (ADS-12).
  /// A count from another day starts again at one rather than adding to it.
  Future<void> noteAdActivity() async {
    final now = _clock();
    _adActivity = _activityToday + 1;
    _adActivityDay = now;
    await _prefs.setInt(_adActivityKey, _adActivity);
    await _prefs.setString(_adActivityDayKey, _stamp(now));
  }

  /// Starts the count again, because an ad has just been on screen. Called
  /// when one was really seen, never when one was merely asked for (ADS-13).
  Future<void> spendAdActivity() async {
    _adActivity = 0;
    _adActivityDay = _clock();
    await _prefs.setInt(_adActivityKey, 0);
    await _prefs.setString(_adActivityDayKey, _stamp(_adActivityDay!));
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

  /// Records that setup is finished (RUN-3, RUN-5). Also stores the
  /// currency in effect, which until now was only ever preselected from the
  /// device locale (CUR-1): without this, a user who taps Continue without
  /// opening the currency picker never gets a stored choice, and it keeps
  /// silently re-deriving from the device locale on every later launch
  /// (CUR-3).
  Future<void> completeSetup() async {
    if (_setupDone) return;
    await _prefs.setString(_currencyKey, _currencyCode);
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
    _themeKey: _theme.name,
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
    if (theme is String) await setTheme(AppTheme.named(theme));
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
