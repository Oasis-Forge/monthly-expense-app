import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `SecurityBridge.swift` is not Dart and no widget test reaches it, so
/// these read the source directly (the pattern in `android_manifest_test.dart`
/// for the same reason on the Android side).
void main() {
  // Normalized to \n: the file is checked out with \r\n line endings, and
  // every literal below is written with \n.
  final bridge = File('ios/Runner/SecurityBridge.swift')
      .readAsStringSync()
      .replaceAll('\r\n', '\n');

  group('excluding backup-covered directories from iCloud and computer '
      'backups (BAK-8)', () {
    test('handles excludeFromBackup on the security channel', () {
      expect(bridge, contains('case "excludeFromBackup":'));
    });

    test('sets isExcludedFromBackup, the actual key that keeps a directory '
        'out of an iCloud or computer backup', () {
      expect(bridge, contains('resourceValues.isExcludedFromBackup = true'));
      expect(bridge, contains('setResourceValues'));
    });

    test('a path that fails is logged and skipped, never thrown back to '
        'Dart: one bad directory must not stop the rest, or startup', () {
      final method = bridge.substring(
        bridge.indexOf('private func excludeFromBackup'),
      );
      // The per-path work is inside a do/catch, and the catch only logs.
      expect(method, contains('do {'));
      expect(method, contains('} catch {'));
      expect(method, contains('NSLog('));
      // The handler always answers with success regardless of what
      // excludeFromBackup found, the same as "uncover" below: this call
      // has no way to report a partial failure back to Dart, by design.
      final handler = bridge.substring(
        bridge.indexOf('case "excludeFromBackup":'),
      );
      expect(
        handler,
        contains(
          'case "excludeFromBackup":\n'
          '        self?.excludeFromBackup((call.arguments as? [String]) '
          '?? [])\n'
          '        result(nil)',
        ),
      );
    });
  });

  group('lifting the privacy cover once Dart confirms it is safe to '
      '(LOCK-1, LOCK-2)', () {
    test('uncover still removes the cover directly, unchanged by the '
        'exclusion work added beside it', () {
      expect(
        bridge,
        contains(
          'case "uncover":\n'
          '        self?.removeCover()\n'
          '        result(nil)',
        ),
      );
    });

    test('the 1 s fallback timer is still armed on didBecomeActive, as a '
        'backstop for a build or a path that never calls uncover', () {
      expect(bridge, contains('uncoverFallback: TimeInterval = 1.0'));
      expect(bridge, contains('@objc private func didBecomeActive()'));
      final didBecomeActive = bridge.substring(
        bridge.indexOf('@objc private func didBecomeActive()'),
      );
      expect(didBecomeActive, contains('Timer.scheduledTimer'));
      expect(didBecomeActive, contains('self?.removeCover()'));
    });
  });
}
