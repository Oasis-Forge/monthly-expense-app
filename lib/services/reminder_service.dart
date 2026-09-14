import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../models/note.dart';

/// A note's reminder notification was tapped: the note's ID, or null when
/// there's nothing pending. A top-level listener opens the note through the
/// lock (NOTE-6, LOCK-2).
final ValueNotifier<String?> tappedNoteId = ValueNotifier(null);

/// A stable notification ID for [noteId]. Notification IDs are 32-bit ints,
/// so this folds the UUID's hash into that range.
int reminderNotificationId(String noteId) => noteId.hashCode & 0x7fffffff;

/// Schedules and cancels the local notification for a note's reminder
/// (NOTE-6). Tests use a fake instead of touching the device.
abstract class ReminderService {
  /// Asks for notification permission, if the platform needs it. Call this
  /// only when the user sets a reminder for the first time (NOTE-6).
  Future<bool> requestPermission();

  /// Schedules [note]'s reminder, replacing any earlier one for it, in
  /// [locale]. Does nothing (and cancels any existing one) when the note has
  /// no reminder, is done, is deleted, or the reminder time has passed. With
  /// [appLockOn], the notification names only the app, not the note's text
  /// (LOCK-2).
  Future<void> schedule(
    Note note, {
    required bool appLockOn,
    required Locale locale,
  });

  /// Cancels the note's reminder, if any.
  Future<void> cancel(Note note);
}

/// Does nothing. [TransactionProvider]'s default, so building one without
/// wiring up notifications (as most tests do) never touches the device;
/// `main.dart` passes a real [DeviceReminderService] instead.
class NoopReminderService implements ReminderService {
  const NoopReminderService();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> schedule(
    Note note, {
    required bool appLockOn,
    required Locale locale,
  }) async {}

  @override
  Future<void> cancel(Note note) async {}
}

/// Schedules real device notifications through `flutter_local_notifications`.
class DeviceReminderService implements ReminderService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final here = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(here.identifier));
    } catch (_) {
      // Falls back to UTC; the reminder still fires, just possibly at a
      // different wall-clock time until the platform's zone is resolvable.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
        linux: LinuxInitializationSettings(defaultActionName: 'Open'),
      ),
      onDidReceiveNotificationResponse: (response) =>
          tappedNoteId.value = response.payload,
    );
    // Catches a tap that launched the app from a terminated state.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      tappedNoteId.value = launch?.notificationResponse?.payload;
    }
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    final macOS = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (macOS != null) {
      return await macOS.requestPermissions(alert: true, sound: true) ?? false;
    }
    // Windows and Linux notifications don't ask permission up front.
    return true;
  }

  @override
  Future<void> schedule(
    Note note, {
    required bool appLockOn,
    required Locale locale,
  }) async {
    final at = note.reminderAt;
    if (at == null ||
        note.isDone ||
        note.deletedAt != null ||
        !at.isAfter(DateTime.now())) {
      await cancel(note);
      return;
    }
    await _ensureInitialized();
    final l10n = await AppLocalizations.delegate.load(locale);
    await _plugin.zonedSchedule(
      id: reminderNotificationId(note.id),
      title: appLockOn ? l10n.noteReminderLockedTitle : l10n.noteReminderTitle,
      body: appLockOn ? null : note.text,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'note_reminders',
          'Note reminders',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        linux: LinuxNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: note.id,
    );
  }

  @override
  Future<void> cancel(Note note) async {
    await _ensureInitialized();
    await _plugin.cancel(id: reminderNotificationId(note.id));
  }
}
