import 'dart:convert';

import 'account.dart';
import 'budget.dart';
import 'category.dart';
import 'note.dart';
import 'recurring_rule.dart';
import 'transaction.dart';
import 'transfer.dart';

/// Rows per table name, as stored in the database and in a backup file.
typedef BackupTables = Map<String, List<Map<String, Object?>>>;

/// Every table a backup holds, in the order they're restored (BAK-1).
const backupTableNames = [
  'categories',
  'accounts',
  'transactions',
  'transfers',
  'budgets',
  'recurring_rules',
  'recurring_occurrences',
  'notes',
];

enum BackupProblem {
  /// The file isn't a backup, or its records are malformed.
  invalid,

  /// The backup comes from a newer schema than this app knows (BAK-4).
  tooNew,
}

class BackupException implements Exception {
  const BackupException(this.problem);

  final BackupProblem problem;

  @override
  String toString() => 'BackupException(${problem.name})';
}

enum RestoreMode { replace, merge }

/// The contents of a backup file (BAK-1): every table's rows, deleted ones
/// included, with the app version, the schema version, and the settings
/// that move with the data.
class BackupData {
  const BackupData({
    required this.schemaVersion,
    required this.createdAt,
    required this.tables,
    this.appVersion,
    this.settings = const {},
    this.files = const {},
  });

  /// Identifies the file type, so other JSON files are refused.
  static const format = 'monthly-expenses-backup';

  final int schemaVersion;
  final DateTime createdAt;
  final String? appVersion;
  final Map<String, Object?> settings;
  final BackupTables tables;

  /// Attachment files by name, carried by a zip backup (ATT-6). They are not
  /// part of the JSON.
  final Map<String, List<int>> files;

  /// Transactions in the backup that aren't deleted.
  int get transactionCount => (tables['transactions'] ?? const [])
      .where((row) => row['deleted_at'] == null)
      .length;

  /// The photo and voice files this backup's transactions point at (ATT-6).
  Set<String> get attachmentNames => {
    for (final row in tables['transactions'] ?? const [])
      for (final column in ['photo_file', 'voice_file'])
        if (row[column] != null) row[column]! as String,
  };

  BackupData withTables(BackupTables tables, {required int schemaVersion}) {
    return BackupData(
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      tables: tables,
      appVersion: appVersion,
      settings: settings,
      files: files,
    );
  }

  BackupData withFiles(Map<String, List<int>> files) => BackupData(
    schemaVersion: schemaVersion,
    createdAt: createdAt,
    tables: tables,
    appVersion: appVersion,
    settings: settings,
    files: files,
  );

  String toJson() => jsonEncode({
    'format': format,
    'appVersion': appVersion,
    'schemaVersion': schemaVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'settings': settings,
    'tables': tables,
  });

  /// Reads a backup file. Throws a [BackupException] when [source] isn't a
  /// backup.
  factory BackupData.fromJson(String source) {
    try {
      final json = jsonDecode(source);
      if (json is! Map<String, Object?> || json['format'] != format) {
        throw const FormatException('Not a backup');
      }
      final version = json['schemaVersion'];
      final tables = json['tables'];
      final settings = json['settings'] ?? const <String, Object?>{};
      if (version is! int ||
          version < 1 ||
          tables is! Map<String, Object?> ||
          settings is! Map<String, Object?>) {
        throw const FormatException('Missing fields');
      }
      return BackupData(
        schemaVersion: version,
        createdAt: DateTime.parse(json['createdAt']! as String),
        appVersion: json['appVersion'] as String?,
        settings: settings,
        tables: {
          for (final MapEntry(key: table, value: rows) in tables.entries)
            table: [for (final row in rows! as List<Object?>) _row(row)],
        },
      );
    } catch (_) {
      throw const BackupException(BackupProblem.invalid);
    }
  }

  static Map<String, Object?> _row(Object? row) {
    if (row is! Map<String, Object?> ||
        row.values.any((v) => v != null && v is! String && v is! num)) {
      throw const FormatException('Malformed row');
    }
    return row;
  }
}

