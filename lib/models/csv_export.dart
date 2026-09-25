import 'transaction.dart';
import 'transfer.dart';

/// The CSV columns, in order. Names stay in English so spreadsheets and
/// scripts can rely on them.
const csvColumns = [
  'date',
  'type',
  'amount',
  'currency',
  'category',
  'account',
  'to_account',
  'title',
  'note',
];

/// A CSV of [transactions] and [transfers] for spreadsheets (BAK-5): oldest
/// first, ISO dates, plain decimal amounts, and a byte order mark so
/// spreadsheet apps read it as UTF-8.
String buildCsv({
  required List<ExpenseTransaction> transactions,
  List<Transfer> transfers = const [],
  required String currencyCode,
  required String Function(String categoryId) categoryName,
  required String Function(String accountId) accountName,
}) {
  final rows = <(DateTime, List<String>)>[
    for (final tx in transactions)
      (
        tx.date,
        [
          isoDate(tx.date),
          tx.type.name,
          tx.amount.toInputString(),
          currencyCode,
          _text(categoryName(tx.categoryId)),
          _text(accountName(tx.accountId)),
          '',
          _text(tx.title),
          _text(tx.note),
        ],
      ),
    for (final transfer in transfers)
      (
        transfer.date,
        [
          isoDate(transfer.date),
          'transfer',
          transfer.amount.toInputString(),
          currencyCode,
          '',
          _text(accountName(transfer.fromAccountId)),
          _text(accountName(transfer.toAccountId)),
          '',
          _text(transfer.note),
        ],
      ),
  ]..sort((a, b) => a.$1.compareTo(b.$1));

  final csv = StringBuffer('\uFEFF')
    ..write(csvColumns.join(','))
    ..write('\r\n');
  for (final (_, cells) in rows) {
    csv
      ..write(cells.map(_escape).join(','))
      ..write('\r\n');
  }
  return csv.toString();
}

String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

final _formulaStart = RegExp(r"^([=+\-@\t\r]|'[=+\-@])");

/// User text. Spreadsheets run a cell that starts with `=`, `+`, `-`, or `@`
/// as a formula, so such text gets a leading apostrophe. A value that
/// already starts with the user's own apostrophe followed by one of those
/// (`'-5 refund`) is guarded the same way, or import's matching strip
/// (csv_import.dart's `_stripFormulaGuard`) would remove that apostrophe
/// as though it were the guard (rules-11-13-20-21#11).
String _text(String? value) {
  if (value == null) return '';
  return _formulaStart.hasMatch(value) ? "'$value" : value;
}

final _needsQuotes = RegExp('[",\r\n]');

String _escape(String cell) =>
    _needsQuotes.hasMatch(cell) ? '"${cell.replaceAll('"', '""')}"' : cell;
