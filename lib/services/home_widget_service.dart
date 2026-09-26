import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// What a tap on the home-screen widget asked for, or null when there's
/// nothing pending. A top-level listener acts on it through the lock
/// (WID-3, LOCK-2).
final ValueNotifier<HomeWidgetAction?> tappedWidgetAction = ValueNotifier(null);

/// The ways into the app from the widget (WID-3).
enum HomeWidgetAction {
  /// The Add expense button.
  addExpense('add_expense'),

  /// The Add income button, on the medium widget only.
  addIncome('add_income'),

  /// The numbers themselves: Home, on the current period.
  openHome('open_home');

  const HomeWidgetAction(this.id);

  /// What the native side sends.
  final String id;

  static HomeWidgetAction? parse(String? id) {
    for (final action in values) {
      if (action.id == id) return action;
    }
    return null;
  }
}

/// Hands the home-screen widget the numbers it shows (WID-5). Tests use a
/// fake instead of touching the platform.
abstract class HomeWidgetService {
  /// Whether this platform has a home-screen widget at all (WID-1). A
  /// caller building the payload can check this first, so it doesn't do
  /// that work only for [update] to throw it away (lifecycle-perf#9).
  bool get isSupported => true;

  /// Replaces what every widget shows with [payload] and redraws them.
  Future<void> update(Map<String, Object?> payload);

  /// Starts reporting widget taps through [tappedWidgetAction], and picks up
  /// the tap that launched the app, if any.
  Future<void> listenForTaps();
}

/// Does nothing, for tests and for the platforms without a widget (WID-1).
class NoopHomeWidgetService implements HomeWidgetService {
  const NoopHomeWidgetService();

  @override
  bool get isSupported => false;

  @override
  Future<void> update(Map<String, Object?> payload) async {}

  @override
  Future<void> listenForTaps() async {}
}

/// Talks to the Android app widget and the iOS widget extension.
///
/// Only the formatted numbers cross over, as one JSON string, and they are
/// written where the widget can read them without the app running. The
/// database never leaves the app (WID-5).
class DeviceHomeWidgetService implements HomeWidgetService {
  static const channel = MethodChannel(
    'com.oasisforge.monthlyexpenses/home_widget',
  );

  @override
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool _listening = false;

  @override
  Future<void> update(Map<String, Object?> payload) async {
    if (!isSupported) return;
    try {
      await channel.invokeMethod<void>('update', jsonEncode(payload));
    } on PlatformException catch (error) {
      // A widget nobody has placed, or an OS that refused the redraw, is not
      // worth failing whatever change triggered this.
      debugPrint('Home-screen widget update failed: ${error.message}');
    } on MissingPluginException {
      // A platform build without the native half.
    }
  }

  @override
  Future<void> listenForTaps() async {
    if (!isSupported || _listening) return;
    _listening = true;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'tapped') {
        tappedWidgetAction.value = HomeWidgetAction.parse(
          call.arguments as String?,
        );
      }
    });
    try {
      // A tap that launched the app from cold is waiting on the other side.
      tappedWidgetAction.value = HomeWidgetAction.parse(
        await channel.invokeMethod<String>('launchAction'),
      );
    } on PlatformException {
      // Nothing pending.
    } on MissingPluginException {
      _listening = false;
    }
  }
}
