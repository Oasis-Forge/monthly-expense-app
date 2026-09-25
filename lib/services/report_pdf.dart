import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/widgets.dart' show Locale;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../l10n/app_localizations.dart';
import '../l10n/languages.dart';
import '../models/money.dart';
import '../models/report.dart';
import '../models/transaction.dart';
import 'report_fonts.dart';

/// The app's own two colours on the report's white page (CUR-5): the same
/// pair the screens use, so income and expense read alike in both places.
const _incomeInk = PdfColor.fromInt(incomeInkLight);
const _expenseInk = PdfColor.fromInt(expenseInkLight);

/// Raised when the caller cancelled the build (PDF-6).
class ReportCancelled implements Exception {
  const ReportCancelled();

  @override
  String toString() => 'The report was cancelled';
}

/// Everything the layout needs that isn't in [ReportData]: the strings, the
/// formats, and the names behind the IDs (PDF-5, LANG-3).
class ReportLabels {
  const ReportLabels({
    required this.l10n,
    required this.locale,
    required this.currency,
    required this.categoryName,
    required this.accountName,
    this.accountFilterName,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final NumberFormat currency;
  final String Function(String categoryId) categoryName;
  final String Function(String accountId) accountName;

  /// The one account the report covers, or null for all of them (PDF-1).
  final String? accountFilterName;

  String get localeName => l10n.localeName;
  String money(Money amount) => currency.money(amount);
  String signed(Money amount, {required bool isIncome}) =>
      currency.signedMoney(amount, isIncome: isIncome);
  String day(DateTime date) => DateFormat.MMMd(localeName).format(date);
  String fullDay(DateTime date) => DateFormat.yMMMd(localeName).format(date);
  String month(DateTime date) => DateFormat.yMMM(localeName).format(date);
  String dateTime(DateTime moment) =>
      DateFormat.yMMMd(localeName).add_jm().format(moment);
}

/// Lays [data] out as a PDF (PDF-2, PDF-5).
///
/// [onProgress] is called with 0 to 1 as the pages come together, and
/// [isCancelled] is checked alongside it; returning true throws
/// [ReportCancelled] and nothing is produced (PDF-6). The whole thing runs on
/// the device, reading nothing from the network (PDF-4).
Future<Uint8List> buildReportPdf({
  required ReportData data,
  required ReportOptions options,
  required ReportLabels labels,
  required ReportFonts fonts,
  required DateTime createdAt,
  PdfPageFormat pageFormat = PdfPageFormat.a4,
  void Function(double progress)? onProgress,
  bool Function()? isCancelled,
  // Tests turn compression off so they can read the text back out and check
  // it is the right way round; the app always leaves it on.
  bool compress = true,
}) async {
  // The report dates itself in the app's language, so it needs the locale's
  // date symbols whether or not a widget delegate has already loaded them
  // (LANG-3).
  await initializeDateFormatting(labels.localeName);

  final rtl = rightToLeftLanguages.contains(labels.locale.languageCode);
  final l10n = labels.l10n;

  var done = 0;
  final total = data.entryCount + 1;
  Future<void> step([int by = 1]) async {
    if (isCancelled?.call() ?? false) throw const ReportCancelled();
    done += by;
    onProgress?.call((done / total).clamp(0.0, 1.0));
    // Let the frame finish, so a long report never freezes the app (PDF-6).
    await Future<void>.delayed(Duration.zero);
  }

  final document = pw.Document(theme: fonts.theme, compress: compress);
  final content = <pw.Widget>[
    _summary(data, labels),
    if (data.expenseCategories.isNotEmpty)
      ..._categories(
        data.expenseCategories,
        labels,
        l10n.reportSpendingHeader,
        withBudget: true,
      ),
    if (data.incomeCategories.isNotEmpty)
      ..._categories(
        data.incomeCategories,
        labels,
        l10n.reportEarningHeader,
        withBudget: false,
      ),
    if (data.trend.length > 1) ..._trend(data, labels),
  ];
  await step();

  if (options.transactions && data.byDay.isNotEmpty) {
    content.add(_heading(l10n.reportEntriesHeader));
    for (final MapEntry(key: day, value: entries) in data.byDay.entries) {
      content.add(_dayTable(day, entries, options, labels));
      await step(entries.length);
    }
  }

  // Off follows the same rule as the day-by-day list above (PDF-2, PDF-3):
  // this is still the transaction list, just for entries dated ahead.
  if (options.transactions && data.upcoming.isNotEmpty) {
    content
      ..add(_heading(l10n.reportUpcomingHeader))
      ..add(_run(l10n.reportUpcomingNote, style: _muted))
      ..add(pw.SizedBox(height: 4))
      ..add(_dayTable(null, data.upcoming, options, labels));
    await step(data.upcoming.length);
  }

  if (data.isEmpty) {
    content.add(_run(l10n.reportEmpty, style: _muted));
  }

  // The page-by-page layout below (MultiPage.generate, measuring and
  // positioning every table row) runs synchronously once addPage starts it,
  // and [step] can't check in during it: a cancel asked for right at the end
  // still has to land somewhere before it, and this is the last chance
  // before the layout itself starts (PDF-6). To keep the UI isolate free to
  // handle that cancel tap (and redraw at all) while a big report lays out,
  // the layout and the write that follows both run on a fresh isolate; only
  // the finished bytes cross back. Document.write (unlike Document.save)
  // does no isolate hop of its own, which is what the pdf package's own docs
  // ask of a caller that is already isolating itself.
  if (isCancelled?.call() ?? false) throw const ReportCancelled();

  // [labels] itself carries the category and account name lookups
  // (ReportLabels.categoryName/accountName), which in the app close over
  // the live TransactionProvider (report_screen.dart) to look names up by
  // id, and [onProgress]/[isCancelled] close over the caller's own
  // ValueNotifier and local state. Content above already called through
  // the name lookups to plain strings, but none of this can be allowed
  // anywhere near the isolate boundary below: closures declared in the
  // same function body as an Isolate.run call can end up sharing one
  // compiler-generated context, so even a closure that only reads
  // [headerWidget] can drag every other local in [buildReportPdf] —
  // [onProgress] included — along with it. _layoutAndWrite is a top-level
  // function for exactly this reason: its own body is the only scope the
  // isolate closure it creates can reach into, and that scope holds
  // nothing but its own plain parameters.
  final headerWidget = _header(data, labels, createdAt, options);
  final pageOfText = l10n.reportPageOf;
  final bytes = await _layoutAndWrite(
    document: document,
    content: content,
    pageFormat: pageFormat,
    rtl: rtl,
    headerWidget: headerWidget,
    pageOfText: pageOfText,
  );

  if (isCancelled?.call() ?? false) throw const ReportCancelled();
  return bytes;
}

/// Lays [content] out as pages of [document] and writes it out, on a fresh
/// isolate (PDF-6). Top-level, and taking only plain values and already-built
/// widgets: see the note above this function's one call site.
Future<Uint8List> _layoutAndWrite({
  required pw.Document document,
  required List<pw.Widget> content,
  required PdfPageFormat pageFormat,
  required bool rtl,
  required pw.Widget headerWidget,
  required String Function(int pageNumber, int pagesCount) pageOfText,
}) {
  return Isolate.run(() async {
    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        margin: const pw.EdgeInsets.all(32),
        header: (context) =>
            context.pageNumber == 1 ? headerWidget : pw.SizedBox(),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 8),
          child: _run(
            pageOfText(context.pageNumber, context.pagesCount),
            style: _muted,
          ),
        ),
        build: (context) => content,
      ),
    );
    final stream = PdfStream();
    await document.write(stream, enableEventLoopBalancing: true);
    return stream.output();
  });
}

