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
/// account. It is coloured only below zero (CUR-5), and null leaves the text
/// its ordinary colour. A day's own total isn't one of these: Home shows a
/// day's income and expense apart rather than netting them (DAY-7), so each
/// goes through [signedColor] instead.
Color? balanceColor(BuildContext context, Money amount) =>
    amount.isNegative ? expenseColor(context) : null;

/// `+12.50` or `-12.50` (CUR-5), written the same way everywhere: the screens
/// and the PDF report both go through [MoneyFormat.signedMoney], so neither
/// can drift into signing an amount its own way.
String signedAmount(
  NumberFormat currency,
  Money amount, {
  required bool isIncome,
}) => currency.signedMoney(amount, isIncome: isIncome);

/// [base] set in the app's figures (CUR-4).
TextStyle amountStyle([TextStyle? base]) =>
    (base ?? const TextStyle()).copyWith(fontFeatures: tabularFigures);

/// Passed in place of a translated message's `{amount}` placeholder when the
/// amount needs its own [TextSpan] — a sign, a colour — rather than plain
/// text: format the message with this in [amount]'s place, then hand the
/// result to [spansWithAmount] along with the styled span. Each language
/// keeps its own separator and word order around the amount this way,
/// instead of one hard-coded in the calling screen (pr61#8).
const amountSentinel = '￼';

/// [textWithSentinel] — a translated message formatted with [amountSentinel]
/// standing in for its amount — split around that sentinel, with
/// [amountSpan] dropped into its place.
List<InlineSpan> spansWithAmount(
  String textWithSentinel,
  InlineSpan amountSpan,
) {
  final index = textWithSentinel.indexOf(amountSentinel);
  if (index < 0) return [TextSpan(text: textWithSentinel)];
  return [
    TextSpan(text: textWithSentinel.substring(0, index)),
    amountSpan,
    TextSpan(text: textWithSentinel.substring(index + amountSentinel.length)),
  ];
}

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
