package com.oasisforge.monthlyexpenses

import android.content.Intent
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// App lock uses local_auth, which needs a FragmentActivity.
class MainActivity : FlutterFragmentActivity() {
  private var channel: MethodChannel? = null
  private var securityChannel: MethodChannel? = null

  /** The widget button that launched the app, until Dart asks for it. */
  private var pendingAction: String? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    pendingAction = intent?.getStringExtra(ExpenseWidgetProvider.EXTRA_ACTION)
    channel =
      MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
        setMethodCallHandler { call, result ->
          when (call.method) {
            // The app hands over the finished numbers; nothing else about
            // the database ever crosses (WID-5).
            "update" -> {
              HomeWidgetStore.save(applicationContext, call.arguments as String)
              ExpenseWidgetProvider.refreshAll(applicationContext)
              result.success(null)
            }
            "launchAction" -> {
              result.success(pendingAction)
              pendingAction = null
            }
            else -> result.notImplemented()
          }
        }
      }
    securityChannel =
      MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL).apply {
        setMethodCallHandler { call, result ->
          when (call.method) {
            // LOCK-2: while App Lock is turned on, keep the OS from
            // including this window in the recents thumbnail or a
            // screenshot, so amounts never sit there readable without
            // unlocking (app_lock.dart pushes this on launch and whenever
            // the setting changes).
            "setSecure" -> {
              if (call.arguments as Boolean) {
                window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
              } else {
                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
              }
              result.success(null)
            }
            else -> result.notImplemented()
          }
        }
      }
  }

  /** A widget tap while the app is already running (WID-3). */
  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    setIntent(intent)
    val action = intent.getStringExtra(ExpenseWidgetProvider.EXTRA_ACTION) ?: return
    val live = channel
    // Before Dart is listening, hold it for the first `launchAction` call.
    if (live == null) pendingAction = action else live.invokeMethod("tapped", action)
  }

  private companion object {
    const val CHANNEL = "com.oasisforge.monthlyexpenses/home_widget"
    const val SECURITY_CHANNEL = "com.oasisforge.monthlyexpenses/security"
  }
}