/// Left-to-right isolate and its matching pop (U+2066, U+2069): the marks
/// [SettingsProvider.currencyFormat]'s pattern wraps round a signed figure
/// so bidi cannot part it from its sign (LANG-5).
const _lri = '\u2066';
const _pdi = '\u2069';

/// A run of text laid out in the direction its own content calls for.
///
/// An Arabic report is a right-to-left page, and the pdf package puts every
/// span on such a page through a bidi pass that leaves Latin runs backwards —
/// v1.3.0 printed the app's own name as "sesnepxE ylhtnoM". Anything with no
/// right-to-left letter in it is drawn left to right instead, which skips
/// that pass: the app name, the currency, an amount, and any category,
/// account or title the user typed in Latin (PDF-5, LANG-5).
///
/// A formatted amount is different: it can carry both a right-to-left symbol
/// and a signed figure that must stay a single left-to-right piece, and this
/// package's bidi pass has no notion of the isolate marks that keep the two
/// apart (unlike the screens' real bidi engine) — worse, it still tries to
/// draw the marks themselves as glyphs. Only a right-to-left currency
/// pattern ever adds them, so their presence alone says this run needs
/// reordering rather than the single-direction guess below: whatever sits
/// outside the isolate (almost always just the symbol) moves in front of it,
/// since that is where a real right-to-left line would carry it, and the
/// whole amount is then drawn as one forced-left-to-right piece so this
/// package's own bidi pass never touches it again (LANG-5, CUR-5, PDF-5,
/// Decision 54).
pw.Widget _run(String text, {pw.TextStyle? style}) {
  final lriAt = text.indexOf(_lri);
  final pdiAt = text.indexOf(_pdi, lriAt + 1);
  if (lriAt == -1 || pdiAt == -1) {
    final plain = stripBidiMarks(text);
    return pw.Directionality(
      textDirection: _directionOf(plain),
      child: pw.Text(plain, style: style),
    );
  }

  final before = stripBidiMarks(text.substring(0, lriAt));
  final isolate = stripBidiMarks(text.substring(lriAt + 1, pdiAt));
  final after = stripBidiMarks(text.substring(pdiAt + 1));
  // Everything outside the isolate keeps its own direction rather than
  // being flattened into one forced-left-to-right string: that skipped this
  // package's arabic.convert pass (it only shapes and reorders a run whose
  // own textDirection is rtl), and glued unrelated text straight onto the
  // isolated figures with no boundary between them — a currency symbol
  // read as mirrored letters, or a percentage's digits run into a
  // budget's. Visual left-to-right order is after, isolate, before (the
  // isolate's own figures stay forced left-to-right); a gap replaces
  // whatever whitespace the source had between two pieces (LANG-5, CUR-5,
  // PDF-5, Decision 54).
  final gap = pw.SizedBox(width: (style?.fontSize ?? 10) * 0.3);
  final afterTrimmed = after.trim();
  final beforeTrimmed = before.trim();
  return pw.Directionality(
    textDirection: pw.TextDirection.ltr,
    child: pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        if (afterTrimmed.isNotEmpty) ...[
          pw.Directionality(
            textDirection: _directionOf(afterTrimmed),
            child: pw.Text(afterTrimmed, style: style),
          ),
          if (after != afterTrimmed) gap,
        ],
        pw.Text(isolate, style: style, textDirection: pw.TextDirection.ltr),
        if (beforeTrimmed.isNotEmpty) ...[
          if (before != beforeTrimmed) gap,
          pw.Directionality(
            textDirection: _directionOf(beforeTrimmed),
            child: pw.Text(beforeTrimmed, style: style),
          ),
        ],
      ],
    ),
  );
}

