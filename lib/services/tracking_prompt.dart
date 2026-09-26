import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';

export 'package:app_tracking_transparency/app_tracking_transparency.dart'
    show TrackingStatus;

/// iOS's own App Tracking Transparency question: whether the ads may be
/// chosen using the device's advertising identifier (ADS-17). Behind an
/// interface so tests never reach the plugin, the way `AdService` keeps them
/// away from the ad SDK.
///
/// Only `DeviceAdService` asks it, only on iOS, and only once consent allows
/// ads at all; this is just the question itself.
abstract interface class TrackingPrompt {
  /// The answer iOS already holds, without asking anything.
  Future<TrackingStatus> status();

  /// Puts iOS's prompt up and completes with the answer. iOS shows it at
  /// most once per install; after that it answers at once without asking.
  Future<TrackingStatus> request();
}

/// The real thing, over `app_tracking_transparency`.
class DeviceTrackingPrompt implements TrackingPrompt {
  const DeviceTrackingPrompt();

  @override
  Future<TrackingStatus> status() =>
      AppTrackingTransparency.trackingAuthorizationStatus;

  @override
  Future<TrackingStatus> request() =>
      AppTrackingTransparency.requestTrackingAuthorization();
}

/// Completes once the app is in the foreground and active, and not behind
/// the lock screen — the only moment the tracking prompt may go up (ADS-17).
///
/// iOS ignores the request from an app that is not active, so asking from
/// anywhere else would leave the question unasked, and the prompt never
/// covers the lock screen (ADS-9, LOCK-2). A state the engine has not yet
/// reported counts as active: waiting on a report that never comes would
/// hold the ads back for good, and by the time consent has been settled the
/// engine has always reported one.
Future<void> untilPromptable(
  WidgetsBinding binding, {
  ValueListenable<bool>? locked,
}) {
  bool ready() {
    final state = binding.lifecycleState;
    final active = state == null || state == AppLifecycleState.resumed;
    return active && !(locked?.value ?? false);
  }

  if (ready()) return Future.value();
  final waiter = _Waiter(binding, locked, ready);
  return waiter.done.future;
}

/// Watches the app's state and the lock until both allow the prompt, then
/// lets go of both.
class _Waiter with WidgetsBindingObserver {
  _Waiter(this._binding, this._locked, this._ready) {
    _binding.addObserver(this);
    _locked?.addListener(_check);
  }

  final WidgetsBinding _binding;
  final ValueListenable<bool>? _locked;
  final bool Function() _ready;
  final done = Completer<void>();

  void _check() {
    if (done.isCompleted || !_ready()) return;
    _binding.removeObserver(this);
    _locked?.removeListener(_check);
    done.complete();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _check();
}
