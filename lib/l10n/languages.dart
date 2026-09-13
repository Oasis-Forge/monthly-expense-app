import 'package:flutter/widgets.dart' show Locale;

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
