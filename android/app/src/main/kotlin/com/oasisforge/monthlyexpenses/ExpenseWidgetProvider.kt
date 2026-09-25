package com.oasisforge.monthlyexpenses

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews

/**
 * Draws the home-screen widget from what the app last saved (WID-1, WID-2).
 *
 * Nothing here reads the database or computes a total: it picks the entry
 * whose day has come out of [HomeWidgetStore] and paints its strings. When a
 * later entry is waiting it also sets an alarm for that moment, so the day's
 * turn reaches the widget without the app being opened (WID-5). The alarm is
 * inexact, which needs no permission; a half-hourly update in the widget's
 * own metadata puts it back after a reboot.
 */
abstract class ExpenseWidgetProvider : AppWidgetProvider() {
  /** Whether this is the medium widget, which also shows income, the
   * balance, and an Add income button (WID-1). */
  protected abstract val isMedium: Boolean

  override fun onUpdate(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
  ) {
    val payload = HomeWidgetStore.read(context)
    val now = System.currentTimeMillis()
    for (id in appWidgetIds) {
      appWidgetManager.updateAppWidget(id, buildViews(context, payload, now, id))
    }
    scheduleNextChange(context, payload, now)
  }

  private fun buildViews(
    context: Context,
    payload: HomeWidgetStore.Payload?,
    now: Long,
    widgetId: Int,
  ): RemoteViews {
    val layout = if (isMedium) R.layout.widget_medium else R.layout.widget_small
    val views = RemoteViews(context.packageName, layout)
    val entry = payload?.entryAt(now)

    views.setInt(
      R.id.widget_root,
      "setLayoutDirection",
      if (payload?.isRtl == true) View.LAYOUT_DIRECTION_RTL else View.LAYOUT_DIRECTION_LTR,
    )

    // Before the app has ever run there is nothing to show but the buttons.
    val hidden = payload == null || payload.hideAmounts || entry == null
    views.setViewVisibility(R.id.widget_amounts, if (hidden) View.GONE else View.VISIBLE)
    views.setViewVisibility(R.id.widget_hidden_note, if (hidden) View.VISIBLE else View.GONE)
    if (hidden) {
      views.setTextViewText(
        R.id.widget_hidden_note,
        if (payload?.hideAmounts == true) payload.label("hidden")
        else context.getString(R.string.widget_open_the_app),
      )
      views.setTextViewText(R.id.widget_period, payload?.title.orEmpty())
    } else {
      views.setTextViewText(R.id.widget_period, entry.period)
      fillAmounts(context, views, payload, entry)
    }

    views.setTextViewText(R.id.widget_add_expense, payload?.label("addExpense").orEmpty())
    views.setOnClickPendingIntent(
      R.id.widget_add_expense,
      launchIntent(context, widgetId, ACTION_ADD_EXPENSE),
    )
    if (isMedium) {
      views.setTextViewText(R.id.widget_add_income, payload?.label("addIncome").orEmpty())
      views.setOnClickPendingIntent(
        R.id.widget_add_income,
        launchIntent(context, widgetId, ACTION_ADD_INCOME),
      )
    }
    // Tapping the numbers opens Home on the current period (WID-3).
    views.setOnClickPendingIntent(
      R.id.widget_root,
      launchIntent(context, widgetId, ACTION_OPEN_HOME),
    )
    return views
  }

  private fun fillAmounts(
    context: Context,
    views: RemoteViews,
    payload: HomeWidgetStore.Payload,
    entry: HomeWidgetStore.Entry,
  ) {
    // The small widget leads with the budget left when there is one, since
    // that is the number worth glancing at (WID-1).
    val budget = entry.budgetLeft
    if (!isMedium) {
      views.setTextViewText(
        R.id.widget_main_label,
        if (budget == null) payload.label("expense") else payload.label("budgetLeft"),
      )
      views.setTextViewText(R.id.widget_main_amount, budget ?: entry.expense)
      // Set explicitly either way: AppWidgetHostView reapplies this update
      // onto the view it already has, so a colour left unset here would be
      // whatever the last update happened to leave behind, not the layout's
      // own default (WID-6).
      views.setTextColor(
        R.id.widget_main_amount,
        amountColor(context, overBudget = budget != null && entry.isOverBudget),
      )
      return
    }

    views.setTextViewText(R.id.widget_income_label, payload.label("income"))
    views.setTextViewText(R.id.widget_income_amount, entry.income)
    views.setTextViewText(R.id.widget_expense_label, payload.label("expense"))
    views.setTextViewText(R.id.widget_expense_amount, entry.expense)
    views.setTextViewText(R.id.widget_balance_label, payload.label("balance"))
    views.setTextViewText(R.id.widget_balance_amount, entry.balance)
    views.setViewVisibility(R.id.widget_budget, if (budget == null) View.GONE else View.VISIBLE)
    if (budget != null) {
      views.setTextViewText(R.id.widget_budget_label, payload.label("budgetLeft"))
      views.setTextViewText(R.id.widget_budget_amount, budget)
      views.setTextColor(
        R.id.widget_budget_amount,
        amountColor(context, overBudget = entry.isOverBudget),
      )
    }
  }

