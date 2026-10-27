# checkout_flutter examples

Two example apps that run the same Dart code and differ only in how iOS pulls in Checkout-IOS:

| App | iOS integration |
|---|---|
| [`spm_example`](spm_example) | Swift Package Manager |
| [`cocoapods_example`](cocoapods_example) | CocoaPods |

The screens, settings and unit tests live in [`shared`](shared) (`package:checkout_example`); each app's `lib/main.dart` only starts it.

```bash
cd spm_example
FLUTTER_SWIFT_PACKAGE_MANAGER=true flutter run --dart-define=TAP_PUBLIC_KEY=pk_test_...
```

```bash
cd cocoapods_example
flutter run --dart-define=TAP_PUBLIC_KEY=pk_test_...
```

See [Example apps](../README.md#example-apps) and [Tests](../README.md#tests) in the plugin README.
