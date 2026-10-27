import Flutter
import UIKit
import Checkout_IOS

/// Bridges the `checkout_flutter` method channel to Checkout-IOS: `startCheckout` presents the
/// checkout sheet, and every `CheckoutSDKDelegate` callback is sent back to Dart with the same name.
public class CheckoutFlutterPlugin: NSObject, FlutterPlugin {
  private let channel: FlutterMethodChannel
  /// The SDK keeps its delegate weakly; the plugin (registered for the engine's lifetime) is that delegate.
  private var checkout: CheckoutSDK?
  /// The checkout sheet on screen, if any.
  private weak var sheet: UIViewController?

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "checkout_flutter", binaryMessenger: registrar.messenger())
    let instance = CheckoutFlutterPlugin(channel: channel)
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
      // A checkout that is still open is replaced by the new one, like on Android. The new sheet is
      // presented once the old one is gone; presenting from a sheet that is being dismissed shows nothing.
      if let sheet = self.sheet, sheet.presentingViewController != nil {
        sheet.dismiss(animated: false) {
          self.present(configurations)
          result(true)
        }
      } else {
        self.present(configurations)
        result(true)
      }
    }
  }

  private func present(_ configurations: [String: Any]) {
    let presenter = controller
    let checkout = CheckoutSDK()
    self.checkout = checkout
    checkout.start(configurations: configurations.mapValues { Self.normalized($0) }, delegate: self)
    sheet = presenter.presentedViewController
  }

  /// Dart doubles arrive as binary `NSNumber`s, which `JSONSerialization` writes as 0.10000000000000001.
  /// Sending them as decimal numbers keeps 0.1 as 0.1, like the native example apps do.
  static func normalized(_ value: Any) -> Any {
    switch value {
    case let dictionary as [String: Any]:
      return dictionary.mapValues { normalized($0) }
    case let array as [Any]:
      return array.map { normalized($0) }
    case let number as NSNumber where CFGetTypeID(number) != CFBooleanGetTypeID() && CFNumberIsFloatType(number):
      return NSDecimalNumber(string: "\(number.doubleValue)")
    default:
      return value
    }
  }

  private func send(_ method: String, data: String? = nil) {
    DispatchQueue.main.async {
      self.channel.invokeMethod(method, arguments: data.map { ["data": $0] })
    }
  }
}

// MARK: - CheckoutSDKDelegate
extension CheckoutFlutterPlugin: CheckoutSDKDelegate {
  /// The checkout sheet is presented from the view controller currently on top.
  public var controller: UIViewController {
    let window = UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.windows.first(where: \.isKeyWindow) }
      .first
    var top = window?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top ?? UIViewController()
  }

  public func onReady() {
    send("onReady")
  }

  public func onChargeCreated(data: String) {
    send("onChargeCreated", data: data)
  }

  public func onSuccess(data: String) {
    send("onSuccess", data: data)
  }

  public func onError(data: String) {
    send("onError", data: data)
  }

  public func onClose() {
    send("onClose")
  }
}
