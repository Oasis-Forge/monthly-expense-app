import 'dart:io';

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart'
    show databaseFactory, databaseFactoryOrNull, databaseFactorySqflitePlugin;

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

  test('on iOS, with no resolvers injected, uses the real database, '
      'attachments and automatic-backups directories', () async {
    // Every other test injects all three resolvers, so this is the only
    // one that exercises db_helper.dart's getDatabasesPath(),
    // DeviceAttachmentFiles().directory() and DeviceBackupFiles().directory()
    // themselves -- the part that actually carries BAK-8. Pointing one of
    // them at the wrong folder would fail no other test in this file.
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final tempDir = await Directory.systemTemp.createTemp(
      'backup_exclusion_test_',
    );
    addTearDown(() => tempDir.delete(recursive: true));

    final pathProviderChannel = const MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    final sqfliteChannel = const MethodChannel('com.tekartik.sqflite');
    final databasesPath = p.join(tempDir.path, 'databases');
    messenger.setMockMethodCallHandler(pathProviderChannel, (call) async {
      expect(call.method, 'getApplicationSupportDirectory');
      return tempDir.path;
    });
    messenger.setMockMethodCallHandler(sqfliteChannel, (call) async {
      expect(call.method, 'getDatabasesPath');
      return databasesPath;
    });
    // db_helper.dart's real default resolver is sqflite's own
    // getDatabasesPath(), which only reaches the channel above once
    // something has pointed sqflite's global factory at it. On a device
    // the generated plugin registrant does this before main() runs; a
    // plain `flutter test` never registers any plugin, so it is done here
    // instead.
    databaseFactory = databaseFactorySqflitePlugin;
    addTearDown(() {
      messenger.setMockMethodCallHandler(pathProviderChannel, null);
      messenger.setMockMethodCallHandler(sqfliteChannel, null);
      databaseFactoryOrNull = null;
    });

    await excludeDataFromDeviceBackup();

    expect(calls.single.method, 'excludeFromBackup');
    expect(calls.single.arguments, [
      databasesPath,
      p.join(tempDir.path, 'attachments'),
      p.join(tempDir.path, 'backups'),
    ]);
  });

  test('lib/main.dart still calls excludeDataFromDeviceBackup at startup', () {
    // Not reachable from a widget test (it runs before runApp, on iOS
    // only), so nothing else here would notice this call being deleted or
    // its result silently dropped instead of at least being unawaited.
    final main = File('lib/main.dart').readAsStringSync();
    expect(
      main,
      contains('unawaited(excludeDataFromDeviceBackup());'),
      reason:
          'BAK-8: this is the only call site. Losing it leaves the '
          'database, attachments and automatic backups unexcluded on '
          'iOS with no test failing.',
    );
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

  test('a directory that fails to resolve never throws, and does not stop '
      'the others from being excluded', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await expectLater(
      excludeDataFromDeviceBackup(
        databasesPath: db,
        attachmentsDirectory: () async => throw StateError('no plugin'),
        backupsDirectory: backups,
      ),
      completes,
    );

    expect(calls.single.method, 'excludeFromBackup');
    expect(calls.single.arguments, ['/documents', '/support/backups']);
  });

  test('when every directory fails to resolve, nothing is sent', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await expectLater(
      excludeDataFromDeviceBackup(
        databasesPath: () async => throw StateError('no plugin'),
        attachmentsDirectory: () async => throw StateError('no plugin'),
        backupsDirectory: () async => throw StateError('no plugin'),
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
