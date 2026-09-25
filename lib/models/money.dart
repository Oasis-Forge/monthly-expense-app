import 'package:intl/number_symbols_data.dart' show numberFormatSymbols;
import 'package:intl/intl.dart';

/// An amount of money in whole thousandths of a currency unit, so sums never
/// drift (MONEY-1): `Money(12500)` is 12.5. Every ISO currency fits, and
/// changing the currency never rescales stored values.
extension type const Money(int thousandths) {
  static const zero = Money(0);

  static final _input = RegExp(r'^(\d{1,12})(?:\.(\d{1,3}))?$');

  /// Parses user input like `12`, `12.5`, or `12,5`, allowing at most
  /// [maxDecimals] decimals (the currency's, CUR-2). Returns null for anything
  /// else, including negative numbers.
  ///
  /// [decimalMark] is the language's own decimal separator (a `NumberFormat`'s
  /// `symbols.DECIMAL_SEP`, CUR-2): where it is `,` (French, German, Turkish,
  /// and most other non-English languages), a comma is read as a decimal
  /// point exactly like a period, since that's how the app's own amounts are
  /// shown in that language. Where it is anything else, `,` is presumed to be
  /// that language's thousands separator instead, and a comma followed by
  /// exactly [maxDecimals] digits is rejected when that is 3 (KWD, BHD, JOD,
  /// TND): `1,500` reads the same as a 3-decimal fraction (1.5) or a
  /// thousands separator (1500), and guessing the decimal reading would be
  /// silently off by 1000x. A period is always read as an unambiguous decimal
  /// point regardless of [decimalMark], since it's what [toInputString]
  /// round-trips through when an existing amount is edited again — so a
  /// language that groups thousands with a period (German) can still be
  /// misread this way; callers show the parsed amount back for a chance to
  /// notice.
  static Money? tryParse(
    String input, {
    int maxDecimals = 3,
    String decimalMark = '.',
  }) {
    final trimmed = input.trim();
    if (maxDecimals == 3 && decimalMark != ',') {
      final comma = trimmed.lastIndexOf(',');
      if (comma >= 0 && trimmed.length - comma - 1 == 3) return null;
    }
    final match = _input.firstMatch(trimmed.replaceAll(',', '.'));
    if (match == null) return null;
    final fraction = match[2] ?? '';
    if (fraction.length > maxDecimals) return null;
    return Money(
      int.parse(match[1]!) * 1000 + int.parse(fraction.padRight(3, '0')),
    );
  }

  bool get isPositive => thousandths > 0;
  bool get isNegative => thousandths < 0;

  Money operator +(Money other) => Money(thousandths + other.thousandths);
  Money operator -(Money other) => Money(thousandths - other.thousandths);
  Money operator -() => Money(-thousandths);

  /// For display and charts only; sums stay in [thousandths].
  double toDouble() => thousandths / 1000;

  /// Plain decimal text for editing a positive amount: `12.5`, `12`, `0.125`.
  String toInputString() {
    final whole = thousandths ~/ 1000;
    final fraction = (thousandths % 1000)
        .toString()
        .padLeft(3, '0')
        .replaceFirst(RegExp(r'0+$'), '');
    return fraction.isEmpty ? '$whole' : '$whole.$fraction';
  }
}

/// Money as people write it (CUR-2).
extension MoneyFormat on NumberFormat {
  /// [amount] with the currency's decimals when it has any to show, and with
  /// none at all when it is whole: 930 reads as 930, 12.5 as 12.50, and a
  /// currency that carries no decimals is unchanged.
  String money(Money amount) {
    minimumFractionDigits = amount.thousandths % 1000 == 0
        ? 0
        : maximumFractionDigits;
    return format(amount.toDouble());
  }

  /// [amount] with a plus on money coming in and a minus on money going out
  /// (CUR-5). The amount is formatted negative so that the language's own
  /// pattern decides where the sign belongs — before the symbol in English,
  /// against the figures in Arabic — and money coming in takes a plus in that
  /// same place. Pasted in front of the formatted amount instead, it would
  /// fall outside the isolate the pattern draws round the figures (LANG-5),
  /// and a right-to-left line would carry it off to the far end of the row,
  /// away from the figures it belongs to.
  String signedMoney(Money amount, {required bool isIncome}) {
    final text = money(-amount);
    return isIncome ? swapMinusForPlus(text, locale) : text;
  }
}

/// [text], formatted from a negative number so [locale]'s own pattern placed
/// the minus against its figures, with that minus swapped for a plus.
///
/// Only the sign glyph itself is swapped, not whatever precedes it: some
/// languages' [NumberSymbols.MINUS_SIGN] is a direction mark plus a hyphen
/// (Arabic's is `‎-`) so that mark can keep the minus from floating off
/// on a right-to-left line, and swapping the whole thing away would strip
/// that protection from the plus it leaves behind. A pattern of our own
/// writes a plain hyphen with no mark, so that is looked for too. Anything
/// that wants a plus on a positive change formats the negated value first
/// and calls this rather than pasting a bare `+` in front of the result:
/// pasted in, the sign falls outside the isolate the pattern draws round the
/// figures (LANG-5), and a right-to-left line can carry it off to the far
/// end of the row, away from the figures it belongs to (CUR-5).
String swapMinusForPlus(String text, String locale) {
  final localeMinus = numberFormatSymbols[locale]?.MINUS_SIGN;
  for (final minus in [
    if (localeMinus != null && localeMinus.isNotEmpty)
      String.fromCharCode(localeMinus.runes.last),
    '-',
  ]) {
    if (text.contains(minus)) return text.replaceFirst(minus, '+');
  }
  return '+$text';
}

/// The two colours money is written in (CUR-5), as plain values so that the
/// screens and the PDF report draw from one pair rather than two. Each side
/// clears 4.5:1 against the surface it sits on: the light pair on a light
/// surface and on the report's white page, the dark pair on a dark one.
const incomeInkLight = 0xFF1B6B3A;
const incomeInkDark = 0xFF7BDBA0;
const expenseInkLight = 0xFFB3261E;
const expenseInkDark = 0xFFFFB4AB;
