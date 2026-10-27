// Widget tests of the example screens, with the plugin's method channel mocked: the main screen
// shows what the next checkout will do, starts it with the configuration from the settings, and
// lists every callback; the Settings screen saves what it edits.

import 'package:checkout_example/checkout_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const channel = MethodChannel('checkout_flutter');

TestDefaultBinaryMessenger get messenger => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

Future<void> nativeSends(String method, [String? data]) => messenger.handlePlatformMessage(
      'checkout_flutter',
      const StandardMethodCodec().encodeMethodCall(MethodCall(method, data == null ? null : {'data': data})),
      (_) {},
    );

void main() {
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    SharedPreferences.setMockInitialValues({});
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  Future<void> pumpApp(WidgetTester tester, {CheckoutSettings? settings}) async {
    // Tall enough for the whole main screen, so no row is left unbuilt by the lazy list.
    tester.view.physicalSize = const Size(1170, 4500);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await settings?.save();
    await tester.pumpWidget(const CheckoutExampleApp());
    await tester.pumpAndSettle();
  }

  testWidgets('the main screen shows the next checkout and the configuration', (tester) async {
    await pumpApp(tester, settings: CheckoutSettings()..publicKey = 'pk_test_x');
    expect(find.text('Tap Checkout'), findsOneWidget);
    expect(find.text('CHARGE'), findsOneWidget);
    expect(find.text('Sandbox key'), findsOneWidget);
    expect(find.text('0.1 SAR'), findsOneWidget);
    expect(find.text('1 item · Ahmed Sharkawy'), findsOneWidget);
    expect(find.text('Payment type'), findsOneWidget);
    expect(find.text('Callbacks will appear here.\nTap a callback to see its full payload.'), findsOneWidget);
  });

  testWidgets('the key chip tells sandbox, live and missing keys apart', (tester) async {
    await pumpApp(tester, settings: CheckoutSettings()..publicKey = 'pk_live_x');
    expect(find.text('Live key'), findsOneWidget);
  });

  testWidgets('without a public key the checkout does not start', (tester) async {
    await pumpApp(tester, settings: CheckoutSettings()..publicKey = CheckoutSettings.placeholderPublicKey);
    expect(find.text('No public key'), findsOneWidget);
    await tester.tap(find.byKey(const Key('startCheckout')));
    await tester.pumpAndSettle();
    expect(find.text('Public key missing'), findsOneWidget);
    expect(calls, isEmpty);
  });

  testWidgets('Start Checkout sends the configuration and lists the callbacks', (tester) async {
    final settings = CheckoutSettings()..publicKey = 'pk_test_x';
    await pumpApp(tester, settings: settings);

    await tester.tap(find.byKey(const Key('startCheckout')));
    await tester.pump();
    expect(calls.single.method, 'startCheckout');
    final sent = (calls.single.arguments as Map)['configurations'] as Map;
    expect(sent['gateway'], {'publicKey': 'pk_test_x'});
    expect(sent['amount'], 0.1);
    expect(find.text('Opening checkout…'), findsOneWidget);

    await nativeSends('onReady');
    await nativeSends('onChargeCreated', '{"id":"chg_1","status":"INITIATED","amount":0.1,"currency":"SAR"}');
    await nativeSends('onSuccess', '{"chargeId":"chg_1"}');
    await tester.pumpAndSettle();

    expect(find.text('Start Checkout'), findsOneWidget);
    expect(find.text('CALLBACKS (3)'), findsOneWidget);
    expect(find.text('Checkout is ready'), findsOneWidget);
    expect(find.text('chg_1 · INITIATED · 0.1 SAR'), findsOneWidget);
    expect(find.text('Completed · chg_1'), findsOneWidget);

    // Tapping a card shows its payload as pretty JSON.
    await tester.tap(find.text('Completed · chg_1'));
    await tester.pumpAndSettle();
    expect(find.text('{\n  "chargeId": "chg_1"\n}'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('CALLBACKS'), findsOneWidget);
  });

  testWidgets('an error gives the button back and shows the message', (tester) async {
    await pumpApp(tester, settings: CheckoutSettings()..publicKey = 'pk_test_x');
    await tester.tap(find.byKey(const Key('startCheckout')));
    await tester.pump();
    await nativeSends('onError', '{"message":"Invalid key","code":"401"}');
    await tester.pumpAndSettle();
    expect(find.text('Invalid key (401)'), findsOneWidget);
    expect(find.text('Start Checkout'), findsOneWidget);
  });

  testWidgets('View JSON shows the configuration that will be sent', (tester) async {
    await pumpApp(tester, settings: CheckoutSettings()..publicKey = 'pk_test_x');
    await tester.tap(find.text('View JSON'));
    await tester.pumpAndSettle();
    final json = tester.widget<SelectableText>(find.byKey(const Key('configurationJson'))).data!;
    expect(json, contains('"publicKey": "pk_test_x"'));
    expect(json.indexOf('"amount"'), lessThan(json.indexOf('"cardOptions"')), reason: 'keys are sorted');
  });

  testWidgets('Settings saves an edit and the main screen picks it up', (tester) async {
    await pumpApp(tester, settings: CheckoutSettings()..publicKey = 'pk_test_x');
    await tester.tap(find.text('SETTINGS'));
    await tester.pumpAndSettle();

    Future<void> scrollTo(String row, {bool up = false}) async {
      final finder = find.byKey(Key('setting.$row'));
      await tester.scrollUntilVisible(finder, up ? -300 : 300, scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
    }

    await scrollTo('Transaction Mode');
    await tester.tap(find.byKey(const Key('setting.Transaction Mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('setting.Authorize')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('setting.Authorize Type')), findsOneWidget, reason: 'authorize rows appear');

    await scrollTo('First Name', up: true);
    await tester.tap(find.byKey(const Key('setting.First Name')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('settingField')), 'Sara');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect((await CheckoutSettings.load()).firstName, 'Sara');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('AUTHORIZE · VOID'), findsOneWidget);
    expect(find.text('1 item · Sara Sharkawy'), findsOneWidget);
  });
}
