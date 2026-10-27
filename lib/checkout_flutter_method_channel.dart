import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'checkout_flutter_platform_interface.dart';

/// An implementation of [CheckoutFlutterPlatform] that uses method channels.
class MethodChannelCheckoutFlutter extends CheckoutFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('checkout_flutter');

  /// Callbacks of the checkout that was started last.
  Function()? _onReady;
  Function(String)? _onChargeCreated;
  Function(String)? _onSuccess;
  Function(String)? _onError;
  Function()? _onClose;

  MethodChannelCheckoutFlutter() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    String data() => (call.arguments as Map?)?['data'] as String? ?? '';
    switch (call.method) {
      case 'onReady':
        _onReady?.call();
      case 'onChargeCreated':
        _onChargeCreated?.call(data());
      case 'onSuccess':
        _onSuccess?.call(data());
      case 'onError':
        _onError?.call(data());
      case 'onClose':
        _onClose?.call();
    }
  }

  @override
  Future<bool> startCheckout({
    required Map<String, dynamic> configurations,
    Function()? onReady,
    Function(String data)? onChargeCreated,
    Function(String data)? onSuccess,
    Function(String data)? onError,
    Function()? onClose,
  }) async {
    _onReady = onReady;
    _onChargeCreated = onChargeCreated;
    _onSuccess = onSuccess;
    _onError = onError;
    _onClose = onClose;

    try {
      final result = await methodChannel.invokeMethod<bool>('startCheckout', {
        'configurations': configurations,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('checkout_flutter: could not start the checkout: ${e.code} ${e.message}');
      return false;
    }
  }
}
