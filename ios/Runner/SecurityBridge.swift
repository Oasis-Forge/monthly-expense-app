import Flutter
import UIKit

/// Keeps App Lock's promise (LOCK-2) covering the app the instant it leaves
/// the foreground, not only once Dart has drawn the lock screen: iOS takes
/// its app-switcher snapshot the moment the app resigns active, which is
/// before Dart's own lifecycle callback would ever get a chance to react.
///
/// Matches `MainActivity.kt` on Android, which sets FLAG_SECURE on the same
/// signal instead. `app_lock.dart` pushes whether App Lock is turned on
/// through this channel at launch and whenever the setting changes; this
/// class only remembers that boolean and shows or hides a plain cover.
// NSObject: #selector and the Notification Center observers below need an
// Objective-C-compatible class, which a plain Swift class isn't.
final class SecurityBridge: NSObject {
  static let shared = SecurityBridge()

  static let channelName = "com.oasisforge.monthlyexpenses/security"

  /// Whether App Lock is turned on right now (the setting, not only while
  /// this session happens to be locked): the cover goes up for every
  /// switcher snapshot while it is, same as Android's FLAG_SECURE.
  private var secure = false
  private var cover: UIView?

  private override init() {
    super.init()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(willResignActive),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
  }

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "setSecure":
        self?.secure = (call.arguments as? Bool) ?? false
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func keyWindow() -> UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.keyWindow }
      .first
  }

  @objc private func willResignActive() {
    guard secure, cover == nil, let window = keyWindow() else { return }
    let view = UIView(frame: window.bounds)
    view.backgroundColor = .systemBackground
    window.addSubview(view)
    cover = view
  }

  @objc private func didBecomeActive() {
    cover?.removeFromSuperview()
    cover = nil
  }
}
