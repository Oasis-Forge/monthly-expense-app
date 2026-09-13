/// Where a period sits relative to today.
enum PeriodTiming { past, current, future }

/// A span of days for totals and budgets (PER-1): from [start] up to, but not
/// including, [end]. Months begin on [startDay], which is 1–28 or
/// [lastDayOfMonth] (PER-2).
class Period {
  const Period._(this.start, this.end, this.startDay);

  /// The period that contains [moment].
  factory Period.containing(DateTime moment, {int startDay = 1}) {
    assert(
      (startDay >= 1 && startDay <= 28) || startDay == lastDayOfMonth,
      'startDay must be 1–28 or Period.lastDayOfMonth',
    );
    var start = _startIn(moment.year, moment.month, startDay);
    if (moment.isBefore(start)) {
      start = _startIn(moment.year, moment.month - 1, startDay);
    }
    final end = _startIn(start.year, start.month + 1, startDay);
    return Period._(start, end, startDay);
  }

  /// Start day meaning "the last day of each month".
  static const lastDayOfMonth = 31;

  final DateTime start;
  final DateTime end;
  final int startDay;

  Period get next => Period.containing(end, startDay: startDay);

  Period get previous => Period.containing(
    DateTime(start.year, start.month, start.day - 1),
    startDay: startDay,
  );

  /// The last day inside the period.
  DateTime get lastDay => DateTime(end.year, end.month, end.day - 1);

  bool get isCalendarMonth => start.day == 1 && end.day == 1;

  bool contains(DateTime moment) =>
      !moment.isBefore(start) && moment.isBefore(end);

  /// Whether the period is over, contains [today], or hasn't started yet.
  PeriodTiming timingOn(DateTime today) {
    if (contains(today)) return PeriodTiming.current;
    return today.isBefore(start) ? PeriodTiming.future : PeriodTiming.past;
  }

  @override
  bool operator ==(Object other) =>
      other is Period && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'Period($start – $end)';
}

/// The start date in [month] of [year]; months outside 1–12 roll over.
DateTime _startIn(int year, int month, int startDay) {
  final first = DateTime(year, month);
  final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(
    first.year,
    first.month,
    startDay < daysInMonth ? startDay : daysInMonth,
  );
}
