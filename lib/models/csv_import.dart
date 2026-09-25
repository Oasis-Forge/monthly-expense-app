import 'csv_export.dart' show csvColumns;
import 'money.dart';
import 'transaction_filter.dart' show foldForSearch;

/// Reading a CSV written by some other app (IMP-1–IMP-8).
///
/// Everything here is a pure function over text: splitting the file into
/// rows, working out which column is which, and reading a date, an amount,
/// and a type out of a row. Nothing decides to write anything — that is the
/// provider's job, after the user has seen the preview (IMP-5).

/// The one thing a CSV must have twice over to be worth reading (IMP-4).
enum ImportField {
  date,
  amount,
  type,
  category,
  account,
  toAccount,
  title,
  note,
}

/// A CSV split into its header and its rows, all cells as written.
class CsvTable {
  const CsvTable({required this.header, required this.rows});

  final List<String> header;
  final List<List<String>> rows;

  bool get isEmpty => header.isEmpty;
}

/// Splits [text] into a header row and the rows under it.
///
/// It copes with what spreadsheets actually produce: a byte order mark, CRLF
/// line endings, quoted cells holding commas or newlines, doubled quotes
/// inside them, and a semicolon or tab where a locale uses those instead of
/// a comma. Ragged rows are kept as they are; the caller decides what a
/// missing cell means.
CsvTable parseCsv(String text) {
  final body = text.startsWith('﻿') ? text.substring(1) : text;
  if (body.trim().isEmpty) return const CsvTable(header: [], rows: []);

  final rows = _split(body, _delimiterOf(body));
  if (rows.isEmpty) return const CsvTable(header: [], rows: []);
  return CsvTable(header: rows.first, rows: rows.skip(1).toList());
}

/// The separator the file uses: whichever of `,`, `;` or a tab appears most
/// on the header line. Comma wins a tie, being the usual one.
String _delimiterOf(String body) {
  final firstLine = body.split(RegExp('\r\n|\r|\n')).first;
  var best = ',';
  var bestCount = _countOutsideQuotes(firstLine, ',');
  for (final candidate in [';', '\t']) {
    final count = _countOutsideQuotes(firstLine, candidate);
    if (count > bestCount) {
      best = candidate;
      bestCount = count;
    }
  }
  return best;
}

int _countOutsideQuotes(String line, String character) {
  var count = 0;
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      quoted = !quoted;
    } else if (!quoted && char == character) {
      count++;
    }
  }
  return count;
}

List<List<String>> _split(String body, String delimiter) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  var sawCell = false;

  void endCell() {
    row.add(cell.toString().trim());
    cell.clear();
    sawCell = true;
  }

  void endRow() {
    endCell();
    // A line of nothing but separators is not a row.
    if (row.any((value) => value.isNotEmpty)) rows.add(row);
    row = <String>[];
    sawCell = false;
  }

  for (var i = 0; i < body.length; i++) {
    final char = body[i];
    if (quoted) {
      if (char != '"') {
        cell.write(char);
      } else if (i + 1 < body.length && body[i + 1] == '"') {
        cell.write('"');
        i++;
      } else {
        quoted = false;
      }
      continue;
    }
    switch (char) {
      case '"':
        quoted = true;
      case '\r':
        // Swallow it; the \n that follows ends the row.
        if (i + 1 >= body.length || body[i + 1] != '\n') endRow();
      case '\n':
        endRow();
      default:
        if (char == delimiter) {
          endCell();
        } else {
          cell.write(char);
        }
    }
  }
  if (cell.isNotEmpty || sawCell) endRow();
  return rows;
}

