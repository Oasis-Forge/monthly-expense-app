import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../models/money.dart';
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

/// Marks a payload as the app's own reminder rather than a note's. The
/// Android boot receiver tells the two apart by it too
/// (`NUDGE_PAYLOAD_PREFIX` in ReminderBootReceiver.kt, held equal by
/// test/android_manifest_test.dart), to keep the quiet hours after a
/// restart (NUDGE-6, NUDGE-9).
const nudgePayloadPrefix = 'nudge:';

/// The payload of the app's own reminder of [kind] (NUDGE-1).
String nudgePayload(ReminderKind kind) => '$nudgePayloadPrefix${kind.name}';

/// A stable notification ID for [noteId]. Notification IDs are 32-bit ints,
/// so this folds the UUID's hash into that range.
int reminderNotificationId(String noteId) => noteId.hashCode & 0x7fffffff;

/// The Android notification channel name for a note reminder, from [l10n]
/// rather than an English literal (LANG-2, NUDGE-11). A pure function so a
/// test can catch a regression to the English literal without touching the
/// notifications plugin.
String noteChannelName(AppLocalizations l10n) => l10n.noteReminderChannelName;

/// The Android notification channel name for one of the app's own nudges
/// (NUDGE-11), from [l10n] rather than an English literal (LANG-2).
String channelNameFor(ReminderKind kind, AppLocalizations l10n) =>
    switch (kind) {
      ReminderKind.dueEntry => l10n.dueEntryChannelName,
      ReminderKind.emptyDay => l10n.emptyDayChannelName,
    };

/// How long after its time a note reminder is still worth leaving alone,
/// covering the inexact alarm's own delivery window (NUDGE-9).
///
/// A restart applies the same number before Dart runs: the Android boot
/// receiver (`PASSED_REMINDER_GRACE_MS` in ReminderBootReceiver.kt) drops
/// every one-shot reminder more overdue than this rather than fire it late
/// (pr59_10), and test/android_manifest_test.dart holds the two equal.
const passedReminderGrace = Duration(hours: 2);

/// Whether a reminder whose time [at] has already passed should be
/// cancelled outright, rather than left as whatever is already pending.
///
/// Opening the app (or any other reschedule) shortly after a reminder's
/// time, but before the device's inexact alarm has actually fired, must not
/// cancel that still-pending alarm -- that silently loses the notification
/// for good (NOTE-6). So a passed time is left alone, unless [lastScheduledAt]
/// (the time this reminder was scheduled for last) shows it changed, or the
/// time is more than [passedReminderGrace] in the past.
bool shouldCancelPassedReminder({
  required DateTime at,
  required DateTime? lastScheduledAt,
  required DateTime now,
}) {
  if (lastScheduledAt != null && lastScheduledAt != at) return true;
  return now.difference(at) > passedReminderGrace;
}

/// What [ReminderService.schedule] should do with a note's reminder:
/// schedule it fresh (or replace whatever is pending), leave the pending
/// one exactly as it is, or cancel it outright.
enum ReminderAction { schedule, keep, cancel }

/// While [ReminderAction.keep] leaves a passed-but-pending reminder alone,
/// app lock being on is still a reason to touch it: whatever the device has
/// for it must carry the locked wording, not the note's own text (LOCK-2).
/// What that takes depends on what the device actually has, not on any
/// remembered history of the app's own (x-reminder-lock-keep) -- a cold
/// start has no such history, but the device's own active and pending
/// lists are always there to ask.
enum LockKeepAction {
  /// App lock is off, the device has nothing for this reminder, or whatever
  /// the device has already carries the locked wording (x-reminder-lock-keep):
  /// leave it exactly as it is.
  none,

  /// Already delivered and sitting in the tray: shown again with the same
  /// ID and the locked wording, which replaces it in place rather than
  /// adding a second one (LOCK-2).
  reshow,

  /// Not yet delivered: the pending alarm still carries the note's own
  /// text, so it is cancelled and laid again a minute out with the locked
  /// wording, rather than shown this instant (NUDGE-9's own inexact
  /// delivery, kept even here).
  reschedule,
}

