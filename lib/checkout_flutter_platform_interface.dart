import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'checkout_flutter_method_channel.dart';

abstract class CheckoutFlutterPlatform extends PlatformInterface {
  /// Constructs a CheckoutFlutterPlatform.
  CheckoutFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static CheckoutFlutterPlatform _instance = MethodChannelCheckoutFlutter();

  /// The default instance of [CheckoutFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelCheckoutFlutter].
  static CheckoutFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CheckoutFlutterPlatform] when
  /// they register themselves.
  static set instance(CheckoutFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
