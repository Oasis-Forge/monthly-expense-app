package com.oasisforge.monthlyexpenses

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver
import com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.ZonedDateTime
import org.json.JSONArray
import org.json.JSONObject

/**
 * Lays the reminders again after a restart or an app update, minus the ones
 * that are too late to be worth sending (NUDGE-9, NOTE-6).
 *
 * A restart clears every alarm, so flutter_local_notifications keeps its own
 * copy of each scheduled notification and lays them all again at boot. Left
 * to itself it lays a one-shot whose time passed while the phone was off at
 * that same past time, and Android fires it the moment the phone is back:
 * last night's reminder arriving at breakfast (pr59_10). When Dart
 * reschedules, the app's rule is that a reminder which passed less than two
 * hours ago still goes out and an older one is dropped (`passedReminderGrace`
 * and `reminderActionFor` in lib/services/reminder_service.dart). Dart does
 * not run at boot, so this receiver, declared in the plugin's receiver's
 * place, applies the same rule to the plugin's copy first ([StaleReminders])
 * and then hands over to the plugin's own receiver for everything left.
 */
class ReminderBootReceiver : ScheduledNotificationBootReceiver() {
  override fun onReceive(context: Context, intent: Intent) {
    val action = intent.action
    if (action != null && action in StaleReminders.BOOT_ACTIONS) StaleReminders.drop(context)
    super.onReceive(context, intent)
  }
}

/**
 * Drops, from flutter_local_notifications' copy of what it has scheduled,
 * every one-shot reminder more than [PASSED_REMINDER_GRACE_MS] overdue, and
 * every one of the app's own reminders already due inside the quiet hours.
 *
 * The copy is the plugin's private storage, read here as it is laid out in
 * the version [CHECKED_PLUGIN_VERSION]: a JSON array of its
 * NotificationDetails, written by Gson under [PLUGIN_PREFS] / [PLUGIN_KEY],
 * one object per scheduled notification with its fields under their Java
 * names (the class is kept whole through R8). test/android_manifest_test.dart
 * checks that against the plugin's own source and fails when pubspec.lock
 * moves to another version, so the format is looked at again before an
 * upgrade ships.
 *
 * It fails open. A reminder that repeats, or whose time cannot be read, is
 * kept; a copy that cannot be read at all is left exactly as it was, and the
 * plugin lays everything in it again as it always did. A reminder that is
 * still due is never lost to this.
 */
object StaleReminders {
  private const val TAG = "ReminderBootReceiver"

  /**
   * Two hours: `passedReminderGrace` in lib/services/reminder_service.dart,
   * which test/android_manifest_test.dart holds this equal to.
   */
  const val PASSED_REMINDER_GRACE_MS = 7_200_000L

  /**
   * The flutter_local_notifications version whose storage this was checked
   * against; the test fails when pubspec.lock names another.
   */
  const val CHECKED_PLUGIN_VERSION = "22.3.1"

  /** The SharedPreferences file and key the plugin keeps its copy under. */
  const val PLUGIN_PREFS = "scheduled_notifications"
  const val PLUGIN_KEY = "scheduled_notifications"

  /**
   * Nothing the app sends on its own goes out before this hour or from that
   * one, by the device's own clock: `quietUntilHour` and `quietFromHour` in
   * lib/models/reminders.dart (NUDGE-6), which the test holds these equal to.
   */
  const val QUIET_UNTIL_HOUR = 8
  const val QUIET_FROM_HOUR = 22

  /**
   * What the payload of every reminder the app sends on its own starts with,
   * where a note's reminder carries the note's id: `nudgePayloadPrefix` in
   * lib/services/reminder_service.dart, held equal by the test.
   */
  const val NUDGE_PAYLOAD_PREFIX = "nudge:"

  /**
   * An empty-day nudge's whole payload: `nudgePayload(ReminderKind.emptyDay)`
   * in lib/services/reminder_service.dart, held equal by the test.
   */
  const val EMPTY_DAY_PAYLOAD = "nudge:emptyDay"

  /**
   * Where the times of the empty-day nudges dropped here are kept for the
   * app ([droppedEmptyDays]), which leaves those days out of its count of
   * ignored ones: the phone never showed them, so nobody ignored them
   * (NUDGE-5).
   */
  const val DROPPED_PREFS = "reminder_boot"
  const val DROPPED_KEY = "dropped_empty_days"