/// The decision [DeviceReminderService.schedule]'s keep path makes for a
/// note reminder, from what the device currently has for it -- never from
/// memory of what app lock used to be, so it holds after a cold start too.
/// [alreadyLocked] is whether the device's own copy already carries the
/// locked wording (its title is the locked title and it has no body): when
/// it is, this is a no-op, so a reshow does not alert again on every
/// reschedule and a still-pending alarm is not cancelled and re-laid a
/// minute later on every one either (x-reminder-lock-keep).
LockKeepAction lockKeepActionFor({
  required bool appLockOn,
  required bool isActive,
  required bool isPending,
  bool alreadyLocked = false,
}) {
  if (!appLockOn) return LockKeepAction.none;
  if (alreadyLocked) return LockKeepAction.none;
  if (isActive) return LockKeepAction.reshow;
  if (isPending) return LockKeepAction.reschedule;
  return LockKeepAction.none;
}

/// The single decision [DeviceReminderService.schedule] and
/// `FakeReminderService.schedule` (test/helpers.dart) must agree on, so a
/// test that only drives the fake proves something true of the device too
/// (pr59#9). [lastScheduledAt] is the time this note's reminder was
/// scheduled for last, or null if it never was; see
/// [shouldCancelPassedReminder] for the passed-time half of this.
ReminderAction reminderActionFor(
  Note note, {
  required DateTime? lastScheduledAt,
  required DateTime now,
}) {
  final at = note.reminderAt;
  if (at == null || note.isDone || note.deletedAt != null) {
    return ReminderAction.cancel;
  }
  if (at.isAfter(now)) return ReminderAction.schedule;
  return shouldCancelPassedReminder(
        at: at,
        lastScheduledAt: lastScheduledAt,
        now: now,
      )
      ? ReminderAction.cancel
      : ReminderAction.keep;
}

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
  /// no reminder, is done, or is deleted. A reminder whose time has passed is
  /// cancelled only when that time changed or it passed more than
  /// [passedReminderGrace] ago; otherwise whatever is already pending (the
  /// device's own inexact alarm) is left alone rather than dropped for good
  /// (NOTE-6, NUDGE-9, see [shouldCancelPassedReminder]) -- except that with
  /// app lock on, every such reschedule checks what the device itself
  /// currently has for it (never a memory of whether app lock just turned
  /// on, which a cold start has none of) and rewords it once with the
  /// locked wording: a delivered one still in the tray is replaced in
  /// place, without alerting again, and a still-pending one is cancelled
  /// and re-laid about a minute out with it. Once that copy already
  /// carries the locked wording, later reschedules leave it alone
  /// (x-reminder-lock-keep, see [lockKeepActionFor]). With [appLockOn], the
  /// notification names only the app, not the note's text (LOCK-2).
  Future<void> schedule(
    Note note, {
    required bool appLockOn,
    required Locale locale,
  });

  /// Cancels the note's reminder, if any.
  Future<void> cancel(Note note);

  /// Replaces every reminder the app sends on its own with [plan], cancelling
  /// whatever was scheduled before (NUDGE-1). With [appLockOn] they name
  /// nothing but the app itself (NUDGE-8). [currency] formats a due entry's
  /// amount the same way the rest of the app shows it (CUR-2, NUDGE-2).
  Future<void> scheduleNudges(
    List<PlannedReminder> plan, {
    required bool appLockOn,
    required Locale locale,
    required NumberFormat currency,
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
    required NumberFormat currency,
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
    required NumberFormat currency,
  }) => _guard(
    () => inner.scheduleNudges(
      plan,
      appLockOn: appLockOn,
      locale: locale,
      currency: currency,
    ),
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

  /// The time each note's reminder was last scheduled for, so a passed time
  /// can be told apart from one that changed (pr59-style in-memory record;
  /// see [shouldCancelPassedReminder]). Nothing about app lock is kept here
  /// any more: whether a pending reminder needs the locked wording is
  /// decided from the device's own state every time (see
  /// [lockKeepActionFor]), not from a memory that a cold start would start
  /// out empty (x-reminder-lock-keep).
  final _lastScheduledAt = <String, DateTime>{};

  Future<void> _ensureInitialized() {
    final initializing = _initializing ??= _doInitialize();
    // A failed attempt is not cached: the next call starts a fresh one,
    // exactly as the old `bool` flag (left false on failure) did. This does
    // not touch what `initializing` resolves with for whoever is awaiting
    // it here and elsewhere -- Dart lets more than one caller listen to the
    // same future independently.
    unawaited(initializing.catchError((_) => _initializing = null));
    return initializing;
  }

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
    final last = _lastScheduledAt[note.id];
    final now = DateTime.now();
    switch (reminderActionFor(note, lastScheduledAt: last, now: now)) {
      case ReminderAction.cancel:
        await cancel(note);
        return;
      case ReminderAction.keep:
        // Still within the grace window and unchanged: leave whatever the
        // device already has pending alone (NOTE-6) -- unless app lock is
        // on, in which case whatever the device has for it must not still
        // carry the note's own text (LOCK-2). Asked of the device itself,
        // not remembered, so this holds after a cold start too
        // (x-reminder-lock-keep).
        await _applyLockKeep(note, appLockOn: appLockOn, locale: locale);
        _lastScheduledAt[note.id] = at!;
        return;
      case ReminderAction.schedule:
        break;
    }
    await _ensureInitialized();
    final l10n = await AppLocalizations.delegate.load(locale);
    await _plugin.zonedSchedule(
      id: reminderNotificationId(note.id),
      title: appLockOn ? l10n.noteReminderLockedTitle : l10n.noteReminderTitle,
      body: appLockOn ? null : note.text,
      scheduledDate: tz.TZDateTime.from(at!, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'note_reminders',
          noteChannelName(l10n),
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
        linux: const LinuxNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: note.id,
    );
    _lastScheduledAt[note.id] = at;
  }

  /// Makes sure whatever the device has for [note]'s reminder carries the
  /// locked wording while app lock is on (LOCK-2), per [lockKeepActionFor].
  Future<void> _applyLockKeep(
    Note note, {
    required bool appLockOn,
    required Locale locale,
  }) async {
    if (!appLockOn) return;
    await _ensureInitialized();
    final id = reminderNotificationId(note.id);
    final l10n = await AppLocalizations.delegate.load(locale);
    final active = await _plugin.getActiveNotifications();
    final pending = await _plugin.pendingNotificationRequests();
    // Already carrying the locked wording -- itself, not the note's own
    // text -- means a previous reschedule already handled this one; doing
    // it again would alert a second time for nothing (x-reminder-lock-keep).
    bool isLocked(String? title, String? body) =>
        title == l10n.noteReminderLockedTitle && body == null;
    final action = lockKeepActionFor(
      appLockOn: appLockOn,
      isActive: active.any((n) => n.id == id),
      isPending: pending.any((p) => p.id == id),
      alreadyLocked:
          active
              .where((n) => n.id == id)
              .any((n) => isLocked(n.title, n.body)) ||
          pending
              .where((p) => p.id == id)
              .any((p) => isLocked(p.title, p.body)),
    );
    if (action == LockKeepAction.none) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'note_reminders',
        noteChannelName(l10n),
        importance: Importance.defaultImportance,
        // Reshowing an already-delivered notification in place must not
        // alert again -- Android treats an update as a new alert unless
        // told otherwise (x-reminder-lock-keep).
        onlyAlertOnce: true,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
      linux: const LinuxNotificationDetails(),
    );
    switch (action) {
      case LockKeepAction.reshow:
        // Same ID: this replaces the one already in the tray rather than
        // adding a second one (LOCK-2).
        await _plugin.show(
          id: id,
          title: l10n.noteReminderLockedTitle,
          notificationDetails: details,
          payload: note.id,
        );
      case LockKeepAction.reschedule:
        await _plugin.cancel(id: id);
        await _plugin.zonedSchedule(
          id: id,
          title: l10n.noteReminderLockedTitle,
          body: null,
          scheduledDate: tz.TZDateTime.from(
            DateTime.now().add(const Duration(minutes: 1)),
            tz.local,
          ),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: note.id,
        );
      case LockKeepAction.none:
        break;
    }
  }

  @override
  Future<void> cancel(Note note) async {
    _lastScheduledAt.remove(note.id);
    await _ensureInitialized();
    await _plugin.cancel(id: reminderNotificationId(note.id));
  }

  /// Routes a tapped notification: the app's own reminders carry a marked
  /// payload, and everything else is a note's ID (NOTE-6, NUDGE-1).
  void _deliver(String? payload) {
    if (payload == null) return;
    if (payload.startsWith(nudgePayloadPrefix)) {
      final name = payload.substring(nudgePayloadPrefix.length);
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
    required NumberFormat currency,
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
            : nudgeTitle(l10n, reminder),
        body: appLockOn ? null : nudgeBody(l10n, reminder, currency: currency),
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
            channelNameFor(reminder.kind, l10n),
            importance: Importance.defaultImportance,
          ),
          iOS: const DarwinNotificationDetails(),
          macOS: const DarwinNotificationDetails(),
          linux: const LinuxNotificationDetails(),
        ),
        // Inexact, so Play is never asked for the exact-alarm permission and
        // the phone may deliver it a few minutes late (NUDGE-9).
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: nudgePayload(reminder.kind),
      );
    }
  }
}

