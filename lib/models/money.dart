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
  static Money? tryParse(String input, {int maxDecimals = 3}) {
    final match = _input.firstMatch(input.trim().replaceAll(',', '.'));
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
}

/// The two colours money is written in (CUR-5), as plain values so that the
/// screens and the PDF report draw from one pair rather than two. Each side
/// clears 4.5:1 against the surface it sits on: the light pair on a light
/// surface and on the report's white page, the dark pair on a dark one.
const incomeInkLight = 0xFF1B6B3A;
const incomeInkDark = 0xFF7BDBA0;
const expenseInkLight = 0xFFB3261E;
const expenseInkDark = 0xFFFFB4AB;
