import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:monthly_expense_app/l10n/languages.dart';
import 'package:monthly_expense_app/services/report_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The languages a report can be made in: all but Chinese, Japanese and
  /// Korean, whose faces the app doesn't carry (PDF-7).
  final supported = appLanguages.keys.where(
    (code) => !ReportFonts.unsupportedLanguages.contains(code),
  );

  group('report fonts (PDF-4, PDF-5, PDF-7)', () {
    test(
      'every language with a face loads one, and the rest behind it',
      () async {
        for (final code in supported) {
          final fonts = await ReportFonts.forLocale(Locale(code));
          expect(fonts.base, isNotNull, reason: code);
          expect(fonts.bold, isNotNull, reason: code);
          // The four faces this one doesn't lead with, regular and bold.
          expect(fonts.fallback, hasLength(8), reason: code);
        }
      },
    );

    test('each script leads with its own face', () async {
      const leads = {
        'ar': 'NotoSansArabic',
        'ur': 'NotoSansArabic',
        'hi': 'NotoSansDevanagari',
        'bn': 'NotoSansBengali',
        'th': 'NotoSansThai',
      };

      for (final code in supported) {
        final fonts = await ReportFonts.forLocale(Locale(code));
        expect(
          fonts.base.fontName,
          contains(leads[code] ?? 'Roboto'),
          reason: code,
        );
      }
    });

    test('Chinese, Japanese and Korean are refused rather than printed '
        'as boxes (PDF-7)', () {
      for (final code in ['zh', 'ja', 'ko']) {
        expect(ReportFonts.supports(Locale(code)), isFalse, reason: code);
      }
      for (final code in supported) {
        expect(ReportFonts.supports(Locale(code)), isTrue, reason: code);
      }
    });

    test('a page of each script builds a PDF with the text in it', () async {
      // One line per script, each with characters the other faces lack, so a
      // missing glyph or a failed fallback would throw here (PDF-5).
      const samples = {
        'en': 'Groceries',
        'tr': 'Alışveriş fişi',
        'de': 'Ausgaben für Straße',
        'vi': 'Chi tiêu tháng này',
        'pl': 'Wydatki miesiąca',
        'el': 'Έξοδα του μήνα',
        'ru': 'Расходы за месяц',
        'ar': 'مصروفات الشهر',
        'ur': 'ماہانہ اخراجات',
        'hi': 'महीने का खर्च',
        'bn': 'মাসের খরচ',
        'th': 'ค่าใช้จ่ายรายเดือน',
      };

      for (final MapEntry(key: code, value: text) in samples.entries) {
        final fonts = await ReportFonts.forLocale(Locale(code));
        final document = pw.Document(theme: fonts.theme);
        document.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            textDirection: rightToLeftLanguages.contains(code)
                ? pw.TextDirection.rtl
                : pw.TextDirection.ltr,
            build: (context) => pw.Column(
              children: [
                pw.Text(text),
                pw.Text(
                  text,
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                // A Latin account name turns up in reports in every
                // language, so the fallback carries it (PDF-5).
                pw.Text('Cash'),
                // Amounts stay left to right in every language (LANG-3).
                pw.Directionality(
                  textDirection: pw.TextDirection.ltr,
                  child: pw.Text('1,234.56'),
                ),
              ],
            ),
          ),
        );

        final bytes = await document.save();
        expect(bytes.length, greaterThan(1000), reason: code);
        expect(
          String.fromCharCodes(bytes.take(5)),
          '%PDF-',
          reason: '$code should produce a real PDF',
        );
      }
    });
  });
}
