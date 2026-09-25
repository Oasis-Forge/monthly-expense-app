import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/authenticator.dart';

/// Whether the lock screen is covering the app (LOCK-2).
///
/// The app underneath keeps its state, so a screen that loads things by
/// itself would carry on behind the lock. The ad slots watch this and stop,
/// because no ad may load while the app is locked (ADS-9).
final appIsLocked = ValueNotifier<bool>(false);

/// Covers the app until the device owner authenticates, when app lock is on
/// (LOCK-1–LOCK-3). The app underneath keeps its state.
class AppLock extends StatefulWidget {
  const AppLock({super.key, required this.child, this.clock});

  final Widget child;

  /// Supplies "now"; tests pass their own.
  final DateTime Function()? clock;

  /// How long the app can stay in the background before it locks (LOCK-2).
  static const timeout = Duration(minutes: 1);

  @override
  State<AppLock> createState() => _AppLockState();
}

class _AppLockState extends State<AppLock> with WidgetsBindingObserver {
  late bool _locked;
  bool _authenticating = false;
  DateTime? _hiddenAt;

  /// True from the moment the app leaves the foreground until it's back, so
  /// long as App Lock is on — covering the last frame in Dart itself
  /// (LOCK-2). The native side only keeps the OS from screenshotting or
  /// thumbnailing the window (see [_syncSecure]); Flutter still holds and
  /// can redraw that last frame on the live surface, and iOS drops its own
  /// native cover on `didBecomeActive` before Dart has had a chance to
  /// react to `resumed` and lock. This flag closes that gap without waiting
  /// for [AppLock.timeout] or asking the user anything.
  bool _obscured = false;

  /// Told whether App Lock is turned on, so the OS never keeps a readable
  /// snapshot of the app around while it is (LOCK-2): Android sets
  /// FLAG_SECURE on the window (MainActivity.kt), iOS covers the app the
  /// moment it resigns active (SecurityBridge.swift) rather than waiting for
  /// Dart to notice and draw the lock screen, which is already too late for
  /// the snapshot the app switcher takes. A no-op on desktop and in tests,
  /// where nothing answers the channel.
  static const _security = MethodChannel(
    'com.oasisforge.monthlyexpenses/security',
  );

  static bool get _hasNativeLock =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool? _secureSent;

  // Cached rather than read from context each time: dispose() needs it too,
  // and reading an inherited widget's context there is unsafe.
  late final SettingsProvider _settings = context.read<SettingsProvider>();

  DateTime _now() => (widget.clock ?? DateTime.now)();

  /// Keeps [appIsLocked] with `_locked`, so the ad slots see it (ADS-9).
  void _setLocked(bool locked) {
    setState(() => _locked = locked);
    appIsLocked.value = locked;
  }

  /// Pushes whether App Lock is on to the native side, only when it
  /// changed, so turning the setting on or off takes effect on the very
  /// next time the app leaves the foreground.
  void _syncSecure() {
    if (!_hasNativeLock) return;
    final secure = _settings.appLock;
    if (secure == _secureSent) return;
    _secureSent = secure;
    unawaited(_sendSecure(secure));
  }

  Future<void> _sendSecure(bool secure) async {
    try {
      await _security.invokeMethod<void>('setSecure', secure);
    } on PlatformException {
      // The OS refused for its own reasons; nothing more to do here.
    } on MissingPluginException {
      // No native side registered: an old build, or a test.
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locked = _settings.appLock;
    appIsLocked.value = _locked;
    if (_locked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
    _settings.addListener(_syncSecure);
    _syncSecure();
  }

  @override
  void dispose() {
    _settings.removeListener(_syncSecure);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The system prompt itself sends the app to the background.
    if (_authenticating || _locked) return;
    switch (state) {
      case AppLifecycleState.inactive:
        // The earliest signal that the app is leaving the foreground: cover
        // it right away, before the OS has a chance to snapshot this frame
        // (LOCK-2).
        if (_settings.appLock) setState(() => _obscured = true);
      case AppLifecycleState.hidden:
        if (_settings.appLock) setState(() => _obscured = true);
        _hiddenAt ??= _now();
      case AppLifecycleState.paused:
        _hiddenAt ??= _now();
      case AppLifecycleState.resumed:
        final hiddenAt = _hiddenAt;
        _hiddenAt = null;
        if (hiddenAt != null &&
            _settings.appLock &&
            _now().difference(hiddenAt) >= AppLock.timeout) {
          _setLocked(true);
          _unlock();
        }
        // Either the real lock screen above just took over, or the app
        // never actually locked (back inside the timeout): either way
        // nothing should stay obscured now.
        if (_obscured) setState(() => _obscured = false);
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _unlock() async {
    if (_authenticating || !mounted) return;
    final authenticator = context.read<Authenticator>();
    final reason = AppLocalizations.of(context).appLockReason;
    setState(() => _authenticating = true);
    final result = await authenticator.authenticate(reason);
    // LOCK-3: without biometrics or a screen lock, nothing can confirm the
    // owner, so app lock turns off rather than lock the data away.
    if (result == AuthResult.unavailable) await _settings.setAppLock(false);
    if (!mounted) return;
    setState(() => _authenticating = false);
    if (result != AuthResult.failed) _setLocked(false);
  }

  @override
  Widget build(BuildContext context) {
    final hidden = _locked || _obscured;
    return Stack(
      children: [
        ExcludeFocus(
          excluding: hidden,
          child: IgnorePointer(
            ignoring: hidden,
            child: ExcludeSemantics(
              excluding: hidden,
              child: TickerMode(enabled: !_locked, child: widget.child),
            ),
          ),
        ),
        if (_locked)
          Positioned.fill(
            child: _LockScreen(busy: _authenticating, onUnlock: _unlock),
          )
        else if (_obscured)
          const Positioned.fill(child: _ObscureCover()),
      ],
    );
  }
}

/// Plain cover with nothing to read, shown the instant the app leaves the
/// foreground while App Lock is on (LOCK-2). It asks nothing and appears
/// before there is any way to know yet whether the app will actually end up
/// locked; [_LockScreen] takes over instead if it does.
class _ObscureCover extends StatelessWidget {
  const _ObscureCover();

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: Theme.of(context).colorScheme.surface);
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.busy, required this.onUnlock});

  final bool busy;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.lockedTitle,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: busy ? null : onUnlock,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.unlockButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