  /**
   * How many of those are kept, the newest. The app reads them without
   * clearing them and looks only at the ones since it last counted, and a
   * plan never holds more than eight nudges, so this is plenty.
   */
  private const val DROPPED_KEPT = 16

  /** The plugin's own boot receiver answers exactly these. */
  val BOOT_ACTIONS = setOf(
    Intent.ACTION_BOOT_COMPLETED,
    Intent.ACTION_MY_PACKAGE_REPLACED,
    "android.intent.action.QUICKBOOT_POWERON",
    "com.htc.intent.action.QUICKBOOT_POWERON",
  )

  /**
   * Any of these set makes a notification repeat: the plugin lays the next
   * one itself once this one fires, so dropping it would end the series.
   */
  private val REPEAT_FIELDS = listOf(
    "repeatInterval",
    "repeatIntervalMilliseconds",
    "repeatTime",
    "matchDateTimeComponents",
    "scheduledNotificationRepeatFrequency",
  )

  /**
   * Rewrites the plugin's copy without the stale one-shots, before the
   * plugin reads it, and disarms whatever alarm is still waiting for them
   * ([cancelAlarm]), and notes the empty-day nudges among them for the app
   * ([noteDroppedEmptyDays]). Nothing is written when nothing is stale.
   */
  fun drop(
    context: Context,
    nowMillis: Long = System.currentTimeMillis(),
    // The device's own clock, as the quiet hours are (NUDGE-6).
    zone: ZoneId = ZoneId.systemDefault(),
  ) {
    try {
      val prefs = context.getSharedPreferences(PLUGIN_PREFS, Context.MODE_PRIVATE)
      val cached = prefs.getString(PLUGIN_KEY, null) ?: return
      val pruned = withoutStale(cached, nowMillis, zone) ?: return
      if (!prefs.edit().putString(PLUGIN_KEY, pruned.kept).commit()) {
        Log.w(TAG, "Could not save the reminders left; the plugin lays all of them")
        return
      }
      // Only once they are out of the copy: still in it, the plugin would
      // lay them again straight after, and disarming them would be undone.
      for (entry in pruned.dropped) idOf(entry)?.let { cancelAlarm(context, it) }
      noteDroppedEmptyDays(context, pruned.dropped)
      Log.i(TAG, "Dropped the reminders too late to send, and the nudges due in the quiet hours")
    } catch (error: Exception) {
      Log.w(
        TAG,
        "Could not read the scheduled reminders as flutter_local_notifications " +
          "$CHECKED_PLUGIN_VERSION stores them; the plugin lays all of them",
        error,
      )
    }
  }

  /** What [withoutStale] leaves in the plugin's copy, and what it takes out. */
  class Pruned(val kept: String, val dropped: List<JSONObject>)

  /**
   * [cached] without the stale one-shots, or null when none of them is
   * stale. Throws when [cached] is not a JSON array at all.
   */
  fun withoutStale(cached: String, nowMillis: Long, zone: ZoneId): Pruned? {
    val all = JSONArray(cached)
    val kept = JSONArray()
    val dropped = mutableListOf<JSONObject>()
    for (index in 0 until all.length()) {
      val entry = all.get(index)
      if (entry is JSONObject && isStale(entry, nowMillis, zone)) dropped.add(entry) else kept.put(entry)
    }
    return if (dropped.isEmpty()) null else Pruned(kept.toString(), dropped)
  }

  /**
   * Disarms the alarm the plugin laid for notification [id], if one is
   * still waiting. After a restart none is: the restart cleared them all.
   * An app update keeps them, though, and a one-shot the phone has held
   * back (Doze, or the standby bucket of an app seldom opened) can still be
   * waiting hours after its time; dropped from the copy alone, it would
   * fire that late all the same. The PendingIntent is the one the plugin's
   * getBroadcastPendingIntent builds: request code the id, the plugin's
   * receiver, immutable (the plugin adds that flag from API 23, below this
   * app's minSdk). Those are what an alarm's PendingIntent is matched on;
   * FLAG_NO_CREATE finds it without making one when there is none.
   */
  private fun cancelAlarm(context: Context, id: Int) {
    val pending = PendingIntent.getBroadcast(
      context,
      id,
      Intent(context, ScheduledNotificationReceiver::class.java),
      PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
    ) ?: return
    (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pending)
    pending.cancel()
  }

