// Checks, on a simulator or emulator against the Tap sandbox, that the configuration values
// documented in README.md give the callbacks the README says. Each test starts the checkout with one
// value changed (through TestHooks in the shared example), then waits for the callback it expects.
// Port of ReadmeConfigurationTests in the native repositories. The checkout itself is a native view,
// so these tests look at the callbacks only; the native UI tests also check what the sheet shows.
//
// Run (the sandbox public key is passed in, never committed):
//   flutter test integration_test --dart-define=TAP_PUBLIC_KEY=pk_test_...

import 'package:checkout_example/checkout_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const publicKey = String.fromEnvironment('TAP_PUBLIC_KEY');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  String log(WidgetTester tester) =>
      (tester.widget<Text>(find.byKey(const Key('callbackLog'))).data ?? '');

  /// Starts the app on the web demo defaults, with [overrides] merged into the configuration, and
  /// lets it start the checkout by itself.
  Future<void> open(WidgetTester tester, [Map<String, dynamic> overrides = const {}, String? key]) async {
    await CheckoutSettings.reset();
    TestHooks.isActive = true;
    TestHooks.autoStart = true;
    TestHooks.publicKey = key ?? publicKey;
    TestHooks.overrides = overrides;
    addTearDown(TestHooks.reset);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const CheckoutExampleApp());
  }

  /// Pumps until one of [callbacks] is in the log; returns the one that arrived, or null.
  Future<String?> waitFor(WidgetTester tester, List<String> callbacks, {int seconds = 60}) async {
    final end = DateTime.now().add(Duration(seconds: seconds));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 500));
      final text = log(tester);
      for (final callback in callbacks) {
        if (text.contains('$callback:')) return callback;
      }
    }
    return null;
  }

  void result(String name, String outcome) => debugPrint('RESULT | $name | $outcome');

  Future<void> expectReady(WidgetTester tester, String name, Map<String, dynamic> overrides) async {
    await open(tester, overrides);
    final callback = await waitFor(tester, ['onReady', 'onError']);
    result(name, callback ?? 'no callback');
    expect(callback, 'onReady', reason: log(tester));
  }

  group('README configuration', skip: publicKey.isEmpty ? 'Pass --dart-define=TAP_PUBLIC_KEY=pk_test_...' : null, () {
    // SDK and gateway

    testWidgets('the default configuration opens the checkout', (tester) async {
      await expectReady(tester, 'defaults', {});
    });

    testWidgets('an invalid public key reports onError', (tester) async {
      await open(tester, {}, 'pk_test_invalidKey000000000000');
      final callback = await waitFor(tester, ['onError', 'onReady']);
      result('gateway.publicKey invalid', callback ?? 'no callback');
      expect(callback, 'onError', reason: log(tester));
    });

    testWidgets('an unknown merchant id', (tester) async {
      await open(tester, {
        'gateway': {'merchantId': '000000'},
      });
      result('gateway.merchantId unknown', await waitFor(tester, ['onReady', 'onError']) ?? 'no callback');
    });

    testWidgets('an invalid hash string', (tester) async {
      await open(tester, {'hashString': 'notARealHash'});
      result('hashString invalid', await waitFor(tester, ['onReady', 'onError']) ?? 'no callback');
    });

    for (final language in ['en', 'ar']) {
      testWidgets('language $language', (tester) async {
        await expectReady(tester, 'language $language', {'language': language});
      });
    }

    for (final theme in ['light', 'dark', 'light_mono', 'dark_colored']) {
      testWidgets('themeMode $theme', (tester) async {
        await expectReady(tester, 'themeMode $theme', {'themeMode': theme});
      });
    }

    testWidgets('paymentType CARD', (tester) async {
      await expectReady(tester, 'paymentType CARD', {'paymentType': 'CARD'});
    });

    testWidgets('selectedCurrency KWD', (tester) async {
      final currency = {'selectedCurrency': 'KWD', 'order': {'currency': 'KWD'}};
      await expectReady(tester, 'selectedCurrency KWD', currency);
    });

    // Card options

    testWidgets('card options switched off', (tester) async {
      await expectReady(tester, 'cardOptions off', {
        'cardOptions': {'showBrands': false, 'collectHolderName': false, 'saveCardOption': 'none'},
      });
    });

    testWidgets('the card scanner input', (tester) async {
      await expectReady(tester, 'cardOptions.alternativeCardInputs.cardScanner', {
        'cardOptions': {
          'alternativeCardInputs': {'cardScanner': true},
        },
      });
    });

    // Transaction

    testWidgets('transaction.mode authorize', (tester) async {
      final charge = CheckoutSettings().makeConfiguration()['transaction']['charge'];
      await expectReady(tester, 'transaction.mode authorize', {
        'transaction': {'mode': 'authorize', 'charge': null, 'authorize': charge},
      });
    });

    testWidgets('3D Secure off', (tester) async {
      await expectReady(tester, 'threeDSecure false', {
        'transaction': {
          'charge': {'threeDSecure': false},
        },
      });
    });

    testWidgets('no airline object', (tester) async {
      await expectReady(tester, 'airline omitted', {
        'transaction': {
          'charge': {'airline': null},
        },
      });
    });
  });
}
