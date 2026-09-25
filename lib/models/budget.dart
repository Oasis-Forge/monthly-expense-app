import 'money.dart';
import 'period.dart';

/// A spending limit per period for one category, or overall when
/// [categoryId] is null (BUD-1). Limits are versioned: a row applies from
/// [effectiveFrom] until a newer row for the same budget (BUD-5).
class Budget {
  final String id;
  final String? categoryId;

  /// Null when the budget was removed from [effectiveFrom] onward.
  final Money? limit;

  /// The start of the first period this limit applies to.
  final DateTime effectiveFrom;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Budget({
    required this.id,
    this.categoryId,
    required this.limit,
    required this.effectiveFrom,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': limit?.thousandths,
      'effective_from': effectiveFrom.toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, Object?> map) {
    final amount = map['amount'] as int?;
    final deletedAt = map['deleted_at'] as String?;
    return Budget(
      id: map['id']! as String,
      categoryId: map['category_id'] as String?,
      limit: amount == null ? null : Money(amount),
      effectiveFrom: DateTime.parse(map['effective_from']! as String),
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
      deletedAt: deletedAt == null ? null : DateTime.parse(deletedAt),
    );
  }

  static const Object _unset = Object();

  /// Pass `null` for [limit] or [deletedAt] to clear it; leave it out to keep
  /// the current value.
  Budget copyWith({
    Object? limit = _unset,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
  }) {
    return Budget(
      id: id,
      categoryId: categoryId,
      limit: identical(limit, _unset) ? this.limit : limit as Money?,
      effectiveFrom: effectiveFrom,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _unset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}

/// The limit in force for [categoryId] (null for the overall budget) during
/// [period]: the newest version that took effect before the period ended
/// (BUD-5). Versions from the same period start, such as ones merged from
/// another device's backup, go by the one saved last. Null when there is
/// none, or it was removed.
Money? limitFor(Iterable<Budget> budgets, String? categoryId, Period period) {
  Budget? newest;
  for (final budget in budgets) {
    if (budget.deletedAt != null ||
        budget.categoryId != categoryId ||
        !budget.effectiveFrom.isBefore(period.end)) {
      continue;
    }
    if (newest == null ||
        budget.effectiveFrom.isAfter(newest.effectiveFrom) ||
        (budget.effectiveFrom == newest.effectiveFrom &&
            budget.updatedAt.isAfter(newest.updatedAt))) {
      newest = budget;
    }
  }
  return newest?.limit;
}

enum BudgetLevel { ok, warning, over }

/// The budget bar's "within budget" colour (BUD-8, THEME-4), pinned like
/// the income and expense inks (CUR-5) so a wallpaper repaints the app
/// without ever making an OK budget look like a warning or an over one.
/// Each side clears 4.5:1 against surface and surfaceContainerLow, in
/// light, dark, and black (A11Y-3).
const budgetOkLight = 0xFF5D5791;
const budgetOkDark = 0xFFC6BFFF;

/// A budget's progress during one period (BUD-2–BUD-6).
class BudgetStatus {
  const BudgetStatus({
    required this.categoryId,
    required this.limit,
    required this.spent,
    required this.timing,
    this.daysLeft = 0,
  });

  /// Null for the overall budget.
  final String? categoryId;
  final Money limit;

  /// Expenses that already count in the period (BUD-2, BAL-4).
  final Money spent;
  final PeriodTiming timing;

  /// Days left in the current period, today included; 0 otherwise.
  final int daysLeft;

  Money get remaining => limit - spent;

  /// Spent as a share of the limit; 1 or more means over budget.
  double get progress =>
      limit.isPositive ? spent.thousandths / limit.thousandths : 1;

  /// A warning from 80% of the limit, over budget from 100% (BUD-4).
  BudgetLevel get level => progress >= 1
      ? BudgetLevel.over
      : progress >= 0.8
      ? BudgetLevel.warning
      : BudgetLevel.ok;

  /// What's left per day, today included. Only for the current period, and
  /// never negative: null once the limit is reached (BUD-3).
  Money? get perDayAllowance =>
      timing == PeriodTiming.current && remaining.isPositive && daysLeft > 0
      ? Money(remaining.thousandths ~/ daysLeft)
      : null;
}

/// The one line the budgets card on Home shows before it's opened (BUD-7).
class BudgetSummary {
  const BudgetSummary({
    required this.progress,
    required this.over,
    required this.level,
    required this.count,
    required this.timing,
  });

  /// The line for a period's [statuses], or null when it has no budgets.
  ///
  /// The overall budget speaks for the period when there is one. Otherwise
  /// the category budgets count together: their spending against their
  /// limits combined. The level is the worst of them all, so one budget over
  /// its limit shows even when the total is fine.
  static BudgetSummary? of(List<BudgetStatus> statuses) {
    if (statuses.isEmpty) return null;
    final overall = statuses.where((s) => s.categoryId == null).firstOrNull;
    final limit = statuses.fold(Money.zero, (sum, s) => sum + s.limit);
    final spent = statuses.fold(Money.zero, (sum, s) => sum + s.spent);
    final levels = statuses.map((s) => s.level).toSet();
    return BudgetSummary(
      progress:
          overall?.progress ??
          (limit.isPositive ? spent.thousandths / limit.thousandths : 1),
      over: statuses.where((s) => s.level == BudgetLevel.over).length,
      level: levels.contains(BudgetLevel.over)
          ? BudgetLevel.over
          : levels.contains(BudgetLevel.warning)
          ? BudgetLevel.warning
          : BudgetLevel.ok,
      count: statuses.length,
      timing: statuses.first.timing,
    );
  }

  /// Spent as a share of the budget; 1 or more means over.
  final double progress;

  /// How many budgets are at or over their limit.
  final int over;
  final BudgetLevel level;
  final int count;
  final PeriodTiming timing;
}

/// Which of the four things the summary card on Home is leading with (BAL-8).
enum HeroLineKind {
  /// An overall budget, still inside it: what is left, and what that is a day.
  leftToSpend,

  /// An overall budget with nothing left in it, exactly (BUD-4).
  limitReached,

  /// An overall budget, past it: how much over (BUD-3).
  overBudget,

  /// No overall budget, in the current period: what has gone so far, and what
  /// that has come to a day.
  spentSoFar,

  /// A period that has ended or has not begun, where there is no allowance to
  /// work out and no day to divide by (BUD-6).
  spentTotal,
}

/// The one number the summary card on Home leads with (BAL-8).
///
/// A value, decided from the period alone, so that what the card says can be
/// tested without a card.
class HeroLine {
  const HeroLine({required this.kind, required this.amount, this.perDay});

  final HeroLineKind kind;

  /// What is left, what is over, or what was spent — whichever [kind] says.
  final Money amount;

  /// The figure beside it, or null for a period that cannot give one.
  final Money? perDay;

  /// The line for a period.
  ///
  /// [overall] is the overall budget's status (BUD-1), or null when none is
  /// set. [spent] is the period's spending across every account, because a
  /// budget counts every account (ACC-7). [daysElapsed] counts today.
  static HeroLine of({
    required BudgetStatus? overall,
    required Money spent,
    required int daysElapsed,
    required PeriodTiming timing,
  }) {
    if (overall != null) {
      final remaining = overall.remaining;
      if (remaining.isNegative) {
        return HeroLine(kind: HeroLineKind.overBudget, amount: -remaining);
      }
      final perDay = overall.perDayAllowance;
      // No allowance to give: either the limit is exactly met, or the period
      // is not the one running (BUD-3, BUD-6).
      if (perDay == null) {
        return remaining.isPositive
            ? HeroLine(kind: HeroLineKind.spentTotal, amount: overall.spent)
            : HeroLine(kind: HeroLineKind.limitReached, amount: overall.limit);
      }
      return HeroLine(
        kind: HeroLineKind.leftToSpend,
        amount: remaining,
        perDay: perDay,
      );
    }
    if (timing != PeriodTiming.current || daysElapsed <= 0) {
      return HeroLine(kind: HeroLineKind.spentTotal, amount: spent);
    }
    return HeroLine(
      kind: HeroLineKind.spentSoFar,
      amount: spent,
      perDay: Money(spent.thousandths ~/ daysElapsed),
    );
  }
}
