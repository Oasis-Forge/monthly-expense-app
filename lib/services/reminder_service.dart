import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../models/note.dart';
import '../models/reminders.dart';

/// A note's reminder notification was tapped: the note's ID, or null when
/// there's nothing pending. A top-level listener opens the note through the
/// lock (NOTE-6, LOCK-2).
final ValueNotifier<String?> tappedNoteId = ValueNotifier(null);

/// A reminder the app sent on its own was tapped (NUDGE-1), or null when
/// there is nothing pending. A top-level listener opens what it was about,
/// through the lock (NUDGE-8, LOCK-2).
final ValueNotifier<ReminderKind?> tappedReminder = ValueNotifier(null);

/// Notification IDs for the app's own reminders. They sit at the top of the
/// range, clear of the note IDs, which are folded hashes.
const _nudgeIdBase = 0x7fff0000;

/// How many are reserved, so replacing a plan always cancels all of the one
/// before it (NUDGE-1).
const _nudgeIdSlots = 8;

/// Marks a payload as the app's own reminder rather than a note's.
const _nudgePrefix = 'nudge:';

/// A stable notification ID for [noteId]. Notification IDs are 32-bit ints,
/// so this folds the UUID's hash into that range.
int reminderNotificationId(String noteId) => noteId.hashCode & 0x7fffffff;

/// Schedules and cancels the local notification for a note's reminder
/// (NOTE-6). Tests use a fake instead of touching the device.
abstract class ReminderService {
  /// Asks for notification permission, if the platform needs it. Call this
  /// only when the user sets a reminder for the first time (NOTE-6).
  Future<bool> requestPermission();

  /// Whether the OS is currently letting this app's notifications through
  /// (NUDGE-7): checked again on launch and resume, since permission granted
  /// once can be taken back later in the phone's own settings, not only
  /// through this app. True on a platform with no way to ask, so nothing
  /// here shows a false warning.
  Future<bool> areNotificationsEnabled();

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

  /// Replaces every reminder the app sends on its own with [plan], cancelling
  /// whatever was scheduled before (NUDGE-1). With [appLockOn] they name
  /// nothing but the app itself (NUDGE-8).
  Future<void> scheduleNudges(
    List<PlannedReminder> plan, {
    required bool appLockOn,
    required Locale locale,
  });
}

/// Does nothing. [TransactionProvider]'s default, so building one without
/// wiring up notifications (as most tests do) never touches the device;
/// `main.dart` passes a real [DeviceReminderService] instead.
class NoopReminderService implements ReminderService {
  const NoopReminderService();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> areNotificationsEnabled() async => true;

  @override
  Future<void> schedule(
    Note note, {
    required bool appLockOn,
    required Locale locale,
  }) async {}

  @override
  Future<void> cancel(Note note) async {}

  @override
  Future<void> scheduleNudges(
    List<PlannedReminder> plan, {
    required bool appLockOn,
    required Locale locale,
  }) async {}
}

/// Passes every call to [inner], and logs and swallows whatever it throws.
/// A reminder is a courtesy on top of the user's records: when the device's
/// notifications cannot be reached (a stripped icon in a release build, a
/// platform the plugin needs more settings for), loading and saving must go
/// on as if reminders were off, never stop halfway (NOTE-6, NUDGE-1).
class SafeReminderService implements ReminderService {
  const SafeReminderService(this.inner);

  final ReminderService inner;

  Future<T> _guard<T>(Future<T> Function() call, T fallback) async {
    try {
      return await call();
    } catch (error, stack) {
      debugPrint('Reminders unavailable: $error\n$stack');
      return fallback;
    }
  }

  @override
  Future<bool> requestPermission() => _guard(inner.requestPermission, false);

  @override
  Future<bool> areNotificationsEnabled() =>
      _guard(inner.areNotificationsEnabled, true);

  @override
  Future<void> schedule(
    Note note, {
    required bool appLockOn,
    required Locale locale,
  }) => _guard(
    () => inner.schedule(note, appLockOn: appLockOn, locale: locale),
    null,
  );

  @override
  Future<void> cancel(Note note) => _guard(() => inner.cancel(note), null);

  @override
  Future<void> scheduleNudges(
    List<PlannedReminder> plan, {
    required bool appLockOn,
    required Locale locale,
  }) => _guard(
    () => inner.scheduleNudges(plan, appLockOn: appLockOn, locale: locale),
    null,
  );
}

