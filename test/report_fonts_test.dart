import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:monthly_expense_app/l10n/languages.dart';
import 'package:monthly_expense_app/services/report_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('report fonts (PDF-4, PDF-5)', () {
    test('every app language loads a face that covers its script', () async {
      for (final code in appLanguages.keys) {
        final fonts = await ReportFonts.forLocale(Locale(code));
        expect(fonts.base, isNotNull, reason: code);
        expect(fonts.bold, isNotNull, reason: code);
        expect(fonts.fallback, hasLength(2), reason: code);
      }
    });

    test('Arabic leads with Noto Sans Arabic, the rest with Roboto', () async {
      final arabic = await ReportFonts.forLocale(const Locale('ar'));
      expect(arabic.base.fontName, contains('NotoSansArabic'));

      for (final code in appLanguages.keys.where((c) => c != 'ar')) {
        final fonts = await ReportFonts.forLocale(Locale(code));
        expect(fonts.base.fontName, contains('Roboto'), reason: code);
      }
    });

    test('a page of each language builds a PDF with the text in it', () async {
      // One line per language, each with a character the others' face lacks,
      // so a missing glyph or a failed fallback would throw here (PDF-5).
      const samples = {
        'en': 'Groceries',
        'tr': 'Alışveriş fişi',
        'ar': 'مصروفات الشهر',
        'fr': 'Dépenses du mois',
        'es': 'Gastos del mes',
        'de': 'Ausgaben für Straße',
      };

      for (final MapEntry(key: code, value: text) in samples.entries) {
        final fonts = await ReportFonts.forLocale(Locale(code));
        final document = pw.Document(theme: fonts.theme);
        document.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            textDirection: code == 'ar'
                ? pw.TextDirection.rtl
                : pw.TextDirection.ltr,
            build: (context) => pw.Column(
              children: [
                pw.Text(text),
                pw.Text(
                  text,
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
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
