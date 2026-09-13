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
