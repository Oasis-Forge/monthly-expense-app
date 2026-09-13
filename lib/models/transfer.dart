import 'money.dart';

/// Money moved between two accounts (ACC-3). It changes both account
/// balances and is never income or expense.
class Transfer {
  final String id;
  final String fromAccountId;
  final String toAccountId;
  final Money amount;

  /// The local date and time the user picked.
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Transfer({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.date,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now().toUtc();

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'from_account_id': fromAccountId,
      'to_account_id': toAccountId,
      'amount': amount.thousandths,
      'date': date.toIso8601String(),
      'note': note,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  factory Transfer.fromMap(Map<String, Object?> map) {
    return Transfer(
      id: map['id']! as String,
      fromAccountId: map['from_account_id']! as String,
      toAccountId: map['to_account_id']! as String,
      amount: Money(map['amount']! as int),
      date: DateTime.parse(map['date']! as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
      deletedAt: map['deleted_at'] == null
          ? null
          : DateTime.parse(map['deleted_at']! as String),
    );
  }

  static const Object _unset = Object();

  /// Pass `null` for [note] or [deletedAt] to clear it; leave it out to keep
  /// the current value.
  Transfer copyWith({
    String? fromAccountId,
    String? toAccountId,
    Money? amount,
    DateTime? date,
    Object? note = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
  }) {
    return Transfer(
      id: id,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: identical(note, _unset) ? this.note : note as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _unset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}
