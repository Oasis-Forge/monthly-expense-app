import 'transaction.dart';

/// A transaction category (CAT-1). Built-in defaults have a fixed [id] and a
/// [defaultKey]; their name comes from translations until the user sets
/// [name].
class Category {
  final String id;
  final TransactionType type;
  final String? defaultKey;
  final String? name;
  final String icon;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Archived categories are hidden from pickers but stay in history (CAT-4).
  final DateTime? archivedAt;
  final DateTime? deletedAt;

  Category({
    required this.id,
    required this.type,
    this.defaultKey,
    this.name,
    required this.icon,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.deletedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'type': type.name,
      'default_key': defaultKey,
      'name': name,
      'icon': icon,
      'sort_order': sortOrder,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'archived_at': archivedAt?.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(
      id: map['id']! as String,
      type: TransactionType.values.byName(map['type']! as String),
      defaultKey: map['default_key'] as String?,
      name: map['name'] as String?,
      icon: map['icon']! as String,
      sortOrder: map['sort_order']! as int,
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
      archivedAt: _optionalDate(map['archived_at']),
      deletedAt: _optionalDate(map['deleted_at']),
    );
  }

  static const Object _unset = Object();

  /// Pass `null` for [name], [archivedAt], or [deletedAt] to clear it; leave
  /// it out to keep the current value.
  Category copyWith({
    Object? name = _unset,
    String? icon,
    int? sortOrder,
    DateTime? updatedAt,
    Object? archivedAt = _unset,
    Object? deletedAt = _unset,
  }) {
    return Category(
      id: id,
      type: type,
      defaultKey: defaultKey,
      name: identical(name, _unset) ? this.name : name as String?,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: identical(archivedAt, _unset)
          ? this.archivedAt
          : archivedAt as DateTime?,
      deletedAt: identical(deletedAt, _unset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}

DateTime? _optionalDate(Object? value) =>
    value == null ? null : DateTime.parse(value as String);
