import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/l10n/languages.dart';
import 'package:monthly_expense_app/models/report.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/services/report_fonts.dart';
import 'package:monthly_expense_app/services/report_pdf.dart';

import 'helpers.dart';
import 'pdf_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final today = DateTime(2026, 9, 15);
  final createdAt = DateTime(2026, 9, 15, 14, 30);

  Future<ReportLabels> labelsFor(String code) async {
    final l10n = await AppLocalizations.delegate.load(Locale(code));
    return ReportLabels(
      l10n: l10n,
      locale: Locale(code),
      currency: NumberFormat.currency(
        locale: l10n.localeName,
        symbol: r'$',
        name: 'USD',
      ),
      categoryName: (id) => id.replaceFirst('cat-', ''),
      accountName: (id) => id,
    );
  }

  ReportData dataWith(
    List<ExpenseTransaction> transactions, {
    DateTime? from,
    DateTime? to,
    ReportOptions options = const ReportOptions(),
  }) => buildReport(
    from: from ?? DateTime(2026, 9, 1),
    to: to ?? DateTime(2026, 9, 30),
    today: today,
    transactions: transactions,
    transfers: const [],
    accounts: [testAccount('cash', opening: 100)],
    options: options,
  );

  List<ExpenseTransaction> manyEntries(int count) => [
    for (var i = 0; i < count; i++)
      testTx(
        'tx-$i',
        i.isEven ? TransactionType.expense : TransactionType.income,
        (i % 40) + 1,
        DateTime(2026, 9, 1 + (i % 14)),
        title: 'Entry number $i',
        note: 'A note on entry $i',
      ),
  ];

  Future<List<int>> build(
    ReportData data, {
    String code = 'en',
    ReportOptions options = const ReportOptions(),
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    void Function(double)? onProgress,
    bool Function()? isCancelled,
  }) async => buildReportPdf(
    data: data,
    options: options,
    labels: await labelsFor(code),
    fonts: await ReportFonts.forLocale(Locale(code)),
    createdAt: createdAt,
    pageFormat: pageFormat,
    onProgress: onProgress,
    isCancelled: isCancelled,
  );

  group('report PDF (PDF-2, PDF-5)', () {
    test('a report with entries comes out as a real PDF', () async {
      final bytes = await build(dataWith(manyEntries(20)));

      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(5000));
    });

    test('an empty range still produces a readable report', () async {
      final data = dataWith(const []);
      expect(data.isEmpty, isTrue);

      final bytes = await build(data);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    // These only say a document came out; that it can be *read* is
    // report_rtl_test.dart's job, which is what v1.3.0's reversed Arabic
    // slipped past.
    test('every language builds, Arabic included (PDF-5, LANG-5)', () async {
      for (final code in appLanguages.keys) {
        final bytes = await build(dataWith(manyEntries(10)), code: code);
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-', reason: code);
        expect(bytes.length, greaterThan(5000), reason: code);
      }
    });

    test('US Letter is laid out as readily as A4 (PDF-5)', () async {
      final data = dataWith(manyEntries(30));
      final a4 = await build(data);
      final letter = await build(data, pageFormat: PdfPageFormat.letter);

      expect(String.fromCharCodes(letter.take(5)), '%PDF-');
      // Different paper, so not byte-identical, but both hold the report.
      expect((letter.length - a4.length).abs(), lessThan(a4.length));
    });
  });

  group('report PDF privacy options (PDF-3)', () {
    test('leaving the transaction list out makes a shorter report', () async {
      final entries = manyEntries(60);
      final full = await build(dataWith(entries));
      final summaryOnly = await build(
        dataWith(entries, options: const ReportOptions(transactions: false)),
        options: const ReportOptions(transactions: false),
      );

      expect(summaryOnly.length, lessThan(full.length));
      expect(String.fromCharCodes(summaryOnly.take(5)), '%PDF-');
    });

    test('leaving titles and notes out makes a shorter one too', () async {
      final entries = manyEntries(60);
      final full = await build(dataWith(entries));
      final withoutDetails = await build(
        dataWith(entries),
        options: const ReportOptions(titlesAndNotes: false),
      );

      expect(withoutDetails.length, lessThan(full.length));
    });

    test('turning the transaction list off also hides upcoming titles, notes '
        'and accounts (PDF-2)', () async {
      const options = ReportOptions(transactions: false);
      final data = buildReport(
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 30),
        today: today,
        transactions: [
          testTx(
            'future',
            TransactionType.expense,
            40,
            DateTime(2026, 9, 25), // after `today` -> goes to `upcoming`.
            title: 'SecretFutureTitle',
            note: 'PrivateNote',
            accountId: 'savings',
          ),
        ],
        transfers: const [],
        accounts: [
          testAccount('cash', opening: 100),
          testAccount('savings', opening: 200),
        ],
        options: options,
      );
      expect(data.upcoming, isNotEmpty);

      final bytes = await buildReportPdf(
        data: data,
        options: options,
        labels: await labelsFor('en'),
        fonts: await ReportFonts.forLocale(const Locale('en')),
        createdAt: createdAt,
        pageFormat: PdfPageFormat.a4,
        compress: false,
      );

      final text = pdfText(bytes);
      expect(text, isNot(contains('SecretFutureTitle')));
      expect(text, isNot(contains('PrivateNote')));
      expect(text, isNot(contains('savings')));
    });
  });

  group('report PDF progress and cancelling (PDF-6)', () {
    test('progress climbs to the end', () async {
      final seen = <double>[];
      await build(dataWith(manyEntries(40)), onProgress: seen.add);

      expect(seen, isNotEmpty);
      expect(seen.first, greaterThan(0));
      expect(seen.last, closeTo(1, 0.001));
      // Never goes backwards.
      for (var i = 1; i < seen.length; i++) {
        expect(seen[i], greaterThanOrEqualTo(seen[i - 1]));
      }
    });

    test('cancelling stops the build and produces nothing', () async {
      var calls = 0;
      await expectLater(
        build(dataWith(manyEntries(60)), isCancelled: () => ++calls > 2),
        throwsA(isA<ReportCancelled>()),
      );
    });

    test('a year of thousands of entries builds in good time', () async {
      // PDF-6: the report has to cope with a whole year, not just a month.
      final data = buildReport(
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 12, 31),
        today: DateTime(2026, 12, 31),
        transactions: [
          for (var i = 0; i < 3000; i++)
            testTx(
              'tx-$i',
              i.isEven ? TransactionType.expense : TransactionType.income,
              (i % 90) + 1,
              DateTime(2026, 1, 1 + (i % 360)),
              title: 'Entry $i',
            ),
        ],
        transfers: const [],
        accounts: [testAccount('cash', opening: 100)],
      );
      expect(data.entryCount, 3000);

      final started = DateTime.now();
      final bytes = await build(data);
      final took = DateTime.now().difference(started);

      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(
        took.inSeconds,
        lessThan(60),
        reason: 'a year took ${took.inSeconds}s to lay out',
      );
    });
  });
}