/// Schedules real device notifications through `flutter_local_notifications`.
class DeviceReminderService implements ReminderService {
  final _plugin = FlutterLocalNotificationsPlugin();

  /// Memoized rather than a `bool` flag (pr59#8): two callers racing each
  /// other -- the first-frame notification-permission check and the load's
  /// own [scheduleNudges], say -- must share the one initialize and the one
  /// delivery of a launch payload below, not each run it and each deliver
  /// the tapped notification's note a second time.
  Future<void>? _initializing;

  Future<void> _ensureInitialized() => _initializing ??= _doInitialize();

  Future<void> _doInitialize() async {
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
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
        linux: LinuxInitializationSettings(defaultActionName: 'Open'),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _deliver(response.payload),
    );
    // Catches a tap that launched the app from a terminated state.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _deliver(launch?.notificationResponse?.payload);
    }
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
  Future<bool> areNotificationsEnabled() async {
    await _ensureInitialized();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? true;
    }
    // iOS, macOS, Windows and Linux have no equivalent live check in the
    // plugin, so nothing here reports a phone as blocking when it may not
    // be (NUDGE-7).
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

  /// Routes a tapped notification: the app's own reminders carry a marked
  /// payload, and everything else is a note's ID (NOTE-6, NUDGE-1).
  void _deliver(String? payload) {
    if (payload == null) return;
    if (payload.startsWith(_nudgePrefix)) {
      final name = payload.substring(_nudgePrefix.length);
      tappedReminder.value = ReminderKind.values
          .where((kind) => kind.name == name)
          .firstOrNull;
      return;
    }
    tappedNoteId.value = payload;
  }

  @override
  Future<void> scheduleNudges(
    List<PlannedReminder> plan, {
    required bool appLockOn,
    required Locale locale,
  }) async {
    await _ensureInitialized();
    // Every slot goes, not only the ones about to be filled: yesterday's
    // plan must not survive into today's (NUDGE-1).
    for (var slot = 0; slot < _nudgeIdSlots; slot++) {
      await _plugin.cancel(id: _nudgeIdBase + slot);
    }

    final l10n = await AppLocalizations.delegate.load(locale);
    final now = DateTime.now();
    var slot = 0;
    for (final reminder in plan) {
      if (slot >= _nudgeIdSlots) break;
      // The plan was made a moment ago, but a slow start could have carried
      // it past one of its own times.
      if (!reminder.at.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: _nudgeIdBase + slot++,
        title: appLockOn
            ? l10n.reminderLockedTitle
            : _nudgeTitle(l10n, reminder),
        body: appLockOn ? null : _nudgeBody(l10n, reminder),
        scheduledDate: tz.TZDateTime.from(reminder.at, tz.local),
        notificationDetails: NotificationDetails(
          // A channel each, so someone who wants the entries that fell due
          // but not the empty days can say so in the phone's own settings
          // and keep the rest (NUDGE-11).
          android: AndroidNotificationDetails(
            switch (reminder.kind) {
              ReminderKind.dueEntry => 'due_entries',
              ReminderKind.emptyDay => 'empty_days',
            },
            switch (reminder.kind) {
              ReminderKind.dueEntry => 'Entries that fell due',
              ReminderKind.emptyDay => 'Days with nothing recorded',
            },
            importance: Importance.defaultImportance,
          ),
          iOS: const DarwinNotificationDetails(),
          macOS: const DarwinNotificationDetails(),
          linux: const LinuxNotificationDetails(),
        ),
        // Inexact, so Play is never asked for the exact-alarm permission and
        // the phone may deliver it a few minutes late (NUDGE-9).
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: '$_nudgePrefix${reminder.kind.name}',
      );
    }
  }

  String _nudgeTitle(AppLocalizations l10n, PlannedReminder reminder) =>
      switch (reminder.kind) {
        ReminderKind.dueEntry => l10n.dueEntryReminderTitle,
        ReminderKind.emptyDay => l10n.emptyDayReminderTitle,
      };

  String _nudgeBody(AppLocalizations l10n, PlannedReminder reminder) {
    if (reminder.kind == ReminderKind.emptyDay) {
      return l10n.emptyDayReminderBody;
    }
    if (reminder.count > 1) return l10n.dueEntryReminderMany(reminder.count);
    final title = reminder.title;
    return title == null || title.isEmpty
        ? l10n.dueEntryReminderUntitled
        : l10n.dueEntryReminderOne(title);
  }
}
