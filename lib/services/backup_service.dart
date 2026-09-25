import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../db/db_helper.dart';
import '../models/backup.dart';
import '../providers/settings_provider.dart';
import 'attachment_service.dart';
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
    AttachmentService? attachments,
  }) : _db = db ?? DBHelper.instance,
       _files = files ?? DeviceBackupFiles(),
       _clock = clock ?? DateTime.now,
       _appVersion = appVersion ?? _packageVersion,
       _attachments = attachments ?? AttachmentService();

  /// How many automatic backups the device keeps (BAK-2).
  static const keepCount = 5;

  /// What the JSON is called inside a zip backup, and the folder its
  /// attachments sit in (ATT-6).
  static const backupEntry = 'backup.json';
  static const attachmentsEntry = 'attachments';

  static final _keptName = RegExp(r'^auto-(\d+)\.json$');

  final DBHelper _db;
  final BackupFiles _files;
  final DateTime Function() _clock;
  final Future<String> Function() _appVersion;
  final AttachmentService _attachments;

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
    final names = backup.attachmentNames;
    final fileName = 'monthly-expenses-backup-${_fileDate(_clock())}';
    // With attachments the backup is a zip; without them it stays the plain
    // JSON file older versions also wrote (ATT-6, BAK-1).
    final saved = names.isEmpty
        ? await _files.save(
            '$fileName.json',
            utf8.encode(backup.toJson()),
            mimeType: 'application/json',
          )
        : await _files.save(
            '$fileName.zip',
            await _zip(backup, names),
            mimeType: 'application/zip',
          );
    if (saved) await settings.recordBackup();
    return saved;
  }

  /// How much the attachments would add to a backup, in bytes (ATT-6).
  Future<int> attachmentBytes() => _attachments.totalBytes();

  Future<Uint8List> _zip(BackupData backup, Set<String> names) async {
    final archive = Archive()
      ..add(ArchiveFile.string(backupEntry, backup.toJson()));
    for (final name in names) {
      // A file that has gone missing is left out rather than refused (ATT-7).
      if (!await _attachments.exists(name)) continue;
      archive.add(
        ArchiveFile.bytes(
          '$attachmentsEntry/$name',
          await _attachments.read(name),
        ),
      );
    }
    return ZipEncoder().encodeBytes(archive);
  }

  /// Lets the user pick a backup file and reads it. Null when they cancel;
  /// throws a [BackupException] like [read].
  Future<BackupData?> openBackup() async {
    final bytes = await _files.open();
    return bytes == null ? null : read(bytes);
  }

  /// Lets the user pick a file and reads it as text, for a CSV import
  /// (IMP-1). Null when they cancel.
  Future<String?> openText() async {
    final bytes = await _files.open();
    if (bytes == null) return null;
    try {
      return utf8.decode(bytes);
    } on FormatException {
      // A spreadsheet saved in the system's own code page. Latin-1 decodes
      // anything, and keeps the separators, dates, and digits intact; at
      // worst an accented name comes through wrong, which the user can see
      // on the preview.
      return latin1.decode(bytes);
    }
  }

  /// Reads a backup file and brings it to the current schema (BAK-4). Throws
  /// a [BackupException] when it isn't a valid backup or comes from a newer
  /// version of the app.
  Future<BackupData> read(List<int> bytes) async {
    final String source;
    var files = const <String, List<int>>{};
    try {
      if (_isZip(bytes)) {
        final unzipped = _unzip(bytes);
        source = unzipped.json;
        files = unzipped.files;
      } else {
        source = utf8.decode(bytes);
      }
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
    return backup
        .withTables(normalizeTables(tables), schemaVersion: _db.version)
        .withFiles(files);
  }

  static bool _isZip(List<int> bytes) =>
      bytes.length > 4 && bytes[0] == 0x50 && bytes[1] == 0x4b;

  /// The JSON and the attachment files inside a zip backup (ATT-6).
  ({String json, Map<String, List<int>> files}) _unzip(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final files = <String, List<int>>{};
    String? json;
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final content = file.readBytes() ?? const <int>[];
      if (file.name == backupEntry) {
        json = utf8.decode(content);
      } else if (file.name.startsWith('$attachmentsEntry/')) {
        // A zip entry name is untrusted (it need not come from this app's
        // own encoder, which is the only thing that would have rewritten a
        // `\`-separated traversal to `/`): keep only names that are this
        // app's own uuid.ext pattern, never a path, so a crafted backup
        // can't write outside the attachments folder (ATT-2,
        // data-integrity#10).
        final name = file.name.split('/').last;
        if (isSafeAttachmentName(name)) files[name] = content;
      }
    }
    if (json == null) throw const BackupException(BackupProblem.invalid);
    return (json: json, files: files);
  }

  /// Keeps an automatic backup of the current data, then restores [backup]
  /// (BAK-2, BAK-3). Replace also applies the backup's settings; Merge keeps
  /// this device's settings.
  ///
  /// Writes the attachment files before committing either the database or
  /// the settings: if a file write fails part-way through (a full disk, a
  /// large zip), nothing has been committed yet, so the caller's failure
  /// path finds the data exactly as it was rather than a database that
  /// already holds the backup while providers still hold the old data
  /// (BAK-2, ATT-6, data-integrity#8).
  Future<RestoreResult> restore(
    BackupData backup,
    RestoreMode mode,
    SettingsProvider settings,
  ) async {
    await keepCurrentData(settings);
    switch (mode) {
      case RestoreMode.replace:
        await _writeFiles(backup);
        await _db.replaceAllData(backup.tables);
        await settings.restoreBackupValues(backup.settings);
        return RestoreResult.replaced(backup.transactionCount);
      case RestoreMode.merge:
        final plan = planMerge(await _db.exportTables(), backup.tables);
        await _writeFiles(backup);
        await _db.applyMerge(plan);
        return RestoreResult.merged(plan);
    }
  }

  /// Writes the attachments a zip backup carried (ATT-6). Files belonging to
  /// data that Replace overwrote stay where they are: the automatic backup
  /// taken first is JSON only, so deleting them would leave it unrestorable.
  Future<void> _writeFiles(BackupData backup) async {
    for (final MapEntry(key: name, value: bytes) in backup.files.entries) {
      await _attachments.write(name, bytes);
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
