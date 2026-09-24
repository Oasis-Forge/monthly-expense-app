import 'package:flutter/material.dart';

/// The app's own colour. Used wherever the phone offers no palette of its
/// own (THEME-2), and everywhere outside the app (THEME-3).
const appSeed = Color(0xFF6C5CE7);

/// True black, for the screens where an unlit pixel costs nothing (THEME-1).
const _black = Color(0xFF000000);

/// The theme for one brightness.
///
/// [fromPhone] is the wallpaper palette Android 12 and later offer, already
/// of the right brightness; where it is null — an older Android, or any
/// other platform — the app's own seed is used instead (THEME-2). [black]
/// puts true black behind everything and only applies to dark.
ThemeData appTheme({
  ColorScheme? fromPhone,
  required Brightness brightness,
  bool black = false,
}) {
  var scheme =
      fromPhone ??
      ColorScheme.fromSeed(seedColor: appSeed, brightness: brightness);
  if (black && brightness == Brightness.dark) {
    scheme = scheme.copyWith(surface: _black);
  }
  final theme = ThemeData(colorScheme: scheme, useMaterial3: true);
  if (!black || brightness != Brightness.dark) return theme;
  return theme.copyWith(scaffoldBackgroundColor: _black, canvasColor: _black);
}
