import 'checkout_flutter_platform_interface.dart';

/// Presents the Tap checkout and reports what happens through the callbacks.
///
/// [configurations] is the checkout configuration map; see the configuration reference in the
/// README. Nested objects are maps and arrays are lists. `gateway.publicKey` is required.
///
/// The callbacks are the same on iOS and Android:
/// - [onReady]: the checkout finished loading and is ready for input.
/// - [onChargeCreated]: a charge or authorization was created; `data` is a JSON string.
/// - [onSuccess]: the checkout completed (including after 3D Secure); `data` is a JSON string.
/// - [onError]: the checkout failed; `data` is a JSON string (some native errors are plain text).
/// - [onClose]: the user closed the checkout.
///
/// The checkout is dismissed before [onSuccess], [onError] and [onClose] are called.
///
/// Returns true when the checkout was started. It returns false, without calling any callback, when
/// the native side rejects the call (for example, no public key).
Future<bool> startCheckout({
  required Map<String, dynamic> configurations,
  Function()? onReady,
  Function(String data)? onChargeCreated,
  Function(String data)? onSuccess,
  Function(String data)? onError,
  Function()? onClose,
  @Deprecated('Use onClose, which is called on both platforms. Android now reports a cancel as onClose.')
  Function()? onCancel,
}) {
  return CheckoutFlutterPlatform.instance.startCheckout(
    configurations: configurations,
    onReady: onReady,
    onChargeCreated: onChargeCreated,
    onSuccess: onSuccess,
    onError: onError,
    onClose: () {
      onClose?.call();
      onCancel?.call();
    },
  );
}
