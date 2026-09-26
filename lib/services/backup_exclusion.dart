import 'dart:io' show Directory;

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath;

import 'attachment_service.dart';
import 'backup_files.dart';

/// Shared with `app_lock.dart` and `SecurityBridge.swift`.
const _securityChannelName = 'com.oasisforge.monthlyexpenses/security';

/// Marks the directories holding the database, the attachments and the
/// automatic backups as excluded from iCloud and computer backups (BAK-8).
///
/// Android is kept out of its own automatic backup through the manifest
/// (`allowBackup="false"`), but iOS backs up the whole of Documents and
/// Application Support to iCloud, and to a computer over cable, by
/// default — which would otherwise carry every one of those directories
/// along, even though the privacy policy promises the records never leave
/// the device on their own. `main.dart` calls this once at startup, on iOS
/// only; excluding a directory covers everything already inside it and
/// anything added to it later (Apple's own `isExcludedFromBackup`
/// semantics), so this never has to single out a file created afterwards.
///
/// A failure along the way — the channel, or resolving a directory — is
/// logged and never allowed to stop the app from starting. The three
/// resolvers default to the app's real directories (`db_helper.dart`'s
/// `getDatabasesPath()`, `attachment_service.dart`'s attachments folder,
/// `backup_files.dart`'s automatic-backups folder); tests pass their own so
/// this never has to touch a real platform channel to be checked.
Future<void> excludeDataFromDeviceBackup({
  Future<String> Function()? databasesPath,
  Future<Directory> Function()? attachmentsDirectory,
  Future<Directory> Function()? backupsDirectory,
  MethodChannel? channel,
}) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
  try {
    final paths = [
      await (databasesPath ?? getDatabasesPath)(),
      (await (attachmentsDirectory ?? DeviceAttachmentFiles().directory)())
          .path,
      (await (backupsDirectory ?? DeviceBackupFiles().directory)()).path,
    ];
    await (channel ?? const MethodChannel(_securityChannelName))
        .invokeMethod<void>('excludeFromBackup', paths);
  } catch (e) {
    // Nothing here may ever block startup (BAK-8): a rare failure just
    // means this run's directories go unmarked, which the next launch
    // tries again.
    debugPrint(
      'excludeDataFromDeviceBackup: could not exclude data from '
      'device backup: $e',
    );
  }
}
