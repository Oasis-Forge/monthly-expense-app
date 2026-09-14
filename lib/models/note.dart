import 'money.dart';

/// Something to remember, with an optional due date, amount, and category
/// (NOTE-1). Recording it as a transaction marks it done and links the two
/// (NOTE-4).
class Note {
  final String id;
  final String text;

  /// A local date. Required for [reminderAt] and for showing the note in the
  /// Home notices and the Insights calendar (NOTE-5).
  final DateTime? dueDate;

  /// A local date and time, on [dueDate], when a reminder notification fires
  /// (NOTE-6). Only meaningful when [dueDate] is set.
  final DateTime? reminderAt;
  final Money? amount;
  final String? categoryId;

  /// The transaction this note was recorded as (NOTE-4); set together with
  /// [doneAt]. Deleting that transaction clears this and reopens the note.
  final String? transactionId;

  /// Set when the note is done.
  final DateTime? doneAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Set when the note is deleted (DEL-1). Deleted rows stay in the database
  /// for undo, trash, and backup merge.
  final DateTime? deletedAt;

  Note({
    required this.id,
    required this.text,
    this.dueDate,
    this.reminderAt,
    this.amount,
    this.categoryId,
    this.transactionId,
    this.doneAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now().toUtc();

  bool get isDone => doneAt != null;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'text': text,
      'due_date': dueDate?.toIso8601String(),
      'reminder_at': reminderAt?.toIso8601String(),
      'amount': amount?.thousandths,
      'category_id': categoryId,
      'transaction_id': transactionId,
      'done_at': doneAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id']! as String,
      text: map['text']! as String,
      dueDate: _optionalDate(map['due_date']),
      reminderAt: _optionalDate(map['reminder_at']),
      amount: map['amount'] == null ? null : Money(map['amount']! as int),
      categoryId: map['category_id'] as String?,
      transactionId: map['transaction_id'] as String?,
      doneAt: _optionalDate(map['done_at']),
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
      deletedAt: _optionalDate(map['deleted_at']),
    );
  }

  static const Object _unset = Object();

  /// Pass `null` for [dueDate], [reminderAt], [amount], [categoryId],
  /// [transactionId], [doneAt], or [deletedAt] to clear it; leave it out to
  /// keep the current value.
  Note copyWith({
    String? text,
    Object? dueDate = _unset,
    Object? reminderAt = _unset,
    Object? amount = _unset,
    Object? categoryId = _unset,
    Object? transactionId = _unset,
    Object? doneAt = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
  }) {
    return Note(
      id: id,
      text: text ?? this.text,
      dueDate: identical(dueDate, _unset) ? this.dueDate : dueDate as DateTime?,
      reminderAt: identical(reminderAt, _unset)
          ? this.reminderAt
          : reminderAt as DateTime?,
      amount: identical(amount, _unset) ? this.amount : amount as Money?,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      transactionId: identical(transactionId, _unset)
          ? this.transactionId
          : transactionId as String?,
      doneAt: identical(doneAt, _unset) ? this.doneAt : doneAt as DateTime?,
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