/// The header names each field answers to, folded for comparison. Our own
/// export's names (BAK-5) come first in each list, then the usual English
/// alternatives, then the same word in the app's other twenty languages —
/// whoever is switching may well have been using their own language.
const _aliases = <ImportField, List<String>>{
  ImportField.date: [
    'date',
    'transaction date',
    'day',
    'datetime',
    'date time',
    'posted',
    'posting date',
    'value date',
    'value dt',
    'dt',
    'when',
    'tarih',
    'التاريخ',
    'تاريخ',
    'fecha',
    'datum',
    'তারিখ',
    '日期',
    'ημερομηνία',
    'दिनांक',
    'tanggal',
    'data',
    '日付',
    '날짜',
    'дата',
    'วันที่',
    'تاریخ',
    'ngày',
  ],
  ImportField.amount: [
    'amount',
    'value',
    'sum',
    'total',
    'price',
    'money',
    'debit credit',
    'amount value',
    'tutar',
    'miktar',
    'المبلغ',
    'مبلغ',
    'montant',
    'importe',
    'cantidad',
    'betrag',
    'পরিমাণ',
    '金额',
    'bedrag',
    'ποσό',
    'राशि',
    'jumlah',
    'nominal',
    'importo',
    '金額',
    '금액',
    'kwota',
    'valor',
    'сумма',
    'จำนวนเงิน',
    'رقم',
    'số tiền',
  ],
  ImportField.type: [
    'type',
    'transaction type',
    'kind',
    'income expense',
    'direction',
    'in out',
    'debit credit type',
    'tur',
    'tip',
    'islem turu',
    'النوع',
    'نوع',
    'tipo',
    'typ',
    'art',
    'ধরন',
    '类型',
    'soort',
    'τύπος',
    'प्रकार',
    'jenis',
    '種類',
    '유형',
    'rodzaj',
    'тип',
    'ประเภท',
    'loại',
  ],
  ImportField.category: [
    'category',
    'category name',
    'categories',
    'group',
    'tag',
    'subject',
    'kategori',
    'الفئة',
    'فئة',
    'التصنيف',
    'تصنيف',
    'categorie',
    'categoria',
    'kategorie',
    'বিভাগ',
    '分类',
    'κατηγορία',
    'श्रेणी',
    'カテゴリ',
    '카테고리',
    'категория',
    'หมวดหมู่',
    'قسم',
    'danh mục',
  ],
  ImportField.account: [
    'account',
    'account name',
    'from account',
    'source',
    'source account',
    'wallet',
    'wallet name',
    'payment method',
    'paid with',
    'hesap',
    'الحساب',
    'حساب',
    'compte',
    'cuenta',
    'konto',
    'হিসাব',
    '账户',
    'rekening',
    'λογαριασμός',
    'खाता',
    'akun',
    'conto',
    '口座',
    '계좌',
    'rachunek',
    'conta',
    'счет',
    'счёт',
    'บัญชี',
    'کھاتہ',
    'tài khoản',
  ],
  ImportField.toAccount: [
    'to account',
    'destination',
    'destination account',
    'target account',
    'transfer to',
    'hedef hesap',
    'الى الحساب',
    'الحساب الوجهة',
    'compte destinataire',
    'cuenta destino',
    'zielkonto',
    '转入账户',
    'tegenrekening',
    'λογαριασμός προορισμού',
    'rekening tujuan',
    'conto destinazione',
    '振込先口座',
    '입금 계좌',
    'konto docelowe',
    'conta destino',
    'счет получателя',
    'บัญชีปลายทาง',
    'tài khoản nhận',
  ],
  ImportField.title: [
    'title',
    'description',
    'name',
    'payee',
    'merchant',
    'details',
    'reference',
    'memo title',
    'baslik',
    'aciklama',
    'العنوان',
    'عنوان',
    'الوصف',
    'titre',
    'titulo',
    'descripcion',
    'titel',
    'beschreibung',
    'বিবরণ',
    '摘要',
    'omschrijving',
    'τίτλος',
    'περιγραφή',
    'शीर्षक',
    'विवरण',
    'judul',
    'keterangan',
    'titolo',
    'descrizione',
    'タイトル',
    '제목',
    '적요',
    'tytul',
    'opis',
    'descricao',
    'название',
    'описание',
    'ชื่อเรื่อง',
    'รายละเอียด',
    'tiêu đề',
    'mô tả',
  ],
  ImportField.note: [
    'note',
    'notes',
    'comment',
    'comments',
    'memo',
    'remark',
    'notlar',
    'ملاحظة',
    'ملاحظات',
    'nota',
    'notas',
    'notiz',
    'bemerkung',
    'মন্তব্য',
    '备注',
    'notitie',
    'σημείωση',
    'टिप्पणी',
    'catatan',
    'メモ',
    '備考',
    '메모',
    '비고',
    'notatka',
    'uwagi',
    'observacao',
    'заметка',
    'примечание',
    'บันทึก',
    'หมายเหตุ',
    'تبصرہ',
    'نوٹ',
    'ghi chú',
  ],
};

