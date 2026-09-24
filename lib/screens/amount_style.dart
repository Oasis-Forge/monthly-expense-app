import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:intl/number_symbols_data.dart' show numberFormatSymbols;

import '../models/money.dart';

/// How money is written, in one place (CUR-4, CUR-5): figures of one width,
/// one sign, and two colours the app owns rather than borrows.

/// Digits of a single width, so a column of amounts lines up and a figure
/// that changes never nudges the text beside it (CUR-4).
const List<FontFeature> tabularFigures = [FontFeature.tabularFigures()];

/// Money coming in, and money going out (CUR-5). Each pair clears 4.5:1
/// against the surface behind it, which Flutter's stock green and red do not.
const _incomeLight = Color(incomeInkLight);
const _incomeDark = Color(incomeInkDark);
const _expenseLight = Color(expenseInkLight);
const _expenseDark = Color(expenseInkDark);

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

/// The colour of money coming in (CUR-5).
Color incomeColor(BuildContext context) =>
    _isDark(context) ? _incomeDark : _incomeLight;

/// The colour of money going out (CUR-5).
Color expenseColor(BuildContext context) =>
    _isDark(context) ? _expenseDark : _expenseLight;

/// The colour of an amount that is one kind or the other (CUR-5).
Color signedColor(BuildContext context, {required bool isIncome}) =>
    isIncome ? incomeColor(context) : expenseColor(context);

/// The colour of a figure that can fall either way — a balance, a net, an
/// account, a day's own total. It is coloured only below zero (CUR-5), and
/// null leaves the text its ordinary colour.
Color? balanceColor(BuildContext context, Money amount) =>
    amount.isNegative ? expenseColor(context) : null;

/// `+12.50` or `-12.50` (CUR-5). The amount is formatted negative so that the
/// language's own pattern decides where the sign belongs — before the symbol
/// in English, against the figures in Arabic — and money coming in then takes
/// a plus in that same place. Put in by hand it would sit outside the isolate
/// the pattern draws (LANG-5) and a right-to-left line would carry it off to
/// the far end, away from the figures it belongs to.
String signedAmount(
  NumberFormat currency,
  Money amount, {
  required bool isIncome,
}) {
  final text = currency.money(-amount);
  if (!isIncome) return text;
  // A language's own minus may carry a direction mark in front of it, and a
  // pattern of our own writes the plain one, so both are looked for.
  for (final minus in [
    numberFormatSymbols[currency.locale]?.MINUS_SIGN ?? '-',
    '-',
  ]) {
    if (text.contains(minus)) return text.replaceFirst(minus, '+');
  }
  return '+$text';
}

/// [base] set in the app's figures (CUR-4).
TextStyle amountStyle([TextStyle? base]) =>
    (base ?? const TextStyle()).copyWith(fontFeatures: tabularFigures);

/// A money figure that counts to its new value instead of cutting to it
/// (BAL-10). The figure is right from the first frame — only the way it
/// arrives is new — and a phone asking for less motion is given it at once.
class RollingAmount extends StatelessWidget {
  const RollingAmount({
    super.key,
    required this.amount,
    required this.currency,
    this.style,
    this.textAlign,
  });

  final Money amount;
  final NumberFormat currency;
  final TextStyle? style;
  final TextAlign? textAlign;

  static const _roll = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: amount.toDouble()),
      duration: still ? Duration.zero : _roll,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text(
        // Mid-count the figure is a fraction of the way there, so it
        // carries decimals until it lands on a whole one (CUR-2).
        currency.money(Money((value * 1000).round())),
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}
