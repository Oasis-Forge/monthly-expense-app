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