  /** The over-budget red when [overBudget], else the layout's own amount
   * colour — set explicitly rather than left to whichever update last
   * touched this view (WID-6). Both colours are the app's own expense-ink
   * pair (CUR-5) and clear 4.5:1 on the widget's light and dark background
   * alike (A11Y-3, THEME-4). */
  private fun amountColor(context: Context, overBudget: Boolean): Int =
    context.getColor(if (overBudget) R.color.widget_over_budget else R.color.widget_amount)

  private fun launchIntent(context: Context, widgetId: Int, action: String): PendingIntent {
    val intent =
      Intent(context, MainActivity::class.java).apply {
        this.action = Intent.ACTION_MAIN
        addCategory(Intent.CATEGORY_LAUNCHER)
        putExtra(EXTRA_ACTION, action)
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
      }
    // A request code per widget and action, so one button's extras never
    // replace another's.
    val requestCode = widgetId * ACTIONS.size + ACTIONS.indexOf(action)
    return PendingIntent.getActivity(
      context,
      requestCode,
      intent,
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
  }

  private fun scheduleNextChange(
    context: Context,
    payload: HomeWidgetStore.Payload?,
    now: Long,
  ) {
    val alarms = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
    val pending =
      PendingIntent.getBroadcast(
        context,
        0,
        Intent(context, javaClass).setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
      )
    val next = payload?.nextChangeAfter(now)
    if (next == null) {
      alarms.cancel(pending)
      return
    }
    // Inexact on purpose: the widget may lag the turn of the day by a few
    // minutes, and asking for an exact alarm would need a permission the app
    // doesn't want (see NOTE-6 for the same choice on reminders).
    alarms.set(AlarmManager.RTC, next, pending)
  }

  override fun onReceive(context: Context, intent: Intent) {
    // The alarm broadcast carries no widget IDs, so fill them in.
    if (
      intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE &&
        !intent.hasExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS)
    ) {
      val manager = AppWidgetManager.getInstance(context)
      val ids = manager.getAppWidgetIds(ComponentName(context, javaClass))
      if (ids.isNotEmpty()) onUpdate(context, manager, ids)
      return
    }
    super.onReceive(context, intent)
  }

  override fun onDisabled(context: Context) {
    super.onDisabled(context)
    scheduleNextChange(context, null, System.currentTimeMillis())
  }

  companion object {
    const val EXTRA_ACTION = "com.oasisforge.monthlyexpenses.WIDGET_ACTION"
    const val ACTION_ADD_EXPENSE = "add_expense"
    const val ACTION_ADD_INCOME = "add_income"
    const val ACTION_OPEN_HOME = "open_home"

    private val ACTIONS = listOf(ACTION_ADD_EXPENSE, ACTION_ADD_INCOME, ACTION_OPEN_HOME)

    /** Redraws every widget on the home screen, after the app saved new
     * numbers. */
    fun refreshAll(context: Context) {
      val manager = AppWidgetManager.getInstance(context)
      for (provider in listOf(SmallExpenseWidget::class.java, MediumExpenseWidget::class.java)) {
        val ids = manager.getAppWidgetIds(ComponentName(context, provider))
        if (ids.isEmpty()) continue
        context.sendBroadcast(
          Intent(context, provider)
            .setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
            .putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        )
      }
    }
  }
}

/** The 2×2 widget: the period's expense, or the budget left (WID-1). */
class SmallExpenseWidget : ExpenseWidgetProvider() {
  override val isMedium = false
}

/** The 4×2 widget: income, expense, balance, and the budget left (WID-1). */
class MediumExpenseWidget : ExpenseWidgetProvider() {
  override val isMedium = true
}
