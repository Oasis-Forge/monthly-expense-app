import 'money.dart';

enum TransactionType { income, expense }

/// A single income or expense entry.
class ExpenseTransaction {
  final String id;

  /// Optional (ADD-1); lists fall back to the note, then the category name.
  final String? title;
  final Money amount;
  final String categoryId;
  final String accountId;
  final TransactionType type;

  /// The local date and time the user picked (DATE-1).
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Set when the transaction is deleted (DEL-1). Deleted rows stay in the
  /// database for undo, trash, and backup merge.
  final DateTime? deletedAt;

  ExpenseTransaction({
    required this.id,
    this.title,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    required this.type,
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
      'title': title,
      'amount': amount.thousandths,
      'category_id': categoryId,
      'account_id': accountId,
      'type': type.name,
      'date': date.toIso8601String(),
      'note': note,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, Object?> map) {
    return ExpenseTransaction(
      id: map['id']! as String,
      title: map['title'] as String?,
      amount: Money(map['amount']! as int),
      categoryId: map['category_id']! as String,
      accountId: map['account_id']! as String,
      type: TransactionType.values.byName(map['type']! as String),
      date: DateTime.parse(map['date']! as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
      deletedAt: _optionalDate(map['deleted_at']),
    );
  }

  static const Object _unset = Object();

  /// Pass `null` for [title], [note], or [deletedAt] to clear it; leave it out
  /// to keep the current value.
  ExpenseTransaction copyWith({
    Object? title = _unset,
    Money? amount,
    String? categoryId,
    String? accountId,
    TransactionType? type,
    DateTime? date,
    Object? note = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
  }) {
    return ExpenseTransaction(
      id: id,
      title: identical(title, _unset) ? this.title : title as String?,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
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

DateTime? _optionalDate(Object? value) =>
    value == null ? null : DateTime.parse(value as String);
