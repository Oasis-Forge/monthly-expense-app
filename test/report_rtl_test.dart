import 'dart:typed_data';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/report.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/services/report_fonts.dart';
import 'package:monthly_expense_app/services/report_pdf.dart';

import 'helpers.dart';
import 'pdf_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The app's own formatter (settings.currencyFormat), exactly as
  // report_screen.dart calls it — not a hand-rolled NumberFormat — so these
  // tests exercise the real isolate marks an Arab currency and language
  // combination produces (LANG-5, CUR-5, PDF-5).
  Future<Uint8List> report(
    String code, {
    List<ExpenseTransaction> transactions = const [],
    String currencyCode = 'USD',
    Money? Function(String categoryId)? budgetLimit,
  }) async {
    final l10n = await AppLocalizations.delegate.load(Locale(code));
    final settings = await testSettings({'currency_code': currencyCode});
    final data = buildReport(
      from: DateTime(2026, 9, 1),
      to: DateTime(2026, 9, 30),
      today: DateTime(2026, 9, 15),
      transactions: transactions,
      transfers: const [],
      accounts: [testAccount('cash', opening: 100)],
      budgetLimit: budgetLimit,
    );
    return buildReportPdf(
      data: data,
      options: const ReportOptions(),
      labels: ReportLabels(
        l10n: l10n,
        locale: Locale(code),
        currency: settings.currencyFormat(code),
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
          RegExp(r'\+[^\d]{0,3}40').hasMatch(text),
          isTrue,
          reason: '$code: $text',
        );
        // The report signs through the same formatter as the screens, so the
        // minus is the language's own rather than a typographic one the
        // report chose for itself (CUR-5).
        expect(
          RegExp(r'[-\u2212][^\d]{0,3}25').hasMatch(text),
          isTrue,
          reason: '$code: $text',
        );
      }
    });

    test(
      'an Arab-currency (SAR) amount signs the same way in the PDF as on '
      'screen: sign right next to its digits (LANG-5, CUR-5, Decision 54)',
      () async {
        final text = squashed(
          pdfText(await report('ar', transactions: spend, currencyCode: 'SAR')),
        );

        expect(
          RegExp(r'[-−][^\d]{0,3}25').hasMatch(text),
          isTrue,
          reason: 'sign should sit right next to its digits, got: $text',
        );
      },
    );

    test('a Latin-symbol currency (USD) keeps its symbol on the left in the '
        'PDF, as it does on screen, even in an Arabic report (LANG-5, '
        'Decision 54)', () async {
      final text = squashed(
        pdfText(await report('ar', transactions: spend, currencyCode: 'USD')),
      );

      expect(
        RegExp(r'\$[^\d]{0,3}[-−][^\d]{0,3}25').hasMatch(text),
        isTrue,
        reason: 'symbol should lead the sign and digits, got: $text',
      );
    });

    test(
      'a budgeted category in an Arabic (SAR) report keeps the used '
      'percentage and the limit apart, in the right x-order (pr61#2)',
      () async {
        final bytes = await report(
          'ar',
          transactions: spend,
          currencyCode: 'SAR',
          budgetLimit: (_) => const Money(500000),
        );
        final lines = pdfLines(bytes);

        // The limit's figures ("500") are unique on the page, and unlike
        // the old bug they are their own run rather than glued to the
        // percentage's digits.
        final limitIndex = lines.indexWhere((l) => l == '500');
        expect(limitIndex, isNot(-1), reason: 'no isolated 500 run in $lines');
        expect(limitIndex, greaterThan(0));
        expect(lines[limitIndex - 1], isNot(contains('500')));
        expect(lines[limitIndex + 1], isNot(contains('500')));

        // after | isolate | before, visually left to right: the symbol
        // (shaped and reordered, unlike the plain letters the old bug
        // drew) leads the limit's figures, which lead the used
        // percentage-and-"of" run.
        final symbolRun = lines[limitIndex - 1];
        expect(RegExp('[0-9]').hasMatch(symbolRun), isFalse);
        expect(symbolRun.runes, isNot(contains('ر'.runes.single)));

        final usedRun = lines[limitIndex + 1];
        expect(usedRun, contains('%'));
        expect(usedRun, contains('5'));
      },
    );

    test('a budgeted category in an Urdu report keeps the limit and the used '
        'percentage apart, in the right x-order (pr61#2)', () async {
      final bytes = await report(
        'ur',
        transactions: spend,
        currencyCode: 'SAR',
        budgetLimit: (_) => const Money(500000),
      );
      final lines = pdfLines(bytes);

      // {limit} میں سے {used}: ur's SAR pattern leads with the symbol, so
      // the whole limit (symbol and figures) is one isolated run; the used
      // percentage and "میں سے" sit in the run right before it, not glued
      // onto its figures.
      final limitIndex = lines.indexWhere(
        (l) => l.contains('500') && !l.contains('%'),
      );
      expect(limitIndex, isNot(-1), reason: 'no limit run in $lines');
      expect(limitIndex, greaterThan(0));

      final usedRun = lines[limitIndex - 1];
      expect(usedRun, isNot(contains('500')));
      expect(usedRun, contains('%'));
      expect(usedRun, contains('5'));
    });

    test('an Arab-currency symbol keeps a gap from the signed figures, '
        'shaped and reordered, instead of running into them as plain '
        'letters (pr61#2)', () async {
      final bytes = await report(
        'ar',
        transactions: spend,
        currencyCode: 'SAR',
      );
      final lines = pdfLines(bytes);

      // The balance line is negative in this report (100 opening, -25
      // spent): its figures are a run of exactly '-25', on their own.
      final figuresIndex = lines.indexWhere((l) => l == '-25');
      expect(figuresIndex, isNot(-1), reason: 'no isolated -25 run in $lines');
      expect(figuresIndex, greaterThan(0));

      // The symbol sits in the run right before it — never merged into the
      // same run as the figures, which is what the old forced-left-to-right
      // concatenation produced (one run, 'ر.س.-25.00', with the letters
      // drawn in their plain, unshaped, unreordered form since the bidi
      // pass never ran on it).
      final symbolRun = lines[figuresIndex - 1];
      expect(symbolRun, isNot(contains('-25')));
      expect(RegExp('[0-9]').hasMatch(symbolRun), isFalse);
      // A shaped, reordered Arabic run draws presentation-form glyphs
      // (U+FB50–U+FEFF), not the plain letters the old bug left behind.
      expect(
        symbolRun.runes.any((r) => r >= 0xFB50 && r <= 0xFEFF),
        isTrue,
        reason: 'expected shaped presentation forms, got: $symbolRun',
      );
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
