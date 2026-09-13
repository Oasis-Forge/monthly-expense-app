import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';

import '../db/db_helper.dart';
import '../models/backup.dart';
import '../providers/settings_provider.dart';
import 'backup_files.dart';

/// An automatic backup kept on the device, saved before a restore (BAK-2).
class KeptBackup {
  const KeptBackup(this.name, this.backup);

  final String name;
  final BackupData backup;
}

/// Creates, reads, and restores backups, and saves CSV exports
/// (BAK-1–BAK-6). After a restore, screens reload `TransactionProvider`.
class BackupService {
  /// Uses [db], or the app database when null. [files] defaults to the
  /// platform's file dialogs, [clock] to the current time, and [appVersion]
  /// to the installed package version.
  BackupService({
    DBHelper? db,
    BackupFiles? files,
    DateTime Function()? clock,
    Future<String> Function()? appVersion,
  }) : _db = db ?? DBHelper.instance,
       _files = files ?? DeviceBackupFiles(),
       _clock = clock ?? DateTime.now,
       _appVersion = appVersion ?? _packageVersion;

  /// How many automatic backups the device keeps (BAK-2).
  static const keepCount = 5;

  static final _keptName = RegExp(r'^auto-(\d+)\.json$');

  final DBHelper _db;
  final BackupFiles _files;
  final DateTime Function() _clock;
  final Future<String> Function() _appVersion;

  static Future<String> _packageVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  /// A backup of all current data and the settings that travel with it.
  Future<BackupData> create(SettingsProvider settings) async {
    return BackupData(
      schemaVersion: _db.version,
      createdAt: _clock().toUtc(),
      appVersion: await _appVersion(),
      settings: settings.backupValues,
      tables: await _db.exportTables(),
    );
  }

  /// Lets the user save a backup file, and records it for the reminder
  /// (BAK-7). False when the user cancels.
  Future<bool> saveBackup(SettingsProvider settings) async {
    final backup = await create(settings);
    final saved = await _files.save(
      'monthly-expenses-backup-${_fileDate(_clock())}.json',
      utf8.encode(backup.toJson()),
      mimeType: 'application/json',
    );
    if (saved) await settings.recordBackup();
    return saved;
  }

  /// Lets the user pick a backup file and reads it. Null when they cancel;
  /// throws a [BackupException] like [read].
  Future<BackupData?> openBackup() async {
    final bytes = await _files.open();
    return bytes == null ? null : read(bytes);
  }

  /// Reads a backup file and brings it to the current schema (BAK-4). Throws
  /// a [BackupException] when it isn't a valid backup or comes from a newer
  /// version of the app.
  Future<BackupData> read(List<int> bytes) async {
    final String source;
    try {
      source = utf8.decode(bytes);
    } on FormatException {
      throw const BackupException(BackupProblem.invalid);
    }
    final backup = BackupData.fromJson(source);
    if (backup.schemaVersion > _db.version) {
      throw const BackupException(BackupProblem.tooNew);
    }
    final tables = backup.schemaVersion < _db.version
        ? await _db.upgradeBackupTables(backup.tables, backup.schemaVersion)
        : backup.tables;
    return backup.withTables(
      normalizeTables(tables),
      schemaVersion: _db.version,
    );
  }

  /// Keeps an automatic backup of the current data, then restores [backup]
  /// (BAK-2, BAK-3). Replace also applies the backup's settings; Merge keeps
  /// this device's settings.
  Future<RestoreResult> restore(
    BackupData backup,
    RestoreMode mode,
    SettingsProvider settings,
  ) async {
    await keepCurrentData(settings);
    switch (mode) {
      case RestoreMode.replace:
        await _db.replaceAllData(backup.tables);
        await settings.restoreBackupValues(backup.settings);
        return RestoreResult.replaced(backup.transactionCount);
      case RestoreMode.merge:
        final plan = planMerge(await _db.exportTables(), backup.tables);
        await _db.applyMerge(plan);
        return RestoreResult.merged(plan);
    }
  }

  /// Saves an automatic backup in the app's folder and drops the oldest ones
  /// beyond [keepCount].
  Future<void> keepCurrentData(SettingsProvider settings) async {
    final backup = await create(settings);
    await _files.writeKept(
      'auto-${_clock().millisecondsSinceEpoch}.json',
      backup.toJson(),
    );
    for (final name in (await _keptNames()).skip(keepCount)) {
      await _files.deleteKept(name);
    }
  }

  /// Automatic backups, newest first. Unreadable files are left out.
  Future<List<KeptBackup>> keptBackups() async {
    final kept = <KeptBackup>[];
    for (final name in await _keptNames()) {
      try {
        final backup = await read(utf8.encode(await _files.readKept(name)));
        kept.add(KeptBackup(name, backup));
      } on BackupException {
        continue;
      }
    }
    return kept;
  }

  /// Lets the user save a CSV export (BAK-5). False when they cancel.
  Future<bool> saveCsv(String fileName, String csv) =>
      _files.save(fileName, utf8.encode(csv), mimeType: 'text/csv');

  Future<List<String>> _keptNames() async {
    final stamps = {
      for (final name in await _files.listKept())
        if (_keptName.firstMatch(name) case final match?)
          name: int.parse(match[1]!),
    };
    return stamps.keys.toList()
      ..sort((a, b) => stamps[b]!.compareTo(stamps[a]!));
  }

  static String _fileDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
