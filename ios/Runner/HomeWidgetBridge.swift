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
  private static let appGroupId = "group.com.oasisforge.monthlyexpenses"
  private static let urlScheme = "monthlyexpenses"
  private static let urlHost = "widget"

  /// Where the payload goes: a file in the App Group container, in a folder
  /// excluded from iCloud and computer backups (BAK-8). The widget reads the
  /// same file (`WidgetPayload.read` in MonthlyExpensesWidget.swift), so
  /// these names must match there.
  private static let payloadFolder = "WidgetPayload"
  private static let payloadFile = "payload.json"

  /// Where 1.31.1 and earlier kept the payload: the App Group's
  /// UserDefaults suite, whose plist no app can keep out of a backup.
  private static let legacyPayloadKey = "payload"

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
        do {
          try Self.store(json)
        } catch {
          result(
            FlutterError(
              code: "write_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
          return
        }
        // The file is written, so the copy an older version kept in the
        // suite has no reader left and would only linger in backups.
        UserDefaults(suiteName: Self.appGroupId)?
          .removeObject(forKey: Self.legacyPayloadKey)
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

  /// Writes the payload where the widget reads it. The folder is marked
  /// excluded from backup every time, before the file goes in, so the
  /// figures are never in a folder a backup would take; the mark sits on
  /// the folder because replacing the file, as an atomic write does, would
  /// drop a mark set on the file itself. Atomic, so the widget never reads
  /// half a payload.
  private static func store(_ json: String) throws {
    guard
      var folder = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: appGroupId)?
        .appendingPathComponent(payloadFolder, isDirectory: true)
    else {
      throw CocoaError(.fileNoSuchFile)
    }
    try FileManager.default.createDirectory(
      at: folder,
      withIntermediateDirectories: true
    )
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try folder.setResourceValues(values)
    let file = folder.appendingPathComponent(payloadFile, isDirectory: false)
    try Data(json.utf8).write(to: file, options: .atomic)
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
