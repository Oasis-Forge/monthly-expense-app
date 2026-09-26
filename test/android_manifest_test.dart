import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_expense_app/services/reminder_service.dart';

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
      // The third, which lays the alarms again after a restart, is replaced
      // by the app's own ReminderBootReceiver: see the group below.
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

    test('none of the receivers is exported: they are ours alone', () {
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

  // After a restart the plugin's own boot receiver lays every cached
  // notification again at its original time, so a reminder whose time passed
  // while the phone was off fired the moment it was back, however late
  // (pr59_10). Dart does not run at boot; ReminderBootReceiver.kt stands in
  // for the plugin's receiver, drops the one-shots more than
  // passedReminderGrace overdue from the plugin's copy, and hands the rest
  // over. It is native, so these read the sources: no Dart test reaches it.
  group('a restart drops a reminder more than two hours overdue '
      '(NUDGE-9, NOTE-6, pr59_10)', () {
    const kotlinPath =
        'android/app/src/main/kotlin/com/oasisforge/monthlyexpenses/'
        'ReminderBootReceiver.kt';
    final kotlin = File(kotlinPath).readAsStringSync();
    final withoutComments = manifest.replaceAll(
      RegExp(r'<!--.*?-->', dotAll: true),
      '',
    );

    String? kotlinConst(String name) =>
        RegExp('const val $name = "([^"]*)"').firstMatch(kotlin)?.group(1);

    test('ReminderBootReceiver is declared, private, and hears a restart '
        'and an update', () {
      final receiver = RegExp(
        r'<receiver\s+android:name="\.ReminderBootReceiver"(.*?)</receiver>',
        dotAll: true,
      ).firstMatch(withoutComments)?.group(1);
      expect(
        receiver,
        isNotNull,
        reason: 'Without it nothing lays the reminders again after a restart.',
      );
      expect(receiver, contains('android:exported="false"'));
      // The same four actions the plugin's own receiver answers.
      for (final action in const [
        'android.intent.action.BOOT_COMPLETED',
        'android.intent.action.MY_PACKAGE_REPLACED',
        'android.intent.action.QUICKBOOT_POWERON',
        'com.htc.intent.action.QUICKBOOT_POWERON',
      ]) {
        expect(receiver, contains('<action android:name="$action"/>'));
      }
      // And the receiver itself drops only on those.
      for (final action in const [
        'Intent.ACTION_BOOT_COMPLETED',
        'Intent.ACTION_MY_PACKAGE_REPLACED',
        '"android.intent.action.QUICKBOOT_POWERON"',
        '"com.htc.intent.action.QUICKBOOT_POWERON"',
      ]) {
        expect(kotlin, contains(action));
      }
    });

    test("the plugin's own boot receiver is not declared", () {
      expect(
        withoutComments,
        isNot(contains('ScheduledNotificationBootReceiver')),
        reason:
            'Declared too, it would lay the overdue reminders again at boot '
            'whatever ReminderBootReceiver dropped, and fire them late.',
      );
    });

    test('drops first, then hands over to the plugin to lay the rest', () {
      expect(
        kotlin,
        contains(
          'class ReminderBootReceiver : ScheduledNotificationBootReceiver()',
        ),
      );
      final onReceive = RegExp(
        r'override fun onReceive\(context: Context, intent: Intent\) \{'
        r'(.*?)\r?\n  \}',
        dotAll: true,
      ).firstMatch(kotlin)?.group(1);
      expect(
        onReceive,
        isNotNull,
        reason: 'ReminderBootReceiver has no onReceive',
      );
      final drop = onReceive!.indexOf('StaleReminders.drop(context)');
      final handOver = onReceive.indexOf('super.onReceive(context, intent)');
      expect(drop, isNonNegative, reason: 'nothing is dropped');
      expect(handOver, isNonNegative, reason: 'nothing is laid again');
      expect(drop, lessThan(handOver));
    });

    test('the Kotlin grace is passedReminderGrace, to the millisecond', () {
      final match = RegExp(r'const val PASSED_REMINDER_GRACE_MS = ([\d_]+)L')
          .firstMatch(kotlin);
      expect(match, isNotNull, reason: 'PASSED_REMINDER_GRACE_MS is gone');
      expect(
        int.parse(match!.group(1)!.replaceAll('_', '')),
        passedReminderGrace.inMilliseconds,
        reason:
            'A restart and a reschedule from Dart must drop a passed '
            'reminder at the same age (NUDGE-9, NOTE-6).',
      );
      // Strictly more than the grace, as shouldCancelPassedReminder has it.
      expect(kotlin, contains('nowMillis - due > PASSED_REMINDER_GRACE_MS'));
    });

    test('is checked against the flutter_local_notifications version '
        'pubspec.lock uses', () {
      final lock = File('pubspec.lock').readAsStringSync();
      final locked = RegExp(
        r'^  flutter_local_notifications:\r?$(.*?)^    version: "([^"]+)"',
        multiLine: true,
        dotAll: true,
      ).firstMatch(lock)?.group(2);
      expect(locked, isNotNull);
      expect(
        kotlinConst('CHECKED_PLUGIN_VERSION'),
        locked,
        reason:
            'flutter_local_notifications moved to $locked. '
            'ReminderBootReceiver.kt reads that plugin\'s private cache of '
            'scheduled notifications, so recheck its format in the new '
            "version's Android source (FlutterLocalNotificationsPlugin."
            'rescheduleNotifications and loadScheduledNotifications, '
            'NotificationDetails, ScheduledNotificationBootReceiver) before '
            'raising CHECKED_PLUGIN_VERSION to match.',
      );
    });

    // The locked version's own Android source, wherever pub put it: the
    // package config pub get writes names every package's root.
    Directory pluginRoot() {
      final config = File('.dart_tool/package_config.json');
      final packages =
          (jsonDecode(config.readAsStringSync())
                  as Map<String, dynamic>)['packages']
              as List<dynamic>;
      final plugin =
          packages.cast<Map<String, dynamic>>().singleWhere(
                (p) => p['name'] == 'flutter_local_notifications',
              )['rootUri']
              as String;
      return Directory.fromUri(
        config.absolute.uri.resolve(plugin.endsWith('/') ? plugin : '$plugin/'),
      );
    }

    String pluginJava(String path) => File.fromUri(
      pluginRoot().uri.resolve(
        'android/src/main/java/com/dexterous/flutterlocalnotifications/$path',
      ),
    ).readAsStringSync();

    // A method of FlutterLocalNotificationsPlugin.java, from its signature
    // to the closing brace at its indent; any run of whitespace in the
    // signature matches any other.
    String pluginMethod(String signature) {
      final match = RegExp(
        '${signature.split(' ').map(RegExp.escape).join(r'\s+')}'
        r'(.*?)\r?\n  \}',
        dotAll: true,
      ).firstMatch(pluginJava('FlutterLocalNotificationsPlugin.java'));
      expect(match, isNotNull, reason: '$signature is gone');
      return match!.group(1)!;
    }

    // One function of StaleReminders, up to the next declaration at its
    // indent (or the end of the file).
    String kotlinFun(String name) {
      final start = kotlin.indexOf(RegExp('fun $name\\('));
      expect(start, isNonNegative, reason: 'StaleReminders.$name is gone');
      final end = kotlin.indexOf(RegExp(r'\n  [^ }\r\n]'), start);
      return kotlin.substring(start, end < 0 ? kotlin.length : end);
    }

    test("reads the plugin's cache where that version keeps it", () {
      final plugin = pluginJava('FlutterLocalNotificationsPlugin.java');
      final name = RegExp(r'String SCHEDULED_NOTIFICATIONS = "([^"]+)";')
          .firstMatch(plugin)
          ?.group(1);
      expect(name, isNotNull);
      final load = RegExp(
        r'ArrayList<NotificationDetails> loadScheduledNotifications\('
        r'Context context\) \{(.*?)\r?\n  \}',
        dotAll: true,
      ).firstMatch(plugin)?.group(1);
      expect(load, isNotNull, reason: 'loadScheduledNotifications is gone');
      expect(
        load,
        contains(
          'getSharedPreferences(SCHEDULED_NOTIFICATIONS, '
          'Context.MODE_PRIVATE)',
        ),
      );
      expect(load, contains('getString(SCHEDULED_NOTIFICATIONS, null)'));
      // A JSON array of NotificationDetails.
      expect(load, contains('TypeToken<ArrayList<NotificationDetails>>'));
      expect(kotlinConst('PLUGIN_PREFS'), name);
      expect(kotlinConst('PLUGIN_KEY'), name);

      // Gson writes each field under its Java name: no naming policy, and
      // the class is kept whole, so R8 does not rename them in a release.
      final gson = RegExp(
        r'static Gson buildGson\(\) \{(.*?)\r?\n  \}',
        dotAll: true,
      ).firstMatch(plugin)?.group(1);
      expect(gson, isNotNull);
      expect(gson, isNot(contains('FieldNaming')));
      final details = pluginJava('models/NotificationDetails.java');
      expect(
        details,
        contains(RegExp(r'@Keep\s+public class NotificationDetails')),
      );
      final fields = {
        for (final match in RegExp(r'"([a-z][A-Za-z]*)"').allMatches(kotlin))
          match.group(1)!,
      };
      expect(fields, containsAll(['scheduledDateTime', 'timeZoneName']));
      for (final field in fields) {
        expect(
          details,
          contains(RegExp('public [A-Za-z<>]+ $field;')),
          reason: 'NotificationDetails has no field $field',
        );
      }
    });

    // What the plugin itself does, which the receiver relies on; the tests
    // after it hold the receiver's Kotlin to the same.
    test('the plugin still lays repeats, zoned and plain reminders as the '
        'receiver assumes', () {
      final plugin = pluginJava('FlutterLocalNotificationsPlugin.java');
      final reschedule = RegExp(
        r'static void rescheduleNotifications\(Context context\) \{(.*?)'
        r'\r?\n  \}',
        dotAll: true,
      ).firstMatch(plugin)?.group(1);
      expect(reschedule, isNotNull, reason: 'rescheduleNotifications is gone');
      // Repeating first, then zoned, then the older plain epoch time.
      final repeat = reschedule!.indexOf(
        'notificationDetails.repeatInterval != null',
      );
      final zoned = reschedule.indexOf(
        'notificationDetails.timeZoneName != null',
      );
      expect(repeat, isNonNegative);
      expect(zoned, greaterThan(repeat));
      expect(
        plugin,
        contains('LocalDateTime.parse(notificationDetails.scheduledDateTime)'),
      );
      expect(plugin, contains('ZoneId.of(notificationDetails.timeZoneName)'));
      expect(plugin, contains('notificationDetails.millisecondsSinceEpoch'));
      // What the plugin's own receiver does is all the handover relies on.
      final boot = pluginJava('ScheduledNotificationBootReceiver.java');
      expect(
        boot,
        contains(
          'public class ScheduledNotificationBootReceiver extends '
          'BroadcastReceiver',
        ),
      );
      expect(
        boot,
        contains('FlutterLocalNotificationsPlugin.rescheduleNotifications'),
      );
    });

    // Dropping a notification that repeats would end the series for good:
    // nothing would lay the next one.
    test('keeps every notification the plugin treats as repeating', () {
      // What the plugin lays again as a repeat after a restart...
      final reschedule = pluginMethod(
        'static void rescheduleNotifications(Context context) {',
      );
      final repeatBranch = RegExp(
        r'if \((.*?)\) \{\s*repeatNotification\(',
        dotAll: true,
      ).firstMatch(reschedule)?.group(1);
      expect(repeatBranch, isNotNull, reason: 'the repeat branch is gone');
      // ...and what it lays the next of once one fires: every branch but
      // the last, which takes a one-shot out of its copy.
      final next = pluginMethod(
        'static void scheduleNextNotification(Context context, '
        'NotificationDetails notificationDetails) {',
      );
      final oneShot = next.lastIndexOf(
        RegExp(
          r'\} else \{\s*'
          r'removeNotificationFromCache\(context, notificationDetails\.id\);',
        ),
      );
      expect(oneShot, isNonNegative, reason: 'a fired one-shot is kept');
      final repeating = {
        for (final source in [repeatBranch!, next.substring(0, oneShot)])
          for (final match in RegExp(
            r'notificationDetails\.(\w+) != null',
          ).allMatches(source))
            match.group(1)!,
      };
      expect(
        repeating,
        containsAll(const [
          'repeatInterval',
          'repeatIntervalMilliseconds',
          'matchDateTimeComponents',
          'scheduledNotificationRepeatFrequency',
        ]),
      );

      final listed = RegExp(
        r'val REPEAT_FIELDS = listOf\((.*?)\)',
        dotAll: true,
      ).firstMatch(kotlin)?.group(1);
      expect(listed, isNotNull, reason: 'REPEAT_FIELDS is gone');
      final kept = {
        for (final match in RegExp(r'"(\w+)"').allMatches(listed!))
          match.group(1)!,
      };
      for (final field in repeating) {
        expect(
          kept,
          contains(field),
          reason:
              'The plugin repeats a notification with $field set; dropped at '
              'boot, its series would end.',
        );
      }
      expect(
        kotlinFun('isStale'),
        contains(
          'if (REPEAT_FIELDS.any { entry.has(it) && !entry.isNull(it) }) '
          'return false',
        ),
      );
    });

    test("reads a reminder's time the way the plugin lays it", () {
      final due = kotlinFun('dueMillis');
      // Zoned first, in its own zone, then the older plain epoch time, as
      // the plugin's rescheduleNotifications has them.
      final zoned = due.indexOf(
        'entry.has("timeZoneName") && !entry.isNull("timeZoneName")',
      );
      final plain = due.indexOf(
        'entry.has("millisecondsSinceEpoch") && '
        '!entry.isNull("millisecondsSinceEpoch")',
      );
      expect(zoned, isNonNegative, reason: 'a zoned time is not read as one');
      expect(plain, greaterThan(zoned));
      for (final part in const [
        'LocalDateTime.parse(entry.getString("scheduledDateTime"))',
        'ZoneId.of(entry.getString("timeZoneName"))',
        '.toInstant().toEpochMilli()',
        'entry.getLong("millisecondsSinceEpoch")',
        // A time it cannot read keeps the reminder (isStale).
        'else -> null',
      ]) {
        expect(due, contains(part));
      }
      // Which is how the plugin lays each of them.
      final zonedLaid = pluginMethod(
        'private static void zonedScheduleNotification( Context context,',
      );
      expect(
        zonedLaid,
        contains('LocalDateTime.parse(notificationDetails.scheduledDateTime)'),
      );
      expect(
        zonedLaid,
        contains('ZoneId.of(notificationDetails.timeZoneName)'),
      );
      expect(
        pluginMethod(
          'private static void scheduleNotification( Context context,',
        ),
        contains('notificationDetails.millisecondsSinceEpoch'),
      );
    });

    // Swapping the two branches would lose every reminder still due.
    test('drops only the stale ones, and saves everything else', () {
      expect(
        kotlinFun('withoutStale'),
        allOf(
          contains(
            'if (entry is JSONObject && isStale(entry, nowMillis)) '
            'dropped.add(entry) else kept.put(entry)',
          ),
          // Nothing is written when nothing is stale.
          contains(
            'return if (dropped.isEmpty()) null '
            'else Pruned(kept.toString(), dropped)',
          ),
        ),
      );
      expect(
        kotlinFun('isStale'),
        contains('val due = dueMillis(entry) ?: return false'),
        reason: 'a time it cannot read keeps the reminder',
      );
      expect(kotlinFun('drop'), contains('putString(PLUGIN_KEY, pruned.kept)'));
    });

    // An app update keeps the alarms a restart clears, and a one-shot the
    // phone held back (Doze, a seldom-opened app's standby bucket) can still
    // be armed hours after its time. Out of the plugin's copy but still
    // armed, it would fire that late anyway, so the receiver disarms it too.
    test("disarms a dropped reminder's alarm the way the plugin cancels one "
        '(NUDGE-9, pr59_10)', () {
      // The alarm's PendingIntent: the plugin's receiver, no action or data
      // (extras do not count when Android matches one), request code the
      // notification's id, and immutable from API 23, below this app's
      // minSdk.
      final zoned = pluginMethod(
        'private static void zonedScheduleNotification( Context context,',
      );
      expect(
        zoned,
        contains(
          'Intent notificationIntent = new Intent(context, '
          'ScheduledNotificationReceiver.class);',
        ),
      );
      expect(zoned, isNot(contains('notificationIntent.set')));
      expect(
        zoned,
        contains(
          'getBroadcastPendingIntent(context, notificationDetails.id, '
          'notificationIntent)',
        ),
      );
      final pending = pluginMethod(
        'private static PendingIntent getBroadcastPendingIntent('
        'Context context, int id, Intent intent) {',
      );
      expect(pending, contains('flags |= PendingIntent.FLAG_IMMUTABLE;'));
      expect(
        pending,
        contains('PendingIntent.getBroadcast(context, id, intent, flags)'),
      );
      // The plugin's own cancel rebuilds it the same way.
      final cancel = pluginMethod(
        'private void cancelNotification(Integer id, String tag) {',
      );
      expect(
        cancel,
        contains(
          'new Intent(applicationContext, ScheduledNotificationReceiver.class)',
        ),
      );
      expect(cancel, contains('alarmManager.cancel(pendingIntent)'));

      // And the receiver does the same, finding rather than making one.
      expect(
        kotlin,
        contains('Intent(context, ScheduledNotificationReceiver::class.java)'),
      );
      expect(
        kotlin,
        contains(
          'PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE',
        ),
      );
      expect(kotlin, contains('as AlarmManager).cancel(pending)'));
      // Once the copy no longer has them: still in it, the plugin would lay
      // them again straight after and undo it.
      final drop = kotlinFun('drop');
      final saved = drop.indexOf('.commit()');
      final disarmed = drop.indexOf('cancelAlarm(context, it)');
      expect(saved, isNonNegative);
      expect(disarmed, greaterThan(saved));
      expect(drop, contains('for (entry in pruned.dropped)'));
    });
  });

  // Nothing here reruns on its own if it silently regresses: no test in the
  // suite reads allowBackup, dataExtractionRules, or the cloud-backup
  // exclusions, so a manifest edit or a regenerated platform template could
  // reopen decision 37 (BAK-8) with every other test still green
  // (rules-11-13-20-21#5).
  group('Android\'s own backup stays off (BAK-8, BAK-6)', () {
    test('allowBackup is false, and points at the extraction rules', () {
      expect(
        manifest,
        contains('android:allowBackup="false"'),
        reason:
            'Without this, Android copies the database and the settings to '
            "the user's Google Drive by itself and hands them to whoever "
            'next installs the app under that account (BAK-8).',
      );
      expect(
        manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
        reason:
            'The cloud-backup exclusions below only apply if the '
            'manifest points to them.',
      );
    });

    test('every domain is excluded from cloud backup', () {
      final rules = File(
        'android/app/src/main/res/xml/data_extraction_rules.xml',
      ).readAsStringSync();
      final cloudBackup = RegExp(
        r'<cloud-backup>(.*?)</cloud-backup>',
        dotAll: true,
      ).firstMatch(rules)?.group(1);
      expect(
        cloudBackup,
        isNotNull,
        reason: 'No <cloud-backup> block in data_extraction_rules.xml.',
      );
      for (final domain in const [
        'root',
        'file',
        'database',
        'sharedpref',
        'external',
      ]) {
        // Not just that the domain is mentioned: an <include> for it, or an
        // <exclude> narrowed to less than the whole domain, would send that
        // domain to Drive and still pass a bare `contains('domain="...')`
        // (rules-11-13-20-21#5).
        expect(
          cloudBackup,
          contains('<exclude domain="$domain" path="."'),
          reason:
              '$domain is not fully excluded from cloud backup '
              '(BAK-8, BAK-6).',
        );
      }
      expect(
        cloudBackup,
        isNot(contains('<include')),
        reason:
            'An <include> would send that domain to Drive, exactly '
            'what decision 37 (BAK-8) refused.',
      );
    });
  });

  // The ad SDK reads its manifest/plist flags before Dart ever runs, and by
  // default it starts sending app-measurement events to Google immediately
  // at process start — before AdsProvider.start() ever calls
  // MobileAds.instance.initialize(), which is gated on setup, the walkthrough
  // and consent (ADS-4, ADS-5). Without the delay flags below, that native
  // auto-start happens on every launch, for every user, including someone
  // who bought "Remove ads" — which docs/privacy-policy.md promises never
  // starts the ad software at all (ADS-6, ADS-8, PAY-1).
  group('the ad SDK waits for initialize() (ADS-4, ADS-5, ADS-6, PAY-1)', () {
    test('Android delays app measurement', () {
      expect(
        manifest,
        contains(
          RegExp(
            r'com\.google\.android\.gms\.ads\.DELAY_APP_MEASUREMENT_INIT"\s*'
            r'android:value="true"',
          ),
        ),
        reason:
            'Without DELAY_APP_MEASUREMENT_INIT, the ad SDK sends '
            'user-level events to Google at app launch, before setup, the '
            'walkthrough and consent, and even for someone who bought '
            '"Remove ads".',
      );
    });

    test('iOS delays app measurement', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(
        plist,
        contains(RegExp(r'<key>GADDelayAppMeasurementInit</key>\s*<true\s*/>')),
        reason:
            'Without GADDelayAppMeasurementInit, the ad SDK sends '
            'user-level events to Google at app launch, before setup, the '
            'walkthrough and consent, and even for someone who bought '
            '"Remove ads".',
      );
    });
  });

  test('no XML comment under android/app/src/main contains "--", which '
      'makes the file unparseable and fails every Android build', () {
    final files = Directory('android/app/src/main')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.xml'));
    final comment = RegExp(r'<!--(.*?)-->', dotAll: true);
    final offenders = [
      for (final file in files)
        for (final match in comment.allMatches(file.readAsStringSync()))
          if (match.group(1)!.contains('--')) file.path,
    ];
    expect(files, isNotEmpty);
    expect(offenders, isEmpty);
  });

  // Once the process has been killed, Recents and the launcher icon recreate
  // MainActivity with the intent that first started the task, so a shortcut,
  // a widget button or a tapped notification ran again on every such return
  // (pr57_9). It was seen on the emulator; no widget test can reach it.
  test('MainActivity drops a replayed launch before any plugin reads it '
      '(NAV-8, WID-3, NOTE-6)', () {
    final activity = File(
      'android/app/src/main/kotlin/com/oasisforge/monthlyexpenses/'
      'MainActivity.kt',
    ).readAsStringSync();
    final onCreate = RegExp(
      r'override fun onCreate\(savedInstanceState: Bundle\?\) \{(.*?)\r?\n  \}',
      dotAll: true,
    ).firstMatch(activity)?.group(1);
    expect(onCreate, isNotNull, reason: 'MainActivity has no onCreate');
    expect(onCreate, contains('savedInstanceState != null'));
    expect(onCreate, contains('FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY'));
    // The swap has to come first: the plugins read the intent while
    // super.onCreate attaches them.
    final swap = onCreate!.indexOf('intent = ');
    expect(swap, isNonNegative, reason: 'the intent is never replaced');
    expect(swap, lessThan(onCreate.indexOf('super.onCreate')));
  });
}
