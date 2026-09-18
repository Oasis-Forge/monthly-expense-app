package com.oasisforge.monthlyexpenses

import android.content.Context
import org.json.JSONObject

/**
 * The numbers the home-screen widget shows, as the app last handed them over.
 *
 * The widget has no database of its own and never computes anything: the app
 * writes the finished strings here, in its own language and currency format,
 * and the widget paints them (WID-5, WID-6).
 *
 * Along with what to show now, the app sends what to show on each day ahead
 * when the numbers change — a new period starting, or an entry dated ahead
 * beginning to count. That way the widget stays right past midnight even if
 * the app is never opened.
 */
object HomeWidgetStore {
  private const val PREFS = "home_widget"
  private const val KEY_PAYLOAD = "payload"

  /** The payload layout this build understands. */
  private const val SUPPORTED_VERSION = 1

  fun save(context: Context, json: String) {
    context
      .getSharedPreferences(PREFS, Context.MODE_PRIVATE)
      .edit()
      .putString(KEY_PAYLOAD, json)
      .apply()
  }

  /** What was last saved, or null when the app has never run or the payload
   * comes from a version this build doesn't know. */
  fun read(context: Context): Payload? {
    val json =
      context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY_PAYLOAD, null)
        ?: return null
    return try {
      val root = JSONObject(json)
      if (root.optInt("version") != SUPPORTED_VERSION) return null
      Payload(root)
    } catch (error: org.json.JSONException) {
      null
    }
  }

  class Payload(root: JSONObject) {
    /** True while app lock hides the amounts, which are then not sent at all
     * (WID-4). */
    val hideAmounts: Boolean = root.optBoolean("hideAmounts")
    val isRtl: Boolean = root.optBoolean("rtl")
    val title: String = root.optString("title")

    private val labels: JSONObject = root.optJSONObject("labels") ?: JSONObject()
    private val entries: List<Entry> =
      root.optJSONArray("entries").let { array ->
        (0 until (array?.length() ?: 0)).mapNotNull { index ->
          array?.optJSONObject(index)?.let(::Entry)
        }
      }

    fun label(name: String): String = labels.optString(name)

    /** The entry in force at [now], or null when there are none. */
    fun entryAt(now: Long): Entry? = entries.lastOrNull { it.from <= now } ?: entries.firstOrNull()

    /** When the next entry takes over, or null when this is the last one. */
    fun nextChangeAfter(now: Long): Long? = entries.firstOrNull { it.from > now }?.from
  }

  class Entry(json: JSONObject) {
    val from: Long = json.optLong("from")
    val period: String = json.optString("period")
    val income: String = json.optString("income")
    val expense: String = json.optString("expense")
    val balance: String = json.optString("balance")

    /** Null when no overall budget is in force (WID-1). */
    val budgetLeft: String? = if (json.has("budgetLeft")) json.optString("budgetLeft") else null
    val isOverBudget: Boolean = json.optBoolean("overBudget")
  }
}
