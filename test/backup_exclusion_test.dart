import 'dart:io';

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/services/backup_exclusion.dart';

/// `excludeDataFromDeviceBackup` (BAK-8) keeps the database, the attachments
/// and the automatic backups out of iCloud and computer backups on iOS.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final channel = const MethodChannel(
    'com.oasisforge.monthlyexpenses/security',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  bool fail = false;

  setUp(() {
    calls = [];
    fail = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (fail) throw PlatformException(code: 'boom');
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  Future<String> db() async => '/documents';
  Future<Directory> attachments() async => Directory('/support/attachments');
  Future<Directory> backups() async => Directory('/support/backups');

  test('on iOS, marks the database, attachments and automatic-backups '
      'directories excluded from backup', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await excludeDataFromDeviceBackup(
      databasesPath: db,
      attachmentsDirectory: attachments,
      backupsDirectory: backups,
    );

    expect(calls.single.method, 'excludeFromBackup');
    expect(calls.single.arguments, [
      '/documents',
      '/support/attachments',
      '/support/backups',
    ]);
  });

  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ]) {
    test('on $platform, never sends anything', () async {
      debugDefaultTargetPlatformOverride = platform;

      await excludeDataFromDeviceBackup(
        databasesPath: db,
        attachmentsDirectory: attachments,
        backupsDirectory: backups,
      );

      expect(calls, isEmpty);
    });
  }

  test('a channel failure never throws, so it cannot hold up startup '
      '(main.dart)', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    fail = true;

    await expectLater(
      excludeDataFromDeviceBackup(
        databasesPath: db,
        attachmentsDirectory: attachments,
        backupsDirectory: backups,
      ),
      completes,
    );

    // It still tried, once, before the mock threw.
    expect(calls.single.method, 'excludeFromBackup');
  });

  test('a directory that fails to resolve never throws either, and nothing '
      'is sent for that run', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await expectLater(
      excludeDataFromDeviceBackup(
        databasesPath: db,
        attachmentsDirectory: () async => throw StateError('no plugin'),
        backupsDirectory: backups,
      ),
      completes,
    );

    expect(calls, isEmpty);
  });

  test('with no channel registered at all (an old build, or a test that '
      'never mocked it), it still never throws', () async {
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await expectLater(
      excludeDataFromDeviceBackup(
        databasesPath: db,
        attachmentsDirectory: attachments,
        backupsDirectory: backups,
      ),
      completes,
    );
  });
}
