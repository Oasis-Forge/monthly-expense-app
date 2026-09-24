import 'package:flutter/material.dart' show ThemeMode;

/// What the Theme row offers (THEME-1).
///
/// Black is a variant of dark rather than a mood of its own: everything in
/// the app that asks reads it as dark, and only the surfaces change.
enum AppTheme {
  system,
  light,
  dark,
  black;

  /// The brightness this choice asks Flutter for. Black forces dark even on
  /// a phone set to light, because black is what dark looks like here.
  ThemeMode get themeMode => switch (this) {
    AppTheme.system => ThemeMode.system,
    AppTheme.light => ThemeMode.light,
    AppTheme.dark || AppTheme.black => ThemeMode.dark,
  };

  /// Whether the dark surfaces are true black (THEME-1).
  bool get isBlack => this == AppTheme.black;

  /// The choice stored under [name], or following the phone when the stored
  /// value is missing or from a version that did not write this one. The
  /// three older values — system, light, dark — carry over unchanged.
  static AppTheme named(String? name) {
    for (final theme in AppTheme.values) {
      if (theme.name == name) return theme;
    }
    return AppTheme.system;
  }
}