/// Drops the invisible marks that steer bidirectional text.
///
/// Arabic number formats carry them, and a PDF font has no notion of an
/// invisible character: it draws whatever glyph the mark maps to, leaving a
/// speck in front of every amount. The direction of each run is set here
/// anyway, so the marks have nothing left to say (LANG-3).
String stripBidiMarks(String text) =>
    String.fromCharCodes(text.runes.where((rune) => !_isBidiMark(rune)));

bool _isBidiMark(int rune) =>
    rune == 0x200E || // left-to-right mark
    rune == 0x200F || // right-to-left mark
    rune == 0x061C || // Arabic letter mark
    (rune >= 0x202A && rune <= 0x202E) || // embeddings and overrides
    (rune >= 0x2066 && rune <= 0x2069); // isolates

pw.TextDirection _directionOf(String text) =>
    text.runes.any(_isRtlRune) ? pw.TextDirection.rtl : pw.TextDirection.ltr;

/// Hebrew, Arabic, Syriac and Thaana, and the Arabic presentation forms.
bool _isRtlRune(int rune) =>
    (rune >= 0x0590 && rune <= 0x08FF) ||
    (rune >= 0xFB1D && rune <= 0xFDFF) ||
    (rune >= 0xFE70 && rune <= 0xFEFF);

