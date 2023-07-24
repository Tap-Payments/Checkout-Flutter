import Flutter
import UIKit
import CheckoutSDK_iOS
import CommonDataModelsKit_iOS
import TapUIKit_iOS
import LocalisationManagerKit_iOS

public class CheckoutFlutterPlugin: NSObject, FlutterPlugin {
  public var argsSessionParameters:[String:Any]?
  var flutterResult: FlutterResult?
   var argsDataSource:[String:Any]?{
        didSet{
          argsSessionParameters = argsDataSource?["configuration"] as? [String : Any]
        }
      }

  public static func register(with registrar: FlutterPluginRegistrar) {

    let channel = FlutterMethodChannel(name: "checkout_flutter", binaryMessenger: registrar.messenger())
    let instance = CheckoutFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    switch call.method {
    case "start":
        let jsonData = try! JSONSerialization.data(withJSONObject: arguments, options: [])
        let decoded = String(data: call.arguments["configuration"], encoding: .utf8)!
        let decoder = JSONDecoder()
      let dict = call.arguments as? [String: Any]
      argsDataSource = dict
        let checkout: TapCheckout = .init()
        TapCheckout.flippingStatus = argsDataSource
      result("iOS " + UIDevice.current.systemVersion)
      case "terminate_session":
    
      return
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
