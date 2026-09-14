import 'account.dart';
import 'insights.dart';
import 'money.dart';
import 'period.dart';
import 'transaction.dart';
import 'transfer.dart';

/// What a report covers (PDF-1).
enum ReportRange {
  /// The period shown on Home.
  period,

  /// Two dates the user picked.
  custom,

  /// A calendar year.
  year,
}

/// What a report leaves out (PDF-3). Everything is included by default; each
/// flag turned off removes one kind of detail, so a report can be shared
/// without handing over the whole picture.
class ReportOptions {
  const ReportOptions({
    this.transactions = true,
    this.titlesAndNotes = true,
    this.accountNames = true,
  });

  /// The day-by-day list of entries. Off leaves the summary, the categories,
  /// and the trend.
  final bool transactions;

  /// Each entry's title and note. Off leaves its category, date, and amount.
  final bool titlesAndNotes;

  /// Which account an entry belongs to.
  final bool accountNames;
}

/// One category's spending or income over the range, with its share of the
/// total and the budget it ran against (PDF-2, BUD-2).
class ReportCategoryLine {
  const ReportCategoryLine({
    required this.categoryId,
    required this.amount,
    required this.share,
    this.budget,
  });

  final String categoryId;
  final Money amount;

  /// 0 to 1 of the range's total for this type. Zero when the total is zero.
  final double share;

  /// The limit in force, or null when the category has none (BUD-1).
  final Money? budget;

  /// How much of [budget] is spent, 0 to 1 and beyond when over. Null without
  /// a budget, or with one of zero.
  double? get budgetUsed {
    final limit = budget;
    if (limit == null || limit.thousandths == 0) return null;
    return amount.thousandths / limit.thousandths;
  }
}

/// One entry in the report's day-by-day list: a transaction, or a transfer
/// between accounts, which is marked as such and left out of the totals
/// (PDF-2).
class ReportEntry {
  const ReportEntry.transaction(ExpenseTransaction this.transaction)
    : transfer = null;
  const ReportEntry.transfer(Transfer this.transfer) : transaction = null;

  final ExpenseTransaction? transaction;
  final Transfer? transfer;

  bool get isTransfer => transfer != null;
  DateTime get date => transaction?.date ?? transfer!.date;
  Money get amount => transaction?.amount ?? transfer!.amount;
}

/// Everything a report shows, worked out once from the data so the PDF
/// builder only lays it out (PDF-2).
class ReportData {
  const ReportData({
    required this.from,
    required this.to,
    required this.income,
    required this.expense,
    required this.openingBalance,
    required this.closingBalance,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.trend,
    required this.byDay,
    required this.upcoming,
    required this.entryCount,
  });

  /// The first and last day the report covers, both included.
  final DateTime from;
  final DateTime to;

  final Money income;
  final Money expense;

  /// The balance carried into [from] and the one left after [to] (BAL-2,
  /// BAL-3).
  final Money openingBalance;
  final Money closingBalance;

  /// Largest first.
  final List<ReportCategoryLine> expenseCategories;
  final List<ReportCategoryLine> incomeCategories;

  /// A point per day, or per period when the range covers more than two of
  /// them (PDF-2, INS-2). Oldest first.
  final List<ReportTrendPoint> trend;

  /// Counted entries by day, oldest day first, each day's entries oldest
  /// first. Empty when [ReportOptions.transactions] is off.
  final Map<DateTime, List<ReportEntry>> byDay;

  /// Entries dated in the range but after today, which count towards nothing
  /// yet (BAL-4, PDF-2).
  final List<ReportEntry> upcoming;

  /// How many entries the report lays out, for the progress it reports while
  /// building (PDF-6).
  final int entryCount;

  Money get net => income - expense;

  bool get isEmpty => byDay.isEmpty && upcoming.isEmpty && entryCount == 0;
}

/// One column of the report's trend (PDF-2, INS-2).
class ReportTrendPoint {
  const ReportTrendPoint({
    required this.start,
    required this.label,
    required this.income,
    required this.expense,
  });

  /// The first day the point covers.
  final DateTime start;

  /// Whether it stands for a day or a whole period, so the report can date
  /// its axis the right way.
  final ReportTrendGrain label;

  final Money income;
  final Money expense;
}

enum ReportTrendGrain { day, period }

