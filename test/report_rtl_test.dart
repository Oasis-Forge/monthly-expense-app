import 'dart:typed_data';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/models/report.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/services/report_fonts.dart';
import 'package:monthly_expense_app/services/report_pdf.dart';

import 'helpers.dart';
import 'pdf_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Uint8List> report(
    String code, {
    List<ExpenseTransaction> transactions = const [],
  }) async {
    final l10n = await AppLocalizations.delegate.load(Locale(code));
    final data = buildReport(
      from: DateTime(2026, 9, 1),
      to: DateTime(2026, 9, 30),
      today: DateTime(2026, 9, 15),
      transactions: transactions,
      transfers: const [],
      accounts: [testAccount('cash', opening: 100)],
    );
    return buildReportPdf(
      data: data,
      options: const ReportOptions(),
      labels: ReportLabels(
        l10n: l10n,
        locale: Locale(code),
        currency: NumberFormat.currency(
          locale: l10n.localeName,
          symbol: r'$',
          name: 'USD',
        ),
        categoryName: (id) => 'Groceries',
        accountName: (id) => 'Cash',
      ),
      fonts: await ReportFonts.forLocale(Locale(code)),
      createdAt: DateTime(2026, 9, 15, 14, 30),
      pageFormat: PdfPageFormat.a4,
      compress: false,
    );
  }

  final spend = [
    testTx(
      'a',
      TransactionType.expense,
      25,
      DateTime(2026, 9, 4),
      title: 'Weekly shop',
    ),
  ];

  group('the report reads the right way round (PDF-5, LANG-5)', () {
    test('an English report draws its words forwards', () async {
      final text = squashed(pdfText(await report('en', transactions: spend)));

      expect(text, contains('MonthlyExpenses'));
      expect(text, contains('Weeklyshop'));
      for (final word in ['Groceries', 'Cash', 'USD']) {
        expect(text, contains(word));
      }
    });

    test('an Arabic report draws Latin words forwards too', () async {
      final text = squashed(pdfText(await report('ar', transactions: spend)));

      // Left to the page's own bidi pass these come out backwards: v1.3.0
      // printed the app's name as "sesnepxEylhtnoM" and USD as "DSU".
      expect(text, contains('MonthlyExpenses'));
      expect(text, contains('Weeklyshop'));
      for (final word in ['Groceries', 'Cash', 'USD']) {
        expect(text, contains(word));
      }
      expect(text, isNot(contains('ylhtnoM')));
      expect(text, isNot(contains('DSU')));
    });

    test('an Arabic report still draws its Arabic', () async {
      final text = squashed(pdfText(await report('ar', transactions: spend)));

      // Arabic is written out as presentation forms, so look for the block
      // rather than for the source spelling.
      final arabic = text.runes.where(
        (rune) =>
            (rune >= 0x0600 && rune <= 0x06FF) ||
            (rune >= 0xFB50 && rune <= 0xFEFF),
      );
      expect(arabic, isNotEmpty);
    });

    test('an amount is drawn whole, with its sign leading', () async {
      final signed = [
        ...spend,
        testTx('b', TransactionType.income, 40, DateTime(2026, 9, 5)),
      ];
      for (final code in ['en', 'ar']) {
        final text = squashed(
          pdfText(await report(code, transactions: signed)),
        );

        // Where the currency symbol sits is the locale's business; the sign
        // staying in front of its own digits is ours.
        expect(
          RegExp(r'\+[^\d]{0,3}40\.00').hasMatch(text),
          isTrue,
          reason: '$code: $text',
        );
        expect(
          RegExp(r'−[^\d]{0,3}25\.00').hasMatch(text),
          isTrue,
          reason: '$code: $text',
        );
      }
    });

    test('no amount carries a stray bidi mark (LANG-3)', () async {
      final text = squashed(pdfText(await report('ar', transactions: spend)));

      // An Arabic number format embeds these, and a PDF font draws them as
      // a visible speck instead of honouring them.
      expect(
        text.runes.where(
          (rune) => rune == 0x200E || rune == 0x200F || rune == 0x061C,
        ),
        isEmpty,
      );
    });

    test('every language draws its own words forwards', () async {
      for (final code in ['en', 'tr', 'ar', 'fr', 'es', 'de']) {
        final text = squashed(pdfText(await report(code, transactions: spend)));
        expect(text, contains('MonthlyExpenses'), reason: code);
        expect(text, contains('Groceries'), reason: code);
      }
    });
  });
}
