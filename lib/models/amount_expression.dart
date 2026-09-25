import 'money.dart';

final _operator = RegExp(r'[+\-−]');
final _tokens = RegExp(r'[+\-−]|[^+\-−]+');

/// Whether [input] contains a `+` or `−`, so its result is worth showing.
bool isAmountExpression(String input) => input.contains(_operator);

/// Evaluates amount input such as `12.5+3−1` (ADD-2). Returns null unless it
/// is one or more valid amounts, each with at most [maxDecimals] decimals,
/// joined by `+` or `−`. The result can be zero or negative; callers decide
/// whether to accept it.
///
/// [decimalMark] is passed straight through to [Money.tryParse].
Money? evaluateAmount(
  String input, {
  int maxDecimals = 3,
  String decimalMark = '.',
}) {
  final text = input.replaceAll(' ', '');
  final parts = [for (final match in _tokens.allMatches(text)) match[0]!];
  if (parts.isEmpty || parts.length.isEven) return null;

  var total = Money.tryParse(
    parts.first,
    maxDecimals: maxDecimals,
    decimalMark: decimalMark,
  );
  for (var i = 1; i < parts.length && total != null; i += 2) {
    final operand = Money.tryParse(
      parts[i + 1],
      maxDecimals: maxDecimals,
      decimalMark: decimalMark,
    );
    if (operand == null || !_operator.hasMatch(parts[i])) return null;
    total = parts[i] == '+' ? total + operand : total - operand;
  }
  return total;
}
