/// Your Tap sandbox public key (pk_test_...). Replace the placeholder here, or pass it when you run:
///   flutter run --dart-define=TAP_PUBLIC_KEY=pk_test_...
class Keys {
  static const publicKey = String.fromEnvironment('TAP_PUBLIC_KEY', defaultValue: 'YOUR_TAP_PUBLIC_KEY');

  /// Optional; leave empty to use the merchant the key belongs to.
  static const merchantId = String.fromEnvironment('TAP_MERCHANT_ID');
}
