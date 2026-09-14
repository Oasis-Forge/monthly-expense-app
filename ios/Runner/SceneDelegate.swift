import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  /// A widget tapped while the app wasn't running (WID-3).
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    for context in connectionOptions.urlContexts {
      HomeWidgetBridge.shared.handle(url: context.url)
    }
  }

  /// A widget tapped while it was.
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    super.scene(scene, openURLContexts: URLContexts)
    for context in URLContexts {
      HomeWidgetBridge.shared.handle(url: context.url)
    }
  }
}