/// Which column holds which field, by header name (IMP-3).
///
/// Names are compared folded, so case, accents, and the punctuation between
/// words don't matter ("To Account", "to_account" and "TO-ACCOUNT" all
/// match). A field with no confident match is simply absent; nothing is
/// guessed from the data.
Map<ImportField, int> matchColumns(List<String> header) {
  final folded = [for (final name in header) _foldHeader(name)];
  final matched = <ImportField, int>{};
  final taken = <int>{};

  // Exact names first, so a file with both "account" and "to account" can't
  // have the second one swallowed by a loose match on the first.
  for (final exact in [true, false]) {
    for (final entry in _aliases.entries) {
      if (matched.containsKey(entry.key)) continue;
      for (var column = 0; column < folded.length; column++) {
        if (taken.contains(column) || folded[column].isEmpty) continue;
        final name = folded[column];
        final words = name.split(' ');
        final hit = entry.value.any((alias) {
          if (exact) return name == alias;
          // The loose pass matches a whole word of the header, never a
          // substring buried inside another word ("Counterparty" must not
          // match the type alias "art" just because "party" contains it).
          // Latin aliases of three letters or fewer ("art", "tag", "day"...)
          // are common enough as fragments of unrelated words that they are
          // trusted only on an exact whole-header match, never loosely. A
          // short CJK or Hangul alias ("金额", "날짜") is not a fragment the
          // same way a short Latin one is — two characters there is already
          // a whole word — so the limit does not apply to it.
          final short = alias.length <= 3 && _isLatin(alias);
          if (short) return false;
          if (_wholeWordMatch(words, alias)) return true;
          // A bank's own compound word ("Buchungsdatum", "transactiondate")
          // is one folded word with no space for a whole-word match to find,
          // but it still ends with the alias ("datum", "date"): trusted the
          // same as a whole word, since a fragment this long ("date" or
          // longer) is not the kind of coincidental substring the whole-word
          // rule above guards against ("art" inside "party").
          if (alias.length >= 4 && _isLatin(alias) && !alias.contains(' ')) {
            return words.any((word) => word.endsWith(alias));
          }
          return false;
        });
        if (!hit) continue;
        if (!exact && entry.key == ImportField.amount && _readsAsADate(words)) {
          // "Value Dt" reads as both the amount alias "value" and the date
          // alias "dt": a column with competing meanings is left out rather
          // than guessed at (IMP-3), instead of the loose pass picking one
          // arbitrarily. The veto is narrow on purpose — only for the
          // amount/date collision that actually causes harm (a date column
          // read as a numeric amount) — so a generic alias like the title
          // field's "name" (as in "Category name" or "Account Name") does
          // not block a different field's loose match just because it also
          // appears in the header.
          continue;
        }
        matched[entry.key] = column;
        taken.add(column);
        break;
      }
    }
  }
  return matched;
}

/// Whether the header words also whole-word match a date alias, regardless
/// of alias length: a short alias like "dt" is not trusted to pick the date
/// column on its own, but it is trusted to veto the amount field's loose
/// match on the same header ("Value Dt" is both "value" and "dt").
bool _readsAsADate(List<String> words) =>
    _aliases[ImportField.date]!.any((alias) => _wholeWordMatch(words, alias));

/// Whether [text] is made up only of Latin letters (already folded to plain
/// a–z by [_foldHeader]) and spaces. A non-Latin alias — Arabic, CJK,
/// Hangul, Cyrillic and the rest — has no letter-by-letter fragments the way
/// short Latin words do, so the length-based rules above don't apply to it.
bool _isLatin(String text) => RegExp(r'^[a-z ]*$').hasMatch(text);

