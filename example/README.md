# checkout_flutter examples

Two example apps that run the same Dart code and differ only in how iOS pulls in Checkout-IOS:

| App | iOS integration |
|---|---|
| [`spm_example`](spm_example) | Swift Package Manager |
| [`cocoapods_example`](cocoapods_example) | CocoaPods |

The screens, settings and unit tests live in [`shared`](shared) (`package:checkout_example`); each app's `lib/main.dart` only starts it.

Add your Tap sandbox key first ([Add your keys](#add-your-keys)), then:

```bash
cd spm_example
FLUTTER_SWIFT_PACKAGE_MANAGER=true flutter run --dart-define=TAP_PUBLIC_KEY=pk_test_...
```

```bash
cd cocoapods_example
flutter run --dart-define=TAP_PUBLIC_KEY=pk_test_...
```

See [Run the SPM example](../README.md#run-the-spm-example), [Run the CocoaPods example](../README.md#run-the-cocoapods-example) and [Tests](../README.md#tests) in the plugin README for the details.

## Add your keys

The apps need a Tap **sandbox public key** (`pk_test_...`). Keys are never committed. Give the apps a key in one of these ways:

1. **On the command line** (nothing to edit). Add `TAP_MERCHANT_ID` only if you need a specific merchant:

   ```bash
   flutter run --dart-define=TAP_PUBLIC_KEY=pk_test_... --dart-define=TAP_MERCHANT_ID=...
   ```

2. **In code.** Replace the placeholder `YOUR_TAP_PUBLIC_KEY` in [`shared/lib/src/keys.dart`](shared/lib/src/keys.dart). Both apps read it from there; don't commit the change.

3. **Several saved keys** to switch between in the app. From `example/`, copy the example file and fill it in:

   ```bash
   cp shared/assets/keys.local.example.json shared/assets/keys.local.json
   ```

   ```json
   [
     { "name": "My sandbox key", "publicKey": "pk_test_...", "merchantId": "" },
     { "name": "Another merchant", "publicKey": "pk_test_...", "merchantId": "" }
   ]
   ```

   `keys.local.json` is gitignored. Debug builds then show **Settings > Saved Keys**; pick one and it fills in Public Key and Merchant Id. Rebuild (or hot restart) after editing the file.

4. **In the app**, under **Settings > SDK Configuration > Public Key**. Settings are saved on the device.

The key must be registered with Tap for the app's bundle id / package name. Both example apps use the bundle id `com.example.checkoutFlutterExample` (iOS) and the package name `com.example.checkout_flutter_example` (Android); register them for your key, or change them to ones your key is registered for.
