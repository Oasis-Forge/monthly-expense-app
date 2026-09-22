import 'transaction.dart';

/// The sixteen colours a category can take (CAT-6), as ARGB values so that
/// the database, the migration and the screens all read one list and the
/// models layer keeps its distance from Flutter.
///
/// Every one of them carries white text, because the percentage label inside
/// a pie slice is white — a pale swatch would read worse than the fixed
/// palette it replaces.
const categoryPalette = <int>[
  0xFF6C5CE7,
  0xFF00897B,
  0xFFD84315,
  0xFF1E88E5,
  0xFFC2185B,
  0xFF2E7D32,
  0xFF8E24AA,
  0xFF00838F,
  0xFF5D4037,
  0xFF3949AB,
  0xFFE53935,
  0xFF546E7A,
  0xFFEF6C00,
  0xFF00695C,
  0xFF4527A0,
  0xFFAD1457,
];

/// A transaction category (CAT-1). Built-in defaults have a fixed [id] and a
/// [defaultKey]; their name comes from translations until the user sets
/// [name].
class Category {
  final String id;
  final TransactionType type;
  final String? defaultKey;
  final String? name;
  final String icon;

  /// One of [categoryPalette], or null for a category that predates colours
  /// (CAT-6).
  final int? color;
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
    this.color,
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
      'color': color,
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
      color: map['color'] as int?,
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
    int? color,
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
      color: color ?? this.color,
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
