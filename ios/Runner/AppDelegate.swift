import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
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
