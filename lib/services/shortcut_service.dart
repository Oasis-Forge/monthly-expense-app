import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:quick_actions/quick_actions.dart';

/// One item on the app icon's long press (NAV-8): what it is, and what it
/// says in the app's own language.
typedef Shortcut = ({String type, String label});

/// The app icon's long-press menu (NAV-8), behind an interface so that the
/// app, a desktop build and a test can each be given what suits them.
abstract class ShortcutService {
  /// Whether this platform gives an icon a long press at all.
  bool get supported;

  /// Calls [handler] with the type of whichever item was chosen, including
  /// one chosen while the app was not running.
  void onSelected(void Function(String type) handler);

  /// Replaces the menu. Called again whenever the language changes.
  Future<void> setItems(List<Shortcut> items);
}

class DeviceShortcuts implements ShortcutService {
  DeviceShortcuts([QuickActions? actions])
    : _actions = actions ?? const QuickActions();

  final QuickActions _actions;

  @override
  bool get supported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void onSelected(void Function(String type) handler) {
    if (!supported) return;
    _actions.initialize(handler);
  }

  @override
  Future<void> setItems(List<Shortcut> items) async {
    if (!supported) return;
    await _actions.setShortcutItems([
      for (final item in items)
        ShortcutItem(type: item.type, localizedTitle: item.label),
    ]);
  }
}

/// Windows and Linux, where an icon has no long press to give (NAV-8).
class NoShortcuts implements ShortcutService {
  const NoShortcuts();

  @override
  bool get supported => false;

  @override
  void onSelected(void Function(String type) handler) {}

  @override
  Future<void> setItems(List<Shortcut> items) async {}
}

/// The device's own where there is a long press to put them on, and nothing
/// at all where there is not.
ShortcutService deviceOrNoShortcuts() {
  final device = DeviceShortcuts();
  return device.supported ? device : const NoShortcuts();
}