/// Builds a report's figures for the days [from] to [to], both included.
///
/// [today] decides what counts: entries dated after it land in
/// [ReportData.upcoming] instead of the totals (BAL-4). With [accountId] the
/// report narrows to that account, and transfers in or out of it move its
/// balance; without one, transfers are shown in the day list but change no
/// total, because the money never leaves (ACC-4).
///
/// [budgetLimit] answers the limit in force for a category, or null; pass
/// [TransactionProvider.budgetLimit]. [startDay] is the first day of a period
/// (PER-2), used to group a long range's trend.
ReportData buildReport({
  required DateTime from,
  required DateTime to,
  required DateTime today,
  required List<ExpenseTransaction> transactions,
  required List<Transfer> transfers,
  required List<Account> accounts,
  String? accountId,
  Money? Function(String categoryId)? budgetLimit,
  int startDay = 1,
  ReportOptions options = const ReportOptions(),
}) {
  final first = _dayOf(from);
  final last = _dayOf(to);
  final now = _dayOf(today);
  bool inRange(DateTime date) {
    final day = _dayOf(date);
    return !day.isBefore(first) && !day.isAfter(last);
  }

  bool counts(DateTime date) => !_dayOf(date).isAfter(now);
  bool mine(ExpenseTransaction tx) =>
      accountId == null || tx.accountId == accountId;
  bool touches(Transfer transfer) =>
      accountId == null ||
      transfer.fromAccountId == accountId ||
      transfer.toAccountId == accountId;

  var opening = Money.zero;
  for (final account in accounts) {
    if (accountId != null && account.id != accountId) continue;
    if (_dayOf(account.openingDate).isBefore(first) &&
        counts(account.openingDate)) {
      opening += account.openingBalance;
    }
  }
  var openingDuring = Money.zero;
  for (final account in accounts) {
    if (accountId != null && account.id != accountId) continue;
    if (inRange(account.openingDate) && counts(account.openingDate)) {
      openingDuring += account.openingBalance;
    }
  }

  var income = Money.zero;
  var expense = Money.zero;
  final expenseByCategory = <String, Money>{};
  final incomeByCategory = <String, Money>{};
  final byDay = <DateTime, List<ReportEntry>>{};
  final upcoming = <ReportEntry>[];
  final dayTotals = <DateTime, DayTotals>{};
  var entryCount = 0;

  for (final tx in transactions) {
    if (!mine(tx)) continue;
    if (!inRange(tx.date)) {
      // Everything counted before the range moves the opening balance.
      if (counts(tx.date) && _dayOf(tx.date).isBefore(first)) {
        opening += tx.type == TransactionType.income ? tx.amount : -tx.amount;
      }
      continue;
    }
    entryCount++;
    final entry = ReportEntry.transaction(tx);
    if (!counts(tx.date)) {
      upcoming.add(entry);
      continue;
    }
    final day = _dayOf(tx.date);
    if (options.transactions) {
      byDay.putIfAbsent(day, () => []).add(entry);
    }
    final isIncome = tx.type == TransactionType.income;
    final totals = dayTotals[day] ?? const DayTotals();
    dayTotals[day] = DayTotals(
      income: isIncome ? totals.income + tx.amount : totals.income,
      expense: isIncome ? totals.expense : totals.expense + tx.amount,
    );
    final byCategory = isIncome ? incomeByCategory : expenseByCategory;
    byCategory[tx.categoryId] =
        (byCategory[tx.categoryId] ?? Money.zero) + tx.amount;
    if (isIncome) {
      income += tx.amount;
    } else {
      expense += tx.amount;
    }
  }

  // Transfers only move one account's balance, never the overall totals.
  var transferNet = Money.zero;
  for (final transfer in transfers) {
    if (!touches(transfer)) continue;
    final into = transfer.toAccountId == accountId;
    final outOf = transfer.fromAccountId == accountId;
    if (!inRange(transfer.date)) {
      if (accountId != null &&
          counts(transfer.date) &&
          _dayOf(transfer.date).isBefore(first)) {
        if (into) opening += transfer.amount;
        if (outOf) opening -= transfer.amount;
      }
      continue;
    }
    entryCount++;
    final entry = ReportEntry.transfer(transfer);
    if (!counts(transfer.date)) {
      upcoming.add(entry);
      continue;
    }
    if (options.transactions) {
      byDay.putIfAbsent(_dayOf(transfer.date), () => []).add(entry);
    }
    if (accountId != null) {
      if (into) transferNet += transfer.amount;
      if (outOf) transferNet -= transfer.amount;
    }
  }

  for (final entries in byDay.values) {
    entries.sort((a, b) => a.date.compareTo(b.date));
  }
  upcoming.sort((a, b) => a.date.compareTo(b.date));
  final orderedDays = byDay.keys.toList()..sort();

  return ReportData(
    from: first,
    to: last,
    income: income,
    expense: expense,
    openingBalance: opening,
    closingBalance: opening + openingDuring + income - expense + transferNet,
    expenseCategories: _lines(expenseByCategory, expense, budgetLimit),
    incomeCategories: _lines(incomeByCategory, income, null),
    trend: _trend(first, last, now, dayTotals, startDay),
    byDay: {for (final day in orderedDays) day: byDay[day]!},
    upcoming: upcoming,
    entryCount: entryCount,
  );
}

List<ReportCategoryLine> _lines(
  Map<String, Money> byCategory,
  Money total,
  Money? Function(String categoryId)? budgetLimit,
) {
  final lines = [
    for (final MapEntry(key: id, value: amount) in byCategory.entries)
      ReportCategoryLine(
        categoryId: id,
        amount: amount,
        share: total.thousandths == 0
            ? 0
            : amount.thousandths / total.thousandths,
        budget: budgetLimit?.call(id),
      ),
  ]..sort((a, b) => b.amount.thousandths.compareTo(a.amount.thousandths));
  return lines;
}

/// A point per day for a short range, or per period once the range covers
/// more than two of them, so a year doesn't draw 365 columns (PDF-2, INS-2).
List<ReportTrendPoint> _trend(
  DateTime first,
  DateTime last,
  DateTime today,
  Map<DateTime, DayTotals> dayTotals,
  int startDay,
) {
  final periods = <Period>[];
  var period = Period.containing(first, startDay: startDay);
  while (!period.start.isAfter(last)) {
    periods.add(period);
    period = period.next;
  }

  if (periods.length <= 2) {
    final points = <ReportTrendPoint>[];
    for (
      var day = first;
      !day.isAfter(last);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      final totals = dayTotals[day] ?? const DayTotals();
      points.add(
        ReportTrendPoint(
          start: day,
          label: ReportTrendGrain.day,
          income: totals.income,
          expense: totals.expense,
        ),
      );
    }
    return points;
  }

  return [
    for (final period in periods)
      () {
        var income = Money.zero;
        var expense = Money.zero;
        for (final MapEntry(key: day, value: totals) in dayTotals.entries) {
          if (period.contains(day)) {
            income += totals.income;
            expense += totals.expense;
          }
        }
        return ReportTrendPoint(
          start: period.start,
          label: ReportTrendGrain.period,
          income: income,
          expense: expense,
        );
      }(),
  ];
}

DateTime _dayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);