const _muted = pw.TextStyle(fontSize: 9, color: PdfColors.grey700);
const _headingStyle = pw.TextStyle(
  fontSize: 13,
  fontWeight: pw.FontWeight.bold,
);

// Cells are passed as widgets rather than strings so each picks its own
// direction, which means they carry their own style too.
const _tableCellStyle = pw.TextStyle(fontSize: 10);
const _tableHeaderStyle = pw.TextStyle(
  fontSize: 10,
  fontWeight: pw.FontWeight.bold,
);
const _entryCellStyle = pw.TextStyle(fontSize: 9);
const _entryHeaderStyle = pw.TextStyle(
  fontSize: 9,
  fontWeight: pw.FontWeight.bold,
);

pw.Widget _heading(String text) => pw.Container(
  margin: const pw.EdgeInsets.only(top: 16, bottom: 6),
  child: _run(text, style: _headingStyle),
);

/// The app's name, what the report covers, the currency, and when it was
/// made. No watermark and nothing promotional (PDF-3).
pw.Widget _header(
  ReportData data,
  ReportLabels labels,
  DateTime createdAt,
  ReportOptions options,
) {
  final l10n = labels.l10n;
  final range = data.from == data.to
      ? labels.fullDay(data.from)
      : l10n.reportRange(labels.fullDay(data.from), labels.fullDay(data.to));
  final searchInfo = data.searchInfo;
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 12),
    padding: const pw.EdgeInsets.only(bottom: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _run(
          l10n.appTitle,
          style: const pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        _run(range, style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 2),
        // Each part on its own, so a Latin currency name next to an Arabic
        // date doesn't drag one of them the wrong way round.
        pw.Wrap(
          spacing: 8,
          children: [
            for (final part in [
              if (labels.accountFilterName != null) labels.accountFilterName!,
              labels.currency.currencyName ?? '',
              l10n.reportCreated(labels.dateTime(createdAt)),
            ].where((part) => part.isNotEmpty))
              _run(part, style: _muted),
          ],
        ),
        // A shared PDF has to say it is narrowed on its own, since nothing
        // else on the page does (PDF-1, ACC-6): a filtered figure that reads
        // like the whole of the money is worse than no filter at all.
        if (searchInfo != null) ...[
          pw.SizedBox(height: 4),
          _run(
            l10n.reportNarrowedTo(
              _searchDescription(searchInfo, l10n, options),
            ),
            style: const pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ],
    ),
  );
}

/// The query, type, and category a report was narrowed to, joined for the
/// header line (PDF-1). The query itself is left out when titles and notes
/// are off (PDF-3): it may be private text of the user's own, so a report
/// that already hides titles and notes must not print it back in the header
/// (review-pdf-query-titles-off). At least one part is always present, since
/// [ReportSearchInfo] is only attached when something narrowed the report:
/// the type and category still show (neither is titles-and-notes text), and
/// a query-only search falls back to naming the search itself.
String _searchDescription(
  ReportSearchInfo info,
  AppLocalizations l10n,
  ReportOptions options,
) {
  final parts = [
    if (info.query.isNotEmpty && options.titlesAndNotes) '"${info.query}"',
    if (info.type != null)
      info.type == TransactionType.income
          ? l10n.incomeLabel
          : l10n.expenseLabel,
    if (info.categoryName != null) info.categoryName!,
  ];
  return parts.isEmpty ? l10n.searchTooltip : parts.join(' · ');
}

