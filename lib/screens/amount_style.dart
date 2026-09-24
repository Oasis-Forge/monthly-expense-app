import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../models/money.dart';

/// How money is written, in one place (CUR-4, CUR-5): figures of one width,
/// one sign, and two colours the app owns rather than borrows.

/// Digits of a single width, so a column of amounts lines up and a figure
/// that changes never nudges the text beside it (CUR-4).
const List<FontFeature> tabularFigures = [FontFeature.tabularFigures()];

/// Money coming in, and money going out (CUR-5). Each pair clears 4.5:1
/// against the surface behind it, which Flutter's stock green and red do not.
const _incomeLight = Color(0xFF1B6B3A);
const _incomeDark = Color(0xFF7BDBA0);
const _expenseLight = Color(0xFFB3261E);
const _expenseDark = Color(0xFFFFB4AB);

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

/// `+12.50` or `-12.50` (CUR-5). The pieces stay together as one
/// left-to-right run wherever the language runs the other way (LANG-5).
String signedAmount(
  NumberFormat currency,
  Money amount, {
  required bool isIncome,
}) => '${isIncome ? '+' : '-'}${currency.format(amount.toDouble())}';

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
      builder: (context, value, _) =>
          Text(currency.format(value), style: style, textAlign: textAlign),
    );
  }
}
