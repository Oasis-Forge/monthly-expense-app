import 'money.dart';
import 'period.dart';

/// What the home-screen widget shows from [from] until the next entry starts
/// (WID-1, WID-2). The app builds one for today and one for each day ahead
/// on which the numbers change, so the widget stays right past midnight
/// without the app running (WID-5).
class WidgetSummary {
  const WidgetSummary({
    required this.from,
    required this.period,
    required this.income,
    required this.expense,
    required this.balance,
    required this.balanceIsNet,
    this.budgetLeft,
  });

  /// The day this entry takes over, at midnight local time.
  final DateTime from;

  /// The period it counts, which is the current one on [from] (WID-2).
  final Period period;

  final Money income;
  final Money expense;

  /// The closing balance, or the period's net when carry-forward is off,
  /// matching Home's third tile (BAL-3).
  final Money balance;

  /// Whether [balance] is the period's net rather than the closing balance,
  /// so the widget can label it the way Home does.
  final bool balanceIsNet;

  /// The overall budget minus what's been spent, or null when there's no
  /// overall budget in force (BUD-5). Negative once it's overspent.
  final Money? budgetLeft;

  bool get isOverBudget => budgetLeft?.isNegative ?? false;

  @override
  bool operator ==(Object other) =>
      other is WidgetSummary &&
      other.from == from &&
      other.period == period &&
      other.income == income &&
      other.expense == expense &&
      other.balance == balance &&
      other.balanceIsNet == balanceIsNet &&
      other.budgetLeft == budgetLeft;

  @override
  int get hashCode => Object.hash(
    from,
    period,
    income,
    expense,
    balance,
    balanceIsNet,
    budgetLeft,
  );

  @override
  String toString() =>
      'WidgetSummary($from, income: $income, expense: $expense, '
      'balance: $balance, budgetLeft: $budgetLeft)';
}
