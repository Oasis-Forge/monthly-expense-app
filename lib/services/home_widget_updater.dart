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
/// widget. Notifications are coalesced, since one save can raise several.
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

  bool _pending = false;
  bool _started = false;

  /// Starts watching, and pushes what the widget should show right now.
  void start() {
    if (_started) return;
    _started = true;
    _transactions.addListener(_schedule);
    _settings.addListener(_schedule);
    // A day can turn over while the app sits in the background, and the
    // period along with it.
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  void dispose() {
    if (!_started) return;
    _started = false;
    _transactions.removeListener(_schedule);
    _settings.removeListener(_schedule);
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _schedule();
  }

  void _schedule() {
    if (_pending) return;
    _pending = true;
    scheduleMicrotask(() {
      _pending = false;
      if (_started) unawaited(refresh());
    });
  }

  /// Builds the payload and hands it over. Public so a test can await it.
  Future<void> refresh() async {
    if (!_transactions.isLoaded) return;
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
  }
}
