import 'package:flutter/widgets.dart' show Locale, WidgetsBinding;

/// The app's languages (LANG-1), each named in its own language. The names
/// stay untranslated on purpose, so people can find their language whatever
/// the app currently shows.
const appLanguages = {
  'en': 'English',
  'tr': 'Türkçe',
  'ar': 'العربية',
  'fr': 'Français',
  'es': 'Español',
  'de': 'Deutsch',
};

/// The first of the device's [preferred] locales whose language the app has,
/// else English (LANG-1). Flutter's own fallback is the first supported
/// locale, which would be Arabic.
Locale resolveAppLocale(List<Locale>? preferred) {
  for (final locale in preferred ?? const <Locale>[]) {
    if (appLanguages.containsKey(locale.languageCode)) {
      return Locale(locale.languageCode);
    }
  }
  return const Locale('en');
}

/// The locale the app runs in: the [chosen] language, or the best match for
/// the device's when the user follows the system (LANG-1). For code outside
/// the widget tree, such as a note's reminder notification (NOTE-6).
Locale effectiveAppLocale(Locale? chosen) =>
    chosen ??
    resolveAppLocale(WidgetsBinding.instance.platformDispatcher.locales);