/// Whether [alias] (one or more space-separated words) appears as a
/// contiguous run of whole words inside [nameWords].
bool _wholeWordMatch(List<String> nameWords, String alias) {
  final aliasWords = alias.split(' ');
  if (aliasWords.length > nameWords.length) return false;
  for (var start = 0; start + aliasWords.length <= nameWords.length; start++) {
    var match = true;
    for (var i = 0; i < aliasWords.length; i++) {
      if (nameWords[start + i] != aliasWords[i]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}

/// Folds a header for comparison and reduces whatever separates its words —
/// spaces, underscores, hyphens, brackets — to single spaces. Only
/// punctuation goes: letters in any script stay, or an Arabic header would
/// fold away to nothing. A camelCase boundary ("TransactionDate") is split
/// into its own space before case is folded away, since `foldForSearch`
/// lowercases first and would otherwise weld the two words into one.
String _foldHeader(String name) =>
    foldForSearch(_splitCamelCase(name))
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
        .trim();

String _splitCamelCase(String name) => name.replaceAllMapped(
  RegExp(r'(\p{Ll}|\p{N})(\p{Lu})', unicode: true),
  (match) => '${match[1]} ${match[2]}',
);

/// What a row said its type was, or null when the column can't be read that
/// way. A file with no type column says so with a signed amount instead.
enum ImportedType { income, expense, transfer }

const _typeWords = <ImportedType, List<String>>{
  ImportedType.income: [
    'income',
    'in',
    'credit',
    'cr',
    'deposit',
    'earning',
    'revenue',
    'received',
    'gelir',
    'دخل',
    'revenu',
    'ingreso',
    'ingresos',
    'einnahme',
    'einnahmen',
    'আয়',
    '收入',
    'inkomsten',
    'έσοδα',
    'आय',
    'pemasukan',
    'entrate',
    '収入',
    '수입',
    'przychod',
    'receita',
    'entrada',
    'доход',
    'รายรับ',
    'آمدنی',
    'thu nhập',
  ],
  ImportedType.expense: [
    'expense',
    'out',
    'debit',
    'dr',
    'spending',
    'spent',
    'withdrawal',
    'payment',
    'paid',
    'gider',
    'harcama',
    'مصروف',
    'مصروفات',
    'depense',
    'gasto',
    'gastos',
    'ausgabe',
    'ausgaben',
    'ব্যয়',
    '支出',
    'uitgaven',
    'έξοδα',
    'व्यय',
    'खर्च',
    'pengeluaran',
    'uscite',
    '지출',
    'wydatek',
    'despesa',
    'saida',
    'расход',
    'รายจ่าย',
    'ค่าใช้จ่าย',
    'خرچ',
    'chi tiêu',
    'chi phí',
  ],
  ImportedType.transfer: [
    'transfer',
    'transfers',
    'movement',
    'transferencia',
    'transfert',
    'umbuchung',
    'تحويل',
    'স্থানান্তর',
    '转账',
    'overschrijving',
    'μεταφορά',
    'स्थानांतरण',
    'trasferimento',
    '振替',
    '振込',
    '이체',
    '송금',
    'przelew',
    'перевод',
    'โอนเงิน',
    'โอน',
    'منتقلی',
    'chuyển khoản',
  ],
};

/// Reads a type out of [value], in any of the app's 21 languages or the
/// usual English shorthands. Null when it says nothing recognisable.
ImportedType? parseImportedType(String value) {
  final folded = foldForSearch(value).trim();
  if (folded.isEmpty) return null;
  for (final entry in _typeWords.entries) {
    if (entry.value.contains(folded)) return entry.key;
  }
  // "Expense (food)" and the like: fall back to a word inside the cell.
  for (final entry in _typeWords.entries) {
    for (final word in entry.value) {
      if (RegExp('\\b${RegExp.escape(word)}\\b').hasMatch(folded)) {
        return entry.key;
      }
    }
  }
  return null;
}

/// An amount read out of a cell, and whether it was written as a negative.
///
/// Apps disagree about the sign: some carry the direction in a type column
/// and keep amounts positive, others write expenses as `-12.50` or
/// `(12.50)`. [isNegative] lets the caller use the sign only when there is
/// no type column to trust (IMP-3).
typedef ImportedAmount = ({Money amount, bool isNegative});

final _currencyJunk = RegExp(r'''[^0-9.,\-−()]''');

/// Reads an amount out of [value], allowing for a currency symbol, spaces,
/// and either `.` or `,` as the decimal mark. Null when what's left isn't a
/// number. The amount comes back positive; the sign is reported separately.
/// A mark with up to [decimals] digits after it is the decimal mark; one with
/// more separates thousands.
ImportedAmount? parseImportedAmount(String value, {int decimals = 2}) {
  var text = value.replaceAll(_currencyJunk, '').trim();
  if (text.isEmpty) return null;

  // Accountants write a negative in brackets.
  var negative = text.contains('(') && text.contains(')');
  text = text.replaceAll(RegExp(r'[()]'), '');
  if (text.startsWith('-') || text.startsWith('−')) {
    negative = true;
    text = text.substring(1);
  }
  text = text.replaceAll('-', '').replaceAll('−', '');
  if (text.isEmpty) return null;

  final normalised = _decimalPoint(text, decimals);
  final amount = Money.tryParse(normalised);
  if (amount == null) return null;
  return (amount: amount, isNegative: negative);
}

/// Turns whatever grouping and decimal marks [text] uses into a plain
/// `1234.56`. The last `.` or `,` is the decimal mark when it has one to
/// [decimals] digits after it; anything else separates thousands.
String _decimalPoint(String text, int decimals) {
  final lastDot = text.lastIndexOf('.');
  final lastComma = text.lastIndexOf(',');
  final decimalAt = lastDot > lastComma ? lastDot : lastComma;
  if (decimalAt < 0) return text;

  final after = text.length - decimalAt - 1;
  // "1,234" and "1.234.567" are grouped, not fractional.
  if (after == 0 || after > decimals) {
    return text.replaceAll(RegExp('[.,]'), '');
  }
  final whole = text.substring(0, decimalAt).replaceAll(RegExp('[.,]'), '');
  return '$whole.${text.substring(decimalAt + 1)}';
}

final _isoLike = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})');
final _dayFirst = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})');

