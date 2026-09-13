import 'money.dart';

enum AccountType { cash, bank, card, other }

/// Where money is kept (ACC-1). The built-in Cash account has a fixed [id]
/// and a translated name until the user sets [name] (ACC-2).
class Account {
  /// ID of the built-in Cash account.
  static const cashId = 'acc-cash';

  final String id;
  final AccountType type;
  final String? defaultKey;
  final String? name;
  final Money openingBalance;

  /// The opening balance counts from this local date.
  final DateTime openingDate;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final DateTime? deletedAt;

  Account({
    required this.id,
    required this.type,
    this.defaultKey,
    this.name,
    required this.openingBalance,
    required this.openingDate,
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
      'opening_balance': openingBalance.thousandths,
      'opening_date': openingDate.toIso8601String(),
      'sort_order': sortOrder,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'archived_at': archivedAt?.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  factory Account.fromMap(Map<String, Object?> map) {
    return Account(
      id: map['id']! as String,
      type: AccountType.values.byName(map['type']! as String),
      defaultKey: map['default_key'] as String?,
      name: map['name'] as String?,
      openingBalance: Money(map['opening_balance']! as int),
      openingDate: DateTime.parse(map['opening_date']! as String),
      sortOrder: map['sort_order']! as int,
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
      archivedAt: _optionalDate(map['archived_at']),
      deletedAt: _optionalDate(map['deleted_at']),
    );
  }
}

DateTime? _optionalDate(Object? value) =>
    value == null ? null : DateTime.parse(value as String);
