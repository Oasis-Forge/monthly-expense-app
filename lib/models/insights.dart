import 'money.dart';
import 'period.dart';

/// Income and expense dated on one day, for the calendar (INS-1).
class DayTotals {
  const DayTotals({this.income = Money.zero, this.expense = Money.zero});

  final Money income;
  final Money expense;
}

/// Income and expense that count in one period (INS-2, BAL-4).
class PeriodTotals {
  const PeriodTotals(
    this.period, {
    this.income = Money.zero,
    this.expense = Money.zero,
  });

  final Period period;
  final Money income;
  final Money expense;

  Money get net => income - expense;
}

/// How a category compares with the period before it, as a share of what it
/// was then: 0.12 is an eighth more, -0.4 is two fifths less (INS-6).
///
/// Null when there was nothing there before. That is a category to mark as
/// new rather than one to divide by nothing, and the two read differently to
/// anybody looking: "new" is a habit that started, not one that grew.
double? shareChange({required Money before, required Money now}) =>
    before.thousandths == 0
    ? null
    : (now.thousandths - before.thousandths) / before.thousandths;
