import Flutter
import UIKit

/// Apps built with the iOS 27 SDK (Xcode 27) only launch when they use the UIScene life cycle.
/// Flutter 3.32 has no scene delegate of its own, so this one hosts the FlutterViewController from
/// Main.storyboard and registers the plugins with its engine. Newer Flutter releases provide
/// FlutterSceneDelegate, which does the same.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    let engine: FlutterEngine? = (window?.rootViewController as? FlutterViewController)?.engine
    if let engine {
      GeneratedPluginRegistrant.register(with: engine)
    }
  }
}
