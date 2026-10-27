import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  // The plugins are registered in SceneDelegate, which owns the Flutter view.
  override func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
}
