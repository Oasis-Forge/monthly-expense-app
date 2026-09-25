package com.oasisforge.monthlyexpenses

import android.content.Intent
import android.os.Build
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
            // including this window in the recents thumbnail, so amounts
            // never sit there readable without unlocking (app_lock.dart
            // pushes this on launch and whenever the setting changes).
            // API 33+ can hide just the recents thumbnail with
            // setRecentsScreenshotEnabled, leaving the user free to
            // screenshot or record the screen the rest of the time, which is
            // all LOCK-2 promises. Below 33 there is no such call, so
            // FLAG_SECURE is used instead, which also blocks screenshots and
            // screen recording for as long as the setting is on rather than
            // only while actually locked or backgrounded — an accepted gap
            // on those older versions.
            "setSecure" -> {
              val secure = call.arguments as Boolean
              if (Build.VERSION.SDK_INT >= 33) {
                setRecentsScreenshotEnabled(!secure)
              } else if (secure) {
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
