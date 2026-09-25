import 'money.dart';
import 'transaction.dart';

enum RecurrenceFrequency { day, week, month, year }

enum RecurrenceEnd { never, afterCount, onDate }

/// A transaction that repeats (RCR-1). Occurrence dates come from
/// [startDate], so a monthly rule on the 31st keeps returning to the 31st
/// (RCR-3).
class RecurringRule {
  final String id;
  final String? title;
  final Money amount;
  final String categoryId;
  final String accountId;
  final TransactionType type;
  final String? note;
  final RecurrenceFrequency frequency;

  /// Repeat every [interval] days, weeks, months, or years; at least 1.
  final int interval;

  /// A local date.
  final DateTime startDate;
  final RecurrenceEnd endType;

  /// How many occurrences in total, when [endType] is afterCount.
  final int? endCount;

  /// The last possible date, when [endType] is onDate.
  final DateTime? endDate;

  /// Posts due occurrences on its own; otherwise they wait for a tap (RCR-2).
  final bool autoPost;
  final DateTime? pausedAt;

  /// Occurrences before this local date are never posted or queued. It only
  /// moves forward when the rule's own start date moves past it (RCR-5); an
  /// occurrence due while paused is skipped on its own instead (RCR-6), so
  /// one already waiting before the pause is never affected.
  final DateTime activeFrom;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  RecurringRule({
    required this.id,
    this.title,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    required this.type,
    this.note,
    required this.frequency,
    required this.interval,
    required this.startDate,
    required this.endType,
    this.endCount,
    this.endDate,
    this.autoPost = false,
    this.pausedAt,
    required this.activeFrom,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isPaused => pausedAt != null;

  /// Whether the rule still has an occurrence to come on [today] or after it:
  /// a paused rule has none for now (RCR-6), and one whose end has gone by
  /// has none ever again (RCR-1).
  bool isActiveOn(DateTime today) {
    if (isPaused) return false;
    return switch (endType) {
      RecurrenceEnd.never => true,
      RecurrenceEnd.onDate => !endDate!.isBefore(today),
      RecurrenceEnd.afterCount => switch (occurrence((endCount ?? 0) - 1)) {
        null => false,
        final last => !last.isBefore(today),
      },
    };
  }

  /// What the rule comes to in a month, whatever it repeats on: the amount
  /// times how often it falls in a year, over twelve (RCR-8). Ten a week is
  /// 43.33 a month; 120 a year is 10; every second month halves.
  Money get monthlyCost {
    final perYear = switch (frequency) {
      RecurrenceFrequency.day => 365 / interval,
      RecurrenceFrequency.week => 52 / interval,
      RecurrenceFrequency.month => 12 / interval,
      RecurrenceFrequency.year => 1 / interval,
    };
    return Money((amount.thousandths * perYear / 12).round());
  }

  /// The occurrence at [index] (0 is [startDate]), or null once the rule has
  /// ended, or once it falls outside the range [DateTime] can represent
  /// (an interval or a count large enough to overflow it, money-time#7).
  DateTime? occurrence(int index) {
    if (endType == RecurrenceEnd.afterCount && index >= (endCount ?? 0)) {
      return null;
    }
    final steps = index * interval;
    DateTime date;
    try {
      date = switch (frequency) {
        RecurrenceFrequency.day => DateTime(
          startDate.year,
          startDate.month,
          startDate.day + steps,
        ),
        RecurrenceFrequency.week => DateTime(
          startDate.year,
          startDate.month,
          startDate.day + 7 * steps,
        ),
        RecurrenceFrequency.month => _clamped(
          startDate.year,
          startDate.month + steps,
          startDate.day,
        ),
        RecurrenceFrequency.year => _clamped(
          startDate.year + steps,
          startDate.month,
          startDate.day,
        ),
      };
    } on ArgumentError {
      return null;
    }
    if (endType == RecurrenceEnd.onDate && date.isAfter(endDate!)) return null;
    return date;
  }

  /// Occurrence dates from [from] through [to], both inclusive, never before
  /// [activeFrom].
  List<DateTime> occurrencesBetween(DateTime from, DateTime to) {
    final first = from.isAfter(activeFrom) ? from : activeFrom;
    // Days and weeks can jump straight to the first candidate.
    var index = 0;
    final stepDays = switch (frequency) {
      RecurrenceFrequency.day => interval,
      RecurrenceFrequency.week => 7 * interval,
      _ => 0,
    };
    if (stepDays > 0 && first.isAfter(startDate)) {
      index = _daysBetween(startDate, first) ~/ stepDays;
    }

    final dates = <DateTime>[];
    for (; ; index++) {
      final date = occurrence(index);
      if (date == null || date.isAfter(to)) break;
      if (!date.isBefore(first)) dates.add(date);
    }
    return dates;
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount.thousandths,
      'category_id': categoryId,
      'account_id': accountId,
      'type': type.name,
      'note': note,
      'frequency': frequency.name,
      'interval': interval,
      'start_date': startDate.toIso8601String(),
      'end_type': endType.name,
      'end_count': endCount,
      'end_date': endDate?.toIso8601String(),
      'auto_post': autoPost ? 1 : 0,
      'paused_at': pausedAt?.toUtc().toIso8601String(),
      'active_from': activeFrom.toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  factory RecurringRule.fromMap(Map<String, Object?> map) {
    return RecurringRule(
      id: map['id']! as String,
      title: map['title'] as String?,
      amount: Money(map['amount']! as int),
      categoryId: map['category_id']! as String,
      accountId: map['account_id']! as String,
      type: TransactionType.values.byName(map['type']! as String),
      note: map['note'] as String?,
      frequency: RecurrenceFrequency.values.byName(map['frequency']! as String),
      interval: map['interval']! as int,
      startDate: DateTime.parse(map['start_date']! as String),
      endType: RecurrenceEnd.values.byName(map['end_type']! as String),
      endCount: map['end_count'] as int?,
      endDate: _optionalDate(map['end_date']),
      autoPost: map['auto_post'] == 1,
      pausedAt: _optionalDate(map['paused_at']),
      activeFrom: DateTime.parse(map['active_from']! as String),
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
      deletedAt: _optionalDate(map['deleted_at']),
    );
  }

  static const Object _unset = Object();

  /// Pass `null` for [title], [note], [endCount], [endDate], [pausedAt], or
  /// [deletedAt] to clear it; leave it out to keep the current value.
  RecurringRule copyWith({
    Object? title = _unset,
    Money? amount,
    String? categoryId,
    String? accountId,
    TransactionType? type,
    Object? note = _unset,
    RecurrenceFrequency? frequency,
    int? interval,
    DateTime? startDate,
    RecurrenceEnd? endType,
    Object? endCount = _unset,
    Object? endDate = _unset,
    bool? autoPost,
    Object? pausedAt = _unset,
    DateTime? activeFrom,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
  }) {
    return RecurringRule(
      id: id,
      title: identical(title, _unset) ? this.title : title as String?,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      note: identical(note, _unset) ? this.note : note as String?,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      startDate: startDate ?? this.startDate,
      endType: endType ?? this.endType,
      endCount: identical(endCount, _unset) ? this.endCount : endCount as int?,
      endDate: identical(endDate, _unset) ? this.endDate : endDate as DateTime?,
      autoPost: autoPost ?? this.autoPost,
      pausedAt: identical(pausedAt, _unset)
          ? this.pausedAt
          : pausedAt as DateTime?,
      activeFrom: activeFrom ?? this.activeFrom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _unset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}

enum OccurrenceStatus { posted, skipped }

/// An occurrence that was posted or skipped. It is stored once per rule and
/// date, so an occurrence is never handled twice (RCR-4).
class RecurringOccurrence {
  RecurringOccurrence({
    required this.ruleId,
    required this.date,
    required this.status,
    this.transactionId,
    required this.createdAt,
  });

  final String ruleId;

  /// A local date.
  final DateTime date;
  final OccurrenceStatus status;

  /// The posted transaction, when [status] is posted.
  final String? transactionId;
  final DateTime createdAt;

  String get key => occurrenceKey(ruleId, date);

  Map<String, Object?> toMap() {
    return {
      'rule_id': ruleId,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'status': status.name,
      'transaction_id': transactionId,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  factory RecurringOccurrence.fromMap(Map<String, Object?> map) {
    return RecurringOccurrence(
      ruleId: map['rule_id']! as String,
      date: DateTime.parse(map['date']! as String),
      status: OccurrenceStatus.values.byName(map['status']! as String),
      transactionId: map['transaction_id'] as String?,
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }
}

/// Identifies one occurrence of a rule: its ID and the local date.
String occurrenceKey(String ruleId, DateTime date) =>
    '$ruleId@${DateTime(date.year, date.month, date.day).toIso8601String()}';

/// An occurrence that is due or upcoming and not handled yet.
class ScheduledOccurrence {
  const ScheduledOccurrence(this.rule, this.date);

  final RecurringRule rule;
  final DateTime date;
}

DateTime _clamped(int year, int month, int day) {
  final first = DateTime(year, month);
  final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(
    first.year,
    first.month,
    day < daysInMonth ? day : daysInMonth,
  );
}

int _daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

DateTime? _optionalDate(Object? value) =>
    value == null ? null : DateTime.parse(value as String);