/// Income, expense, net, and the balances either side of the range — or, for
/// a report narrowed to a search, those three figures labelled as matching it
/// and no balances at all, since a search's net doesn't move a balance that
/// counts every transaction (PDF-1, PDF-2, BAL-3, ACC-6).
pw.Widget _summary(ReportData data, ReportLabels labels) {
  final l10n = labels.l10n;
  final matched = data.searchInfo != null;
  pw.Widget cell(String label, Money amount, {bool strong = false}) =>
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _run(label, style: _muted),
            pw.SizedBox(height: 2),
            // The sign and figures read left to right in every language
            // (LANG-3, LANG-5); the currency symbol goes where the
            // language puts it. _run gives amounts both, splitting on the
            // isolate marks currencyFormat leaves in them.
            _run(
              labels.money(amount),
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      );

  return pw.Column(
    children: [
      pw.Row(
        children: [
          cell(
            matched ? l10n.reportMatchingIncome : l10n.incomeLabel,
            data.income,
          ),
          cell(
            matched ? l10n.reportMatchingExpense : l10n.expenseLabel,
            data.expense,
          ),
          cell(
            matched ? l10n.reportMatchingNet : l10n.reportNet,
            data.net,
            strong: true,
          ),
        ],
      ),
      if (!matched) ...[
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            cell(l10n.reportOpeningBalance, data.openingBalance),
            cell(l10n.reportClosingBalance, data.closingBalance, strong: true),
            pw.Expanded(child: pw.SizedBox()),
          ],
        ),
      ],
    ],
  );
}

/// Spending or income by category, with each share and, for spending, how
/// much of its budget went (PDF-2, BUD-2).
List<pw.Widget> _categories(
  List<ReportCategoryLine> lines,
  ReportLabels labels,
  String title, {
  required bool withBudget,
}) {
  final l10n = labels.l10n;
  final percent = NumberFormat.percentPattern(labels.localeName);
  final showBudget = withBudget && lines.any((line) => line.budget != null);
  return [
    _heading(title),
    pw.TableHelper.fromTextArray(
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      // PDF-5: the header repeats when a table runs onto the next page.
      headerCount: 1,
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      headers: [
        for (final header in [
          l10n.categoryLabel,
          l10n.reportAmountColumn,
          l10n.reportShareColumn,
          if (showBudget) l10n.reportBudgetColumn,
        ])
          _run(header, style: _tableHeaderStyle),
      ],
      data: [
        for (final line in lines)
          [
            for (final cell in [
              labels.categoryName(line.categoryId),
              labels.money(line.amount),
              percent.format(line.share),
              if (showBudget)
                line.budget == null
                    ? '—'
                    : l10n.reportBudgetOf(
                        percent.format(line.budgetUsed ?? 0),
                        labels.money(line.budget!),
                      ),
            ])
              _run(cell, style: _tableCellStyle),
          ],
      ],
    ),
  ];
}