/// The title for one of the app's own reminders (NUDGE-1), from [l10n]
/// rather than an English literal (LANG-2). A pure function, extracted
/// alongside [nudgeBody] so their content is unit-testable without touching
/// the notifications plugin (rules-23-26-34#5's own suggested_check).
String nudgeTitle(AppLocalizations l10n, PlannedReminder reminder) =>
    switch (reminder.kind) {
      ReminderKind.dueEntry => l10n.dueEntryReminderTitle,
      ReminderKind.emptyDay => l10n.emptyDayReminderTitle,
    };

/// The body for one of the app's own reminders (NUDGE-1), naming what was
/// due and for how much (NUDGE-2): the amount in [currency]'s own format
/// (CUR-2), and "due today" only when [reminder]'s own due date really is
/// the day it fires on -- an occurrence carried over from an earlier,
/// unhandled day names that day instead of claiming it is today's
/// (rules-23-26-34#9). A grouped reminder ([reminder.count] more than one)
/// carries no date of its own, but says "waiting" rather than "due today"
/// when [PlannedReminder.anyOverdue] shows at least one of the group was
/// carried over too.
String nudgeBody(
  AppLocalizations l10n,
  PlannedReminder reminder, {
  required NumberFormat currency,
}) {
  if (reminder.kind == ReminderKind.emptyDay) {
    return l10n.emptyDayReminderBody;
  }
  if (reminder.count > 1) {
    return reminder.anyOverdue
        ? l10n.dueEntryReminderManyWaiting(reminder.count)
        : l10n.dueEntryReminderMany(reminder.count);
  }
  final amount = reminder.amount;
  final amountText = amount == null
      ? ''
      : currency.signedMoney(amount, isIncome: reminder.isIncome);
  final dueDate = reminder.dueDate;
  final overdue = dueDate != null && !_sameLocalDay(dueDate, reminder.at);
  final title = reminder.title;
  if (title == null || title.isEmpty) {
    return overdue
        ? l10n.dueEntryReminderUntitledOverdue(
            amountText,
            DateFormat.yMMMd(l10n.localeName).format(dueDate),
          )
        : l10n.dueEntryReminderUntitled(amountText);
  }
  return overdue
      ? l10n.dueEntryReminderOneOverdue(
          title,
          amountText,
          DateFormat.yMMMd(l10n.localeName).format(dueDate),
        )
      : l10n.dueEntryReminderOne(title, amountText);
}

bool _sameLocalDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