/// Reads a date out of [value] (IMP-6).
///
/// ISO comes first, since that is what this app writes and what most exports
/// use. Otherwise the parts are read in [dayFirst] order — which the preview
/// shows the user, because `03/04` is a real ambiguity no amount of guessing
/// settles. A day that can't be a day settles it either way. Any time after
/// the date is ignored: a transaction belongs to the date the user picked
/// (DATE-1).
DateTime? parseImportedDate(String value, {bool dayFirst = true}) {
  final text = value.trim();
  if (text.isEmpty) return null;

  final iso = _isoLike.firstMatch(text);
  if (iso != null) {
    return _dateFrom(
      int.parse(iso[1]!),
      int.parse(iso[2]!),
      int.parse(iso[3]!),
    );
  }

  final parts = _dayFirst.firstMatch(text);
  if (parts == null) return null;
  final first = int.parse(parts[1]!);
  final second = int.parse(parts[2]!);
  final year = _fullYear(int.parse(parts[3]!));
  // Whichever number can't be a month decides the order.
  final readDayFirst = first > 12 || (second <= 12 && dayFirst);
  return readDayFirst
      ? _dateFrom(year, second, first)
      : _dateFrom(year, first, second);
}

/// Why a row won't be imported. Every one of these is counted and shown on
/// the preview, so nothing disappears silently (IMP-5).
enum SkipReason {
  /// Its date cell couldn't be read as a date (IMP-6).
  unreadableDate,

  /// Its amount cell couldn't be read as a number (IMP-6).
  unreadableAmount,

  /// An amount of nothing isn't a transaction (MONEY-2).
  zeroAmount,

  /// The app already has this one (IMP-8).
  alreadyThere,

  /// A transfer needs two accounts, and this row named fewer (ACC-3).
  incompleteTransfer,
}

