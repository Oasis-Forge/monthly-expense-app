import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Required by flutter_local_notifications so a tapped note reminder or
    // nudge reaches the app (NOTE-6, NUDGE-1). Must be set before launch
    // finishes -- set any later (e.g. in didInitializeImplicitFlutterEngine)
    // and a tap that launches the app from a terminated state can be missed.
    // `FlutterAppDelegate` already conforms to `UNUserNotificationCenterDelegate`,
    // so `as` rather than `as?`.
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // The home-screen widget's channel (WID-3, WID-5).
    if let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "HomeWidgetBridge"
    ) {
      HomeWidgetBridge.shared.attach(to: registrar.messenger())
    }
    // Covers the app while App Lock is on, the moment it resigns active
    // (LOCK-2).
    if let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "SecurityBridge"
    ) {
      SecurityBridge.shared.attach(to: registrar.messenger())
    }
  }
}
