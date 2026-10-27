// Lets the integration tests (integration_test/readme_configuration_test.dart) drive the app: use a
// public key passed at build time, change any configuration key and start the checkout by itself.
// Same behaviour as UITestHooks.swift / UITestHooks.kt in the native example apps.

class TestHooks {
  /// True when the app was started by an integration test.
  static bool isActive = false;

  /// Start the checkout as soon as the main screen appears.
  static bool autoStart = false;

  /// Replaces `gateway.publicKey` when not empty.
  static String publicKey = '';

  /// Merged into the configuration (nested maps are merged key by key); a `null` value removes that key.
  static Map<String, dynamic> overrides = {};

  static void reset() {
    isActive = false;
    autoStart = false;
    publicKey = '';
    overrides = {};
  }

  /// Applies the test's changes on top of the configuration built from the settings.
  static Map<String, dynamic> apply(Map<String, dynamic> configuration) {
    if (!isActive) return configuration;
    var result = configuration;
    if (publicKey.isNotEmpty) {
      result = merge(result, {
        'gateway': {'publicKey': publicKey},
      });
    }
    return merge(result, overrides);
  }

  static Map<String, dynamic> merge(Map<String, dynamic> base, Map<String, dynamic> overrides) {
    final result = Map<String, dynamic>.of(base);
    overrides.forEach((key, value) {
      final current = result[key];
      if (value == null) {
        result.remove(key);
      } else if (value is Map<String, dynamic> && current is Map<String, dynamic>) {
        result[key] = merge(current, value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }
}