/// One line of the file as the app read it.
class ImportRow {
  const ImportRow({
    required this.line,
    required this.type,
    this.date,
    this.amount,
    this.categoryName = '',
    this.accountName = '',
    this.toAccountName = '',
    this.title = '',
    this.note = '',
    this.skipped,
  });

  /// The line in the file, counting the header as line 1, so the preview can
  /// point at a row the user can find.
  final int line;

  final ImportedType type;
  final DateTime? date;
  final Money? amount;
  final String categoryName;
  final String accountName;
  final String toAccountName;
  final String title;
  final String note;

  /// Null when the row will import.
  final SkipReason? skipped;

  bool get imports => skipped == null;
}

/// Why a whole file can't be imported (IMP-4).
enum ImportRefusal {
  /// Nothing in it, or nothing but a header.
  empty,

  /// No column could be read as a date.
  noDateColumn,

  /// No column could be read as an amount.
  noAmountColumn,

  /// Both columns were found, but not one row had a usable pair.
  noUsableRows,
}

/// What importing [table] would do, for the user to look over before any of
/// it happens (IMP-5).
class ImportPlan {
  const ImportPlan({
    required this.columns,
    required this.rows,
    required this.unknownCategories,
    required this.unknownAccounts,
    this.refusal,
  });

  /// Which column was read as which field, for the preview to show and the
  /// user to correct (IMP-3).
  final Map<ImportField, int> columns;

  /// Every row of the file in order, those that will import and those that
  /// won't.
  final List<ImportRow> rows;

  /// Category names in the file that this app doesn't have, in the order
  /// they first appear. The user picks what each becomes (IMP-7).
  final List<String> unknownCategories;

  /// The same for account names.
  final List<String> unknownAccounts;

  /// Set when nothing can be imported and the app should say so (IMP-4).
  final ImportRefusal? refusal;

  bool get canImport => refusal == null;

  Iterable<ImportRow> get importing => rows.where((row) => row.imports);

  int get importCount => importing.length;

  int get skipCount => rows.length - importCount;

  /// How many rows each reason accounts for, for the preview's summary.
  Map<SkipReason, int> get skipCounts {
    final counts = <SkipReason, int>{};
    for (final row in rows) {
      final reason = row.skipped;
      if (reason != null) counts[reason] = (counts[reason] ?? 0) + 1;
    }
    return counts;
  }
}

/// The identity a row is compared by when looking for one already in the app
/// (IMP-8). A foreign CSV has no IDs, so this stands in for BAK-3's merge.
String importIdentity({
  required DateTime date,
  required Money amount,
  required ImportedType type,
  required String title,
}) => [
  date.year,
  date.month,
  date.day,
  amount.thousandths,
  type.name,
  foldForSearch(title).trim(),
].join('|');

