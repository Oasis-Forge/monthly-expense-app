import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/authenticator.dart';

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

  DateTime _now() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locked = context.read<SettingsProvider>().appLock;
    if (_locked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The system prompt itself sends the app to the background.
    if (_authenticating || _locked) return;
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _hiddenAt ??= _now();
      case AppLifecycleState.resumed:
        final hiddenAt = _hiddenAt;
        _hiddenAt = null;
        if (hiddenAt != null &&
            context.read<SettingsProvider>().appLock &&
            _now().difference(hiddenAt) >= AppLock.timeout) {
          setState(() => _locked = true);
          _unlock();
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _unlock() async {
    if (_authenticating || !mounted) return;
    final settings = context.read<SettingsProvider>();
    final authenticator = context.read<Authenticator>();
    final reason = AppLocalizations.of(context).appLockReason;
    setState(() => _authenticating = true);
    final result = await authenticator.authenticate(reason);
    // LOCK-3: without biometrics or a screen lock, nothing can confirm the
    // owner, so app lock turns off rather than lock the data away.
    if (result == AuthResult.unavailable) await settings.setAppLock(false);
    if (!mounted) return;
    setState(() {
      _authenticating = false;
      if (result != AuthResult.failed) _locked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ExcludeFocus(
          excluding: _locked,
          child: IgnorePointer(
            ignoring: _locked,
            child: ExcludeSemantics(
              excluding: _locked,
              child: TickerMode(enabled: !_locked, child: widget.child),
            ),
          ),
        ),
        if (_locked)
          Positioned.fill(
            child: _LockScreen(busy: _authenticating, onUnlock: _unlock),
          ),
      ],
    );
  }
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
