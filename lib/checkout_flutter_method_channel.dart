import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'checkout_flutter_platform_interface.dart';

/// An implementation of [CheckoutFlutterPlatform] that uses method channels.
class MethodChannelCheckoutFlutter extends CheckoutFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('checkout_flutter');

  /// Callback functions for checkout events
  Function()? _onClose;
  Function()? _onReady;
  Function(String)? _onSuccess;
  Function(String)? _onError;

  MethodChannelCheckoutFlutter() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onClose':
        _onClose?.call();
        break;
      case 'onReady':
        _onReady?.call();
        break;
      case 'onSuccess':
        final data = call.arguments['data'] as String? ?? '';
        _onSuccess?.call(data);
        break;
      case 'onError':
        final data = call.arguments['data'] as String? ?? '';
        _onError?.call(data);
        break;
    }
  }

  @override
  Future<bool> startCheckout({
    required Map<String, dynamic> configurations,
    Function()? onClose,
    Function()? onReady,
    Function(String)? onSuccess,
    Function(String)? onError,
  }) async {
    _onClose = onClose;
    _onReady = onReady;
    _onSuccess = onSuccess;
    _onError = onError;

    try {
      final result = await methodChannel.invokeMethod<bool>('startCheckout', {
        'configurations': configurations,
      });
      return result ?? false;
    } catch (e) {
      print('Error starting checkout: $e');
      return false;
    }
  }
}