/// Reads [table] into a plan, without writing anything.
///
/// [columns] overrides the header matching, so the preview can correct it.
/// [categoryIdFor] and [accountIdFor] answer with the app's own ID for a
/// name, or null when it has none — those names come back in the plan for
/// the user to map (IMP-7). [existingIdentities] holds [importIdentity] for
/// what the app already has, so repeats are skipped (IMP-8).
ImportPlan planImport({
  required CsvTable table,
  Map<ImportField, int>? columns,
  bool dayFirst = true,
  String? Function(String name)? categoryIdFor,
  String? Function(String name)? accountIdFor,
  Set<String> existingIdentities = const {},
}) {
  if (table.isEmpty || table.rows.isEmpty) {
    return const ImportPlan(
      columns: {},
      rows: [],
      unknownCategories: [],
      unknownAccounts: [],
      refusal: ImportRefusal.empty,
    );
  }

  final mapping = columns ?? matchColumns(table.header);
  ImportPlan refuse(ImportRefusal why) => ImportPlan(
    columns: mapping,
    rows: const [],
    unknownCategories: const [],
    unknownAccounts: const [],
    refusal: why,
  );
  if (!mapping.containsKey(ImportField.date)) {
    return refuse(ImportRefusal.noDateColumn);
  }
  if (!mapping.containsKey(ImportField.amount)) {
    return refuse(ImportRefusal.noAmountColumn);
  }

  String cell(List<String> row, ImportField field) {
    final column = mapping[field];
    if (column == null || column >= row.length) return '';
    return row[column];
  }

  // This app's own export writes plain decimals and never groups thousands,
  // so its "12.345" is a dinar amount to three places, not twelve thousand
  // (IMP-2). Other files keep the reading where three digits mean grouping.
  final ownExport =
      table.header.length == csvColumns.length &&
      [
        for (var i = 0; i < csvColumns.length; i++)
          table.header[i].trim().toLowerCase() == csvColumns[i],
      ].every((same) => same);

  final rows = <ImportRow>[];
  final unknownCategories = <String>[];
  final unknownAccounts = <String>[];
  // Repeats within the file count too, not just against what's already
  // stored, or importing a file that lists a row twice would still double it.
  final seen = {...existingIdentities};

  for (var i = 0; i < table.rows.length; i++) {
    final row = table.rows[i];
    final line = i + 2;
    final date = parseImportedDate(
      cell(row, ImportField.date),
      dayFirst: dayFirst,
    );
    final read = parseImportedAmount(
      cell(row, ImportField.amount),
      decimals: ownExport ? 3 : 2,
    );
    final title = cell(row, ImportField.title);
    final note = cell(row, ImportField.note);
    final category = cell(row, ImportField.category);
    final account = cell(row, ImportField.account);
    final toAccount = cell(row, ImportField.toAccount);

    // A type column is believed; failing that, a minus sign means it went
    // out, which is how an app with no type column writes an expense.
    final named = parseImportedType(cell(row, ImportField.type));
    final type =
        named ??
        (toAccount.isNotEmpty && account.isNotEmpty
            ? ImportedType.transfer
            : (read?.isNegative ?? false)
            ? ImportedType.expense
            : ImportedType.income);

    ImportRow at(SkipReason? skipped, {Money? amount}) => ImportRow(
      line: line,
      type: type,
      date: date,
      amount: amount,
      categoryName: category,
      accountName: account,
      toAccountName: toAccount,
      title: title,
      note: note,
      skipped: skipped,
    );

    if (date == null) {
      rows.add(at(SkipReason.unreadableDate));
      continue;
    }
    if (read == null) {
      rows.add(at(SkipReason.unreadableAmount));
      continue;
    }
    if (read.amount == Money.zero) {
      rows.add(at(SkipReason.zeroAmount, amount: read.amount));
      continue;
    }
    if (type == ImportedType.transfer &&
        (account.isEmpty || toAccount.isEmpty)) {
      rows.add(at(SkipReason.incompleteTransfer, amount: read.amount));
      continue;
    }

    final identity = importIdentity(
      date: date,
      amount: read.amount,
      type: type,
      title: title,
    );
    if (!seen.add(identity)) {
      rows.add(at(SkipReason.alreadyThere, amount: read.amount));
      continue;
    }

    rows.add(at(null, amount: read.amount));

    if (category.isNotEmpty &&
        categoryIdFor?.call(category) == null &&
        !unknownCategories.contains(category)) {
      unknownCategories.add(category);
    }
    for (final name in [account, toAccount]) {
      if (name.isNotEmpty &&
          accountIdFor?.call(name) == null &&
          !unknownAccounts.contains(name)) {
        unknownAccounts.add(name);
      }
    }
  }

  return ImportPlan(
    columns: mapping,
    rows: rows,
    unknownCategories: unknownCategories,
    unknownAccounts: unknownAccounts,
    // Both columns were there, but not one row made sense of them. The rows
    // stay on the plan even so: why each was skipped is exactly what the
    // user needs to see to fix the file (IMP-4).
    refusal: rows.every((row) => !row.imports)
        ? ImportRefusal.noUsableRows
        : null,
  );
}

int _fullYear(int year) =>
    year >= 100 ? year : (year >= 70 ? 1900 : 2000) + year;

DateTime? _dateFrom(int year, int month, int day) {
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  final date = DateTime(year, month, day);
  // DateTime rolls 31 February over into March; that wasn't a real date.
  if (date.month != month || date.day != day) return null;
  return date;
}
