import 'checkout_flutter_platform_interface.dart';

/// Start the checkout process
///
/// [configurations] - Required checkout configurations map
/// [onClose] - Callback when checkout is closed
/// [onReady] - Callback when checkout is ready
/// [onSuccess] - Callback when checkout succeeds with data
/// [onError] - Callback when checkout fails with error message
/// [onCancel] - Callback when checkout is cancelled (Android only)
///
/// Returns true if checkout started successfully, false otherwise
Future<bool> startCheckout({
  required Map<String, dynamic> configurations,
  Function()? onClose,
  Function()? onReady,
  Function(String)? onSuccess,
  Function(String)? onError,
  Function()? onCancel,
}) {
  return CheckoutFlutterPlatform.instance.startCheckout(
    configurations: configurations,
    onClose: onClose,
    onReady: onReady,
    onSuccess: onSuccess,
    onError: onError,
    onCancel: onCancel,
  );
}
