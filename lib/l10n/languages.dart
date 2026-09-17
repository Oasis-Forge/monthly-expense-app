import 'package:flutter/widgets.dart' show Locale, WidgetsBinding;

/// The app's languages (LANG-1), each named in its own language. The names
/// stay untranslated on purpose, so people can find their language whatever
/// the app currently shows.
///
/// English leads, as the language every message is written in first; the
/// other twenty follow in the order of their English names, since no one
/// order can be alphabetical across this many scripts.
const appLanguages = {
  'en': 'English',
  'ar': 'العربية',
  'bn': 'বাংলা',
  'zh': '简体中文',
  'nl': 'Nederlands',
  'fr': 'Français',
  'de': 'Deutsch',
  'el': 'Ελληνικά',
  'hi': 'हिन्दी',
  'id': 'Bahasa Indonesia',
  'it': 'Italiano',
  'ja': '日本語',
  'ko': '한국어',
  'pl': 'Polski',
  'pt': 'Português',
  'ru': 'Русский',
  'es': 'Español',
  'th': 'ไทย',
  'tr': 'Türkçe',
  'ur': 'اردو',
  'vi': 'Tiếng Việt',
};

/// The languages that read right to left (LANG-5).
const rightToLeftLanguages = {'ar', 'ur'};

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