/// Income against expense over the range, as a bar per point (PDF-2, INS-2).
List<pw.Widget> _trend(ReportData data, ReportLabels labels) {
  final peak = data.trend
      .map((point) => [point.income, point.expense])
      .expand((amounts) => amounts)
      .fold(
        0,
        (peak, amount) => amount.thousandths > peak ? amount.thousandths : peak,
      );

  pw.Widget bar(int thousandths, PdfColor colour) => pw.Container(
    width: 6,
    height: peak == 0 ? 0 : 40 * thousandths / peak,
    color: colour,
  );

  return [
    _heading(labels.l10n.reportTrendHeader),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        for (final point in data.trend)
          pw.Expanded(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    bar(point.income.thousandths, _incomeInk),
                    pw.SizedBox(width: 1),
                    bar(point.expense.thousandths, _expenseInk),
                  ],
                ),
                pw.SizedBox(height: 2),
                _run(
                  point.label == ReportTrendGrain.period
                      ? labels.month(point.start)
                      : '${point.start.day}',
                  style: const pw.TextStyle(fontSize: 6),
                ),
              ],
            ),
          ),
      ],
    ),
    pw.SizedBox(height: 4),
    pw.Row(
      children: [
        _key(_incomeInk, labels.l10n.incomeLabel),
        pw.SizedBox(width: 12),
        _key(_expenseInk, labels.l10n.expenseLabel),
      ],
    ),
  ];
}

pw.Widget _key(PdfColor colour, String label) => pw.Row(
  children: [
    pw.Container(width: 6, height: 6, color: colour),
    pw.SizedBox(width: 3),
    _run(label, style: _muted),
  ],
);

/// One day's entries, or the whole upcoming list when [day] is null. Each row
/// carries only what the options allow (PDF-3), and transfers are marked
/// rather than counted (PDF-2).
pw.Widget _dayTable(
  DateTime? day,
  List<ReportEntry> entries,
  ReportOptions options,
  ReportLabels labels,
) {
  final l10n = labels.l10n;
  final showDetails = options.titlesAndNotes;
  final showAccount = options.accountNames;

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (day != null)
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 8, bottom: 2),
          child: _run(
            labels.fullDay(day),
            style: const pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      pw.TableHelper.fromTextArray(
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        headerCount: 1,
        cellAlignment: pw.Alignment.centerLeft,
        cellAlignments: {3: pw.Alignment.centerRight},
        headers: [
          for (final header in [
            if (day == null) l10n.dateLabel,
            l10n.categoryLabel,
            if (showDetails) l10n.reportDetailsColumn,
            if (showAccount) l10n.accountLabel,
            l10n.reportAmountColumn,
          ])
            _run(header, style: _entryHeaderStyle),
        ],
        data: [
          for (final entry in entries)
            [
              for (final cell in [
                if (day == null) labels.day(entry.date),
                _categoryOf(entry, labels),
                if (showDetails) _detailsOf(entry),
                if (showAccount) _accountOf(entry, labels),
                _amountOf(entry, labels),
              ])
                _run(cell, style: _entryCellStyle),
            ],
        ],
      ),
    ],
  );
}

String _categoryOf(ReportEntry entry, ReportLabels labels) => entry.isTransfer
    ? labels.l10n.transferLabel
    : labels.categoryName(entry.transaction!.categoryId);

String _detailsOf(ReportEntry entry) {
  if (entry.isTransfer) return entry.transfer!.note ?? '';
  final tx = entry.transaction!;
  return [
    if (tx.title != null && tx.title!.isNotEmpty) tx.title!,
    if (tx.note != null && tx.note!.isNotEmpty) tx.note!,
  ].join(' — ');
}

String _accountOf(ReportEntry entry, ReportLabels labels) {
  final transfer = entry.transfer;
  if (transfer != null) {
    return labels.l10n.transferRoute(
      labels.accountName(transfer.fromAccountId),
      labels.accountName(transfer.toAccountId),
    );
  }
  return labels.accountName(entry.transaction!.accountId);
}

String _amountOf(ReportEntry entry, ReportLabels labels) {
  if (entry.isTransfer) return labels.money(entry.amount);
  // Signed the way every screen signs (CUR-5), rather than by pasting a sign
  // in front of the figures, which in Arabic lands outside the isolate the
  // pattern draws and reads as the opposite side of the amount.
  return labels.signed(
    entry.amount,
    isIncome: entry.transaction!.type == TransactionType.income,
  );
}