/// Checks the tables of a backup at the current schema against the app's
/// models and returns them as the app writes them. Throws a
/// [BackupException] for a missing table, a malformed or duplicate record,
/// or data without an account.
BackupTables normalizeTables(BackupTables tables) {
  try {
    List<Map<String, Object?>> rows(String table) => tables[table]!;
    final normalized = <String, List<Map<String, Object?>>>{
      'categories': [
        for (final row in rows('categories')) Category.fromMap(row).toMap(),
      ],
      'accounts': [
        for (final row in rows('accounts')) Account.fromMap(row).toMap(),
      ],
      'transactions': [
        for (final row in rows('transactions'))
          ExpenseTransaction.fromMap(row).toMap(),
      ],
      'transfers': [
        for (final row in rows('transfers')) Transfer.fromMap(row).toMap(),
      ],
      'budgets': [
        for (final row in rows('budgets')) Budget.fromMap(row).toMap(),
      ],
      'recurring_rules': [
        for (final row in rows('recurring_rules'))
          RecurringRule.fromMap(row).toMap(),
      ],
      'recurring_occurrences': [
        for (final row in rows('recurring_occurrences'))
          RecurringOccurrence.fromMap(row).toMap(),
      ],
      'notes': [for (final row in rows('notes')) Note.fromMap(row).toMap()],
    };
    for (final MapEntry(key: table, value: rows) in normalized.entries) {
      final keys = {for (final row in rows) _recordKey(table, row)};
      if (keys.length != rows.length) {
        throw const FormatException('Duplicate records');
      }
    }
    if (!normalized['accounts']!.any((row) => row['deleted_at'] == null)) {
      throw const FormatException('No account');
    }
    return normalized;
  } catch (_) {
    throw const BackupException(BackupProblem.invalid);
  }
}

/// What merging a backup adds and updates, and how many records it leaves as
/// they are (BAK-3).
class MergePlan {
  final BackupTables inserts = {};
  final BackupTables updates = {};
  int unchanged = 0;

  int get added => _count(inserts);
  int get updated => _count(updates);

  static int _count(BackupTables tables) =>
      tables.values.fold(0, (sum, rows) => sum + rows.length);

  void _add(BackupTables into, String table, Map<String, Object?> row) =>
      into.putIfAbsent(table, () => []).add(row);
}

/// Plans a merge of [backup] into [current] (BAK-3). Records match by ID.
/// Records only in the backup are added; when both sides have a record, the
/// later `updated_at` wins, deletions included. An occurrence handled on both
/// sides keeps this device's record, and the backup's transaction for it is
/// left out, so a recurring transaction never posts twice (RCR-4).
MergePlan planMerge(BackupTables current, BackupTables backup) {
  final plan = MergePlan();

  final handled = {
    for (final row in current['recurring_occurrences'] ?? const [])
      _recordKey('recurring_occurrences', row): row,
  };
  final duplicatePosts = <Object?>{};
  for (final row in backup['recurring_occurrences'] ?? const []) {
    final existing = handled[_recordKey('recurring_occurrences', row)];
    if (existing == null) {
      plan._add(plan.inserts, 'recurring_occurrences', row);
      continue;
    }
    plan.unchanged++;
    final posted = row['transaction_id'];
    if (posted != null && posted != existing['transaction_id']) {
      duplicatePosts.add(posted);
    }
  }

  for (final table in backupTableNames) {
    if (table == 'recurring_occurrences') continue;
    final byId = {for (final row in current[table] ?? const []) row['id']: row};
    for (final row in backup[table] ?? const []) {
      final existing = byId[row['id']];
      if (existing == null) {
        if (table == 'transactions' && duplicatePosts.contains(row['id'])) {
          plan.unchanged++;
        } else {
          plan._add(plan.inserts, table, row);
        }
      } else if (_updatedAt(row).isAfter(_updatedAt(existing)) &&
          !_sameContent(row, existing)) {
        plan._add(plan.updates, table, row);
      } else {
        plan.unchanged++;
      }
    }
  }
  return plan;
}

/// Whether two versions of a record differ only in their timestamps, like
/// the built-in defaults created on two devices.
bool _sameContent(Map<String, Object?> a, Map<String, Object?> b) =>
    a.length == b.length &&
    a.keys.every(
      (key) => key == 'created_at' || key == 'updated_at' || a[key] == b[key],
    );

/// The outcome of a restore, for the message shown afterwards.
class RestoreResult {
  const RestoreResult.replaced(this.transactionCount)
    : mode = RestoreMode.replace,
      added = 0,
      updated = 0,
      unchanged = 0;

  RestoreResult.merged(MergePlan plan)
    : mode = RestoreMode.merge,
      added = plan.added,
      updated = plan.updated,
      unchanged = plan.unchanged,
      transactionCount = 0;

  final RestoreMode mode;
  final int added;
  final int updated;
  final int unchanged;

  /// Transactions restored by a replace.
  final int transactionCount;
}

Object? _recordKey(String table, Map<String, Object?> row) =>
    table == 'recurring_occurrences'
    ? '${row['rule_id']}@${row['date']}'
    : row['id'];

DateTime _updatedAt(Map<String, Object?> row) =>
    DateTime.parse(row['updated_at']! as String);
