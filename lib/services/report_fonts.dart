import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show Locale;
import 'package:pdf/widgets.dart' as pw;

/// The fonts the PDF report embeds (PDF-5). They ship as assets rather than
/// being fetched, because the report is built on the device with no network
/// connection (PDF-4, RUN-2). See `assets/fonts/README.md` for their licences.
///
/// A report is mostly one script but rarely only one — an Arabic report can
/// hold a Latin account name, and an English one a Hindi note — so the face
/// for the app's language leads and every other face follows it as a
/// fallback.
///
/// Chinese, Japanese and Korean have no face here: theirs run to tens of
/// megabytes, which the app doesn't carry (PDF-7).
class ReportFonts {
  const ReportFonts({
    required this.base,
    required this.bold,
    required this.fallback,
  });

  final pw.Font base;
  final pw.Font bold;

  /// Tried, in order, for anything [base] and [bold] have no glyph for.
  final List<pw.Font> fallback;

  /// A regular and a bold face, as asset paths.
  static const _latin = (
    regular: 'assets/fonts/Roboto-Regular.ttf',
    bold: 'assets/fonts/Roboto-Bold.ttf',
  );
  static const _arabic = (
    regular: 'assets/fonts/NotoSansArabic-Regular.ttf',
    bold: 'assets/fonts/NotoSansArabic-Bold.ttf',
  );
  static const _devanagari = (
    regular: 'assets/fonts/NotoSansDevanagari-Regular.ttf',
    bold: 'assets/fonts/NotoSansDevanagari-Bold.ttf',
  );
  static const _bengali = (
    regular: 'assets/fonts/NotoSansBengali-Regular.ttf',
    bold: 'assets/fonts/NotoSansBengali-Bold.ttf',
  );
  static const _thai = (
    regular: 'assets/fonts/NotoSansThai-Regular.ttf',
    bold: 'assets/fonts/NotoSansThai-Bold.ttf',
  );

  /// Every face, in the order they are tried for a glyph the leading face
  /// hasn't got. Latin comes first: amounts, dates, and account names written
  /// in Latin letters turn up in reports in every language.
  static const _all = [_latin, _arabic, _devanagari, _bengali, _thai];

  /// The face each language leads with. A language that isn't here reads in
  /// Latin letters, so Roboto leads.
  static const _leading = {
    'ar': _arabic,
    'ur': _arabic,
    'hi': _devanagari,
    'bn': _bengali,
    'th': _thai,
  };

  /// The languages the report can be made in: every one with a face for its
  /// script (PDF-5, PDF-7).
  static const unsupportedLanguages = {'zh', 'ja', 'ko'};

  /// Whether a report can be made in [locale] at all (PDF-7).
  static bool supports(Locale locale) =>
      !unsupportedLanguages.contains(locale.languageCode);

  /// Loads the faces for [locale]: the script's own first, the rest behind it.
  static Future<ReportFonts> forLocale(Locale locale) async {
    final lead = _leading[locale.languageCode] ?? _latin;
    return ReportFonts(
      base: await _load(lead.regular),
      bold: await _load(lead.bold),
      fallback: [
        for (final face in _all)
          if (face != lead) ...[
            await _load(face.regular),
            await _load(face.bold),
          ],
      ],
    );
  }

  static Future<pw.Font> _load(String asset) async =>
      pw.Font.ttf(await rootBundle.load(asset));

  /// The report's theme, so every page inherits the right faces.
  pw.ThemeData get theme =>
      pw.ThemeData.withFont(base: base, bold: bold, fontFallback: fallback);
}
