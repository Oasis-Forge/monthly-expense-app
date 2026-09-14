import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show Locale;
import 'package:pdf/widgets.dart' as pw;

/// The fonts the PDF report embeds (PDF-5). They ship as assets rather than
/// being fetched, because the report is built on the device with no network
/// connection (PDF-4, RUN-2). See `assets/fonts/README.md` for their licences.
///
/// A report is mostly one script but rarely only one — an Arabic report can
/// hold a Latin account name, and an English one an Arabic note — so both
/// faces are always loaded and each falls back to the other.
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

  static const _roboto = 'assets/fonts/Roboto-Regular.ttf';
  static const _robotoBold = 'assets/fonts/Roboto-Bold.ttf';
  static const _arabic = 'assets/fonts/NotoSansArabic-Regular.ttf';
  static const _arabicBold = 'assets/fonts/NotoSansArabic-Bold.ttf';

  /// Loads the faces for [locale]: Noto Sans Arabic leads for Arabic, Roboto
  /// for the other five languages (LANG-1).
  static Future<ReportFonts> forLocale(Locale locale) async {
    final arabic = locale.languageCode == 'ar';
    final regularPath = arabic ? _arabic : _roboto;
    final boldPath = arabic ? _arabicBold : _robotoBold;
    final otherPath = arabic ? _roboto : _arabic;
    final otherBoldPath = arabic ? _robotoBold : _arabicBold;
    return ReportFonts(
      base: await _load(regularPath),
      bold: await _load(boldPath),
      fallback: [await _load(otherPath), await _load(otherBoldPath)],
    );
  }

  static Future<pw.Font> _load(String asset) async =>
      pw.Font.ttf(await rootBundle.load(asset));

  /// The report's theme, so every page inherits the right faces.
  pw.ThemeData get theme =>
      pw.ThemeData.withFont(base: base, bold: bold, fontFallback: fallback);
}
