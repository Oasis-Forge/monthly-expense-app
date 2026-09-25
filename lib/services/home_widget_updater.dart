import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../l10n/app_localizations.dart';
import '../l10n/languages.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'home_widget_payload.dart';
import 'home_widget_service.dart';

/// Keeps the home-screen widget in step with the app (WID-5).
///
/// It watches both providers, so anything that changes the numbers — a
/// transaction, a budget, the currency, the language, app lock — reaches the
/// widget. Notifications are debounced (lifecycle-perf#9): a burst of them,
/// whether several raised by one save or several period-arrow taps in a
/// row, settles into at most one [refresh] a short while after the last one.
///
/// It isn't a widget in the tree: the payload needs no `BuildContext`, and
/// keeping it out means an update still happens while a dialog or a lock
/// screen is covering the app.
class HomeWidgetUpdater with WidgetsBindingObserver {
  HomeWidgetUpdater({
    required this._service,
    required this._transactions,
    required this._settings,
    Future<AppLocalizations> Function(Locale)? loadLocalizations,
  }) : _load = loadLocalizations ?? AppLocalizations.delegate.load;

  final HomeWidgetService _service;
  final TransactionProvider _transactions;
  final SettingsProvider _settings;
  final Future<AppLocalizations> Function(Locale) _load;

  Timer? _debounce;
  bool _started = false;

  /// How long a burst of notifications is given to settle before
  /// [refresh] runs, restarted on every one that lands inside it — so six
  /// period-arrow taps in the same second coalesce into one push instead of
  /// each queuing its own (lifecycle-perf#9).
  static const _debounceDelay = Duration(milliseconds: 250);

  /// The [_transactions] data version [refresh] last pushed for, and
  /// whether something on [_settings] has changed since then. Selecting or
  /// clearing a day inside the same period notifies like anything else, but
  /// changes nothing the widget shows — [_transactions.dataVersion] only
  /// moves on an actual data change, so that alone tells refresh apart from
  /// the work worth redoing (WID-5, lifecycle-perf#9).
  int? _lastDataVersion;
  bool _settingsChanged = true;

  /// Set on every app resume, so the next [refresh] pushes once regardless
  /// of [_lastDataVersion] or [_settingsChanged]. The phone's own language
  /// (and so the widget text, via [effectiveAppLocale]) can change while the
  /// app sits in the background, and a resume is the only signal that tells
  /// us to check again — [_settings] itself hasn't changed (WID-5).
  bool _forceRefresh = false;

  /// Starts watching, and pushes what the widget should show right now.
  void start() {
    if (_started) return;
    _started = true;
    _transactions.addListener(_schedule);
    _settings.addListener(_scheduleFromSettings);
    // A day can turn over while the app sits in the background, and the
    // period along with it.
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  void dispose() {
    if (!_started) return;
    _started = false;
    _debounce?.cancel();
    _debounce = null;
    _transactions.removeListener(_schedule);
    _settings.removeListener(_scheduleFromSettings);
    WidgetsBinding.instance.removeObserver(this);
  }

  void _scheduleFromSettings() {
    _settingsChanged = true;
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _forceRefresh = true;
      _schedule();
    }
  }

  /// Split-screen on API 29+ can change the phone's language while this
  /// app stays resumed the whole time (WID-5): the other app in the split
  /// gets the lifecycle transition, this one just gets told its locales
  /// changed, so [didChangeAppLifecycleState] alone would miss it.
  @override
  void didChangeLocales(List<Locale>? locales) {
    _forceRefresh = true;
    _schedule();
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () {
      _debounce = null;
      if (_started) unawaited(refresh());
    });
  }

  /// Builds the payload and hands it over. Public so a test can await it.
  ///
  /// Skips the work on a platform with no widget (WID-1), and again when
  /// nothing the widget shows has changed since the last push — a day tap
  /// or a period change notifies like a save does, but only a save moves
  /// [TransactionProvider.dataVersion] (lifecycle-perf#9).
  Future<void> refresh() async {
    if (!_transactions.isLoaded || !_service.isSupported) return;
    final dataVersion = _transactions.dataVersion;
    final forced = _forceRefresh;
    if (!forced && dataVersion == _lastDataVersion && !_settingsChanged) {
      return;
    }
    _forceRefresh = false;

    final locale = effectiveAppLocale(_settings.locale);
    final l10n = await _load(locale);
    // The period's name is formatted here rather than on a screen, so the
    // date symbols the Material delegate would have loaded aren't in place.
    await initializeDateFormatting(l10n.localeName);
    // With app lock on the widget shows nothing until the user says
    // otherwise (WID-4).
    final hide = _settings.appLock && !_settings.showWidgetAmounts;
    await _service.update(
      buildHomeWidgetPayload(
        timeline: hide
            ? const []
            : _transactions.widgetTimeline(
                carryForward: _settings.showCarriedForward,
              ),
        l10n: l10n,
        currency: _settings.currencyFormat(l10n.localeName),
        hideAmounts: hide,
      ),
    );
    _lastDataVersion = dataVersion;
    _settingsChanged = false;
  }
}
