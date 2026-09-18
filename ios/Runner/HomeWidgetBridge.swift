import Flutter
import WidgetKit

/// The app's side of the home-screen widget (WID-3, WID-5).
///
/// It matches `MainActivity.kt` on Android: the app hands over the finished
/// numbers as one JSON string, which go into the App Group where the widget
/// extension can read them without the app running, and a tap on the widget
/// comes back the other way. Nothing about the database ever crosses.
final class HomeWidgetBridge {
  static let shared = HomeWidgetBridge()

  static let channelName = "com.oasisforge.monthlyexpenses/home_widget"
  private static let payloadKey = "payload"
  private static let appGroupId = "group.com.oasisforge.monthlyexpenses"
  private static let urlScheme = "monthlyexpenses"
  private static let urlHost = "widget"

  private var channel: FlutterMethodChannel?

  /// A tap that arrived before Dart was listening, until it asks.
  private var pending: String?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "update":
        guard let json = call.arguments as? String else {
          result(FlutterError(code: "bad_payload", message: nil, details: nil))
          return
        }
        UserDefaults(suiteName: Self.appGroupId)?
          .set(json, forKey: Self.payloadKey)
        WidgetCenter.shared.reloadAllTimelines()
        result(nil)
      case "launchAction":
        let action = self?.pending
        self?.pending = nil
        result(action)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
  }

  /// Handles `monthlyexpenses://widget/<action>` from a tapped widget.
  func handle(url: URL) {
    guard url.scheme == Self.urlScheme, url.host == Self.urlHost else { return }
    let action = url.lastPathComponent
    guard !action.isEmpty else { return }
    if let channel {
      channel.invokeMethod("tapped", arguments: action)
    } else {
      pending = action
    }
  }
}