  /**
   * Adds when each empty-day nudge in [dropped] was due to what
   * [droppedEmptyDays] returns.
   */
  private fun noteDroppedEmptyDays(context: Context, dropped: List<JSONObject>) {
    val times = dropped
      .filter { it.optString("payload") == EMPTY_DAY_PAYLOAD }
      .mapNotNull { dueMillis(it) }
    if (times.isEmpty()) return
    val all = (droppedEmptyDays(context) + times).distinct().sorted().takeLast(DROPPED_KEPT)
    context.getSharedPreferences(DROPPED_PREFS, Context.MODE_PRIVATE)
      .edit()
      .putString(DROPPED_KEY, JSONArray(all).toString())
      .commit()
  }

  /**
   * When each empty-day nudge dropped here was due, in epoch milliseconds,
   * oldest first; empty when none was or they cannot be read. MainActivity
   * hands these to the app.
   */
  fun droppedEmptyDays(context: Context): List<Long> =
    try {
      val saved = context.getSharedPreferences(DROPPED_PREFS, Context.MODE_PRIVATE)
        .getString(DROPPED_KEY, null)
      if (saved == null) {
        emptyList()
      } else {
        JSONArray(saved).let { array -> List(array.length()) { array.getLong(it) } }
      }
    } catch (error: Exception) {
      emptyList()
    }

  /** The notification id the plugin keeps [entry] under, if it reads as one. */
  private fun idOf(entry: JSONObject): Int? = (entry.opt("id") as? Number)?.toInt()

  /**
   * Whether [entry] is a one-shot that should not go out now: its time is
   * more than [PASSED_REMINDER_GRACE_MS] in the past (strictly more, as in
   * Dart: one exactly two hours overdue still goes out), or it is one of the
   * app's own reminders, already due, while [zone]'s clock is inside the
   * quiet hours. Laid again, that one would arrive the moment the phone is
   * back, in the night the app promises to keep quiet (NUDGE-6). A note's
   * reminder has no quiet hours: its time was the user's own choice.
   */
  fun isStale(entry: JSONObject, nowMillis: Long, zone: ZoneId): Boolean {
    if (REPEAT_FIELDS.any { entry.has(it) && !entry.isNull(it) }) return false
    val due = dueMillis(entry) ?: return false
    if (nowMillis - due > PASSED_REMINDER_GRACE_MS) return true
    return due <= nowMillis && isNudge(entry) && isQuiet(nowMillis, zone)
  }

  /** Whether [entry] is one of the app's own reminders, not a note's. */
  private fun isNudge(entry: JSONObject): Boolean =
    entry.optString("payload").startsWith(NUDGE_PAYLOAD_PREFIX)

  /** Whether [nowMillis] is inside the quiet hours on [zone]'s clock. */
  private fun isQuiet(nowMillis: Long, zone: ZoneId): Boolean {
    val hour = Instant.ofEpochMilli(nowMillis).atZone(zone).hour
    return hour < QUIET_UNTIL_HOUR || hour >= QUIET_FROM_HOUR
  }

  /**
   * When the plugin would fire [entry], read the way its
   * rescheduleNotifications does: a zoned one from its local date and time
   * in its zone, an older plain one from its epoch time. Null when that
   * cannot be read, which keeps it.
   */
  private fun dueMillis(entry: JSONObject): Long? =
    try {
      when {
        entry.has("timeZoneName") && !entry.isNull("timeZoneName") ->
          ZonedDateTime.of(
            LocalDateTime.parse(entry.getString("scheduledDateTime")),
            ZoneId.of(entry.getString("timeZoneName")),
          ).toInstant().toEpochMilli()
        entry.has("millisecondsSinceEpoch") && !entry.isNull("millisecondsSinceEpoch") ->
          entry.getLong("millisecondsSinceEpoch")
        else -> null
      }
    } catch (error: Exception) {
      null
    }
}
