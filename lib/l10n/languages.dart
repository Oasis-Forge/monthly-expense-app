import 'package:flutter/widgets.dart' show Locale, WidgetsBinding;
import 'package:intl/date_symbol_data_local.dart' show dateTimeSymbolMap;

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

/// First-day-of-week overrides where PER-4's product choice differs from
/// the region's own CLDR/intl convention, rather than a gap in intl's data.
/// In [firstDayOfWeekIndex]'s own numbering (0 is Sunday).
///
/// Portugal is Monday here on purpose, not because CLDR calls for it: CLDR's
/// own supplemental weekData lists `PT` under `firstDay="sun"`, and intl's
/// `pt_PT` symbols agree (`FIRSTDAYOFWEEK` matches generic and Brazilian
/// Portuguese, both Sunday). PER-4 chooses Monday for it anyway, to match
/// the convention the rest of the EU actually follows day to day.
const _weekStartOverrides = {'PT': 1};

/// The device's own first day of the week (PER-4), from [deviceLocales]
/// (a [PlatformDispatcher.locales]) when its most-preferred locale's
/// language is the one the app is currently showing ([appLanguage]) —
/// else null, so the caller falls back to that language's own plain
/// default the way it already did, the right answer for a language the
/// user picked on purpose, unconnected to their phone's own region.
///
/// [MaterialLocalizations.firstDayOfWeekIndex] only ever sees the app's
/// own locale, which [resolveAppLocale] always resolves language-only,
/// dropping whatever region the device itself carries — so a phone set to
/// English (UK) or Portuguese (Portugal) got the language's plain
/// Sunday-first default instead of its own region's Monday.
int? deviceWeekStartIndex(List<Locale> deviceLocales, String appLanguage) {
  if (deviceLocales.isEmpty) return null;
  final device = deviceLocales.first;
  if (device.languageCode != appLanguage) return null;
  final region = device.countryCode;
  if (region == null) return null;
  final override = _weekStartOverrides[region];
  if (override != null) return override;
  final symbols = dateTimeSymbolMap()['${device.languageCode}_$region'];
  if (symbols == null) return null;
  return (symbols.FIRSTDAYOFWEEK + 1) % 7;
}
