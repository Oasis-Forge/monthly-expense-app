package com.oasisforge.monthlyexpenses

import android.content.Context
import android.content.Intent
import android.util.Log
import com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver
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
 * every one-shot reminder more than [PASSED_REMINDER_GRACE_MS] overdue.
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
   * plugin reads it. Nothing is written when nothing is stale.
   */
  fun drop(context: Context, nowMillis: Long = System.currentTimeMillis()) {
    try {
      val prefs = context.getSharedPreferences(PLUGIN_PREFS, Context.MODE_PRIVATE)
      val cached = prefs.getString(PLUGIN_KEY, null) ?: return
      val kept = withoutStale(cached, nowMillis) ?: return
      if (prefs.edit().putString(PLUGIN_KEY, kept).commit()) {
        Log.i(TAG, "Dropped the reminders more than two hours overdue")
      } else {
        Log.w(TAG, "Could not save the reminders left; the plugin lays all of them")
      }
    } catch (error: Exception) {
      Log.w(
        TAG,
        "Could not read the scheduled reminders as flutter_local_notifications " +
          "$CHECKED_PLUGIN_VERSION stores them; the plugin lays all of them",
        error,
      )
    }
  }

  /**
   * [cached] without the stale one-shots, or null when none of them is
   * stale. Throws when [cached] is not a JSON array at all.
   */
  fun withoutStale(cached: String, nowMillis: Long): String? {
    val all = JSONArray(cached)
    val kept = JSONArray()
    var dropped = 0
    for (index in 0 until all.length()) {
      val entry = all.get(index)
      if (entry is JSONObject && isStale(entry, nowMillis)) dropped++ else kept.put(entry)
    }
    return if (dropped == 0) null else kept.toString()
  }

  /**
   * Whether [entry] is a one-shot whose time is more than
   * [PASSED_REMINDER_GRACE_MS] in the past. Strictly more, as in Dart: one
   * exactly two hours overdue still goes out.
   */
  fun isStale(entry: JSONObject, nowMillis: Long): Boolean {
    if (REPEAT_FIELDS.any { entry.has(it) && !entry.isNull(it) }) return false
    val due = dueMillis(entry) ?: return false
    return nowMillis - due > PASSED_REMINDER_GRACE_MS
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
