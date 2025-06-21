import Flutter
import UIKit
import Checkout_IOS

public class CheckoutFlutterPlugin: NSObject, FlutterPlugin {
  private var channel: FlutterMethodChannel?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "checkout_flutter", binaryMessenger: registrar.messenger())
    let instance = CheckoutFlutterPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startCheckout":
      startCheckout(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func startCheckout(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let configurations = arguments["configurations"] as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Configurations are required", details: nil))
      return
    }
    
    DispatchQueue.main.async {
      // Directly start the checkout SDK
      CheckoutSDK().start(configurations: configurations, delegate: self)
      result(true)
    }
  }
}

// MARK: - CheckoutSDKDelegate
extension CheckoutFlutterPlugin: CheckoutSDKDelegate {
  public func onClose() {
    channel?.invokeMethod("onClose", arguments: nil)
  }
  
  public func onReady() {
    channel?.invokeMethod("onReady", arguments: nil)
  }
  
  public func onSuccess(data: String) {
    channel?.invokeMethod("onSuccess", arguments: ["data": data])
  }
  
  public func onError(data: String) {
    channel?.invokeMethod("onError", arguments: ["data": data])
  }
  
  public var controller: UIViewController {
    // Return the root view controller for the SDK to present on
    return UIApplication.shared.windows.first?.rootViewController ?? UIViewController()
  }
}
