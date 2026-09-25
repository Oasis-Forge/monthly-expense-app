import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Android manifest is not Dart and no widget test reaches it, so the one
/// thing that can go wrong here goes wrong silently.
///
/// `flutter_local_notifications` ships its receivers as Java classes and
/// declares none of them: its own manifest carries two permissions and
/// nothing else. An app that forgets to declare them still compiles, still
/// runs, and still registers its alarms — and every one of them fires into a
/// component that does not exist. No notification, no error, no log. That is
/// how every reminder in this app went missing until 24 September 2026.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();

  group('the Android manifest (NOTE-6, NUDGE-1, NUDGE-9)', () {
    for (final receiver in const [
      // Posts a scheduled notification when its alarm fires.
      'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
      // Handles a tap on a notification's action button.
      'com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver',
      // Lays the alarms again after a restart, which clears them.
      'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
    ]) {
      test('declares ${receiver.split('.').last}', () {
        expect(
          manifest,
          contains(receiver),
          reason:
              'Without this the plugin schedules alarms that fire into '
              'nothing, and no reminder is ever delivered.',
        );
      });
    }

    test('the boot receiver can hear a restart', () {
      expect(
        manifest,
        contains('android.permission.RECEIVE_BOOT_COMPLETED'),
        reason: 'NUDGE-9 promises reminders survive a reboot.',
      );
      expect(manifest, contains('android.intent.action.BOOT_COMPLETED'));
      // An app update clears alarms just as a reboot does.
      expect(manifest, contains('android.intent.action.MY_PACKAGE_REPLACED'));
    });

    test('none of the three is exported: they are ours alone', () {
      // Every receiver in this file is private; an exported one would let
      // any app on the phone post notifications as this one.
      expect(manifest.contains('android:exported="true"'), isTrue);
      final exportedTrue = 'android:exported="true"'
          .allMatches(manifest)
          .length;
      // Only MainActivity is exported, and it is an activity, not a receiver.
      expect(exportedTrue, 1);
    });

    test('the small icon is its own drawable, not the launcher icon', () {
      // Android keeps only the alpha of a notification's small icon, so the
      // full-colour launcher icon arrives as a blob or an outline.
      final service = File('lib/services/reminder_service.dart')
          .readAsStringSync();
      expect(service, contains("'@drawable/ic_notification'"));
      expect(
        service,
        isNot(contains("AndroidInitializationSettings('@mipmap")),
      );
      for (final density in const [
        'mdpi',
        'hdpi',
        'xhdpi',
        'xxhdpi',
        'xxxhdpi',
      ]) {
        expect(
          File('android/app/src/main/res/drawable-$density/ic_notification.png')
              .existsSync(),
          isTrue,
          reason: 'ic_notification.png is missing at $density',
        );
      }
    });

    // Release builds shrink away every resource no Java or XML refers to,
    // and a name passed from Dart counts as none. The icon was there in
    // every debug build and gone from every release one, and the plugin's
    // failure to find it stopped each launch from loading anything.
    test('keeps every drawable that Dart names through the shrinker', () {
      final keep = File('android/app/src/main/res/raw/keep.xml');
      expect(keep.existsSync(), isTrue, reason: 'res/raw/keep.xml is gone');
      final kept = keep.readAsStringSync();
      final named = <String>{
        for (final file in Directory('lib').listSync(recursive: true))
          if (file is File && file.path.endsWith('.dart'))
            for (final match in RegExp(
              r'@drawable/(\w+)',
            ).allMatches(file.readAsStringSync()))
              match.group(0)!,
      };
      expect(named, isNotEmpty);
      for (final drawable in named) {
        expect(kept, contains(drawable), reason: '$drawable is not kept');
      }
    });
  });
}
