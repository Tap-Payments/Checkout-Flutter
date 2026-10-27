import 'package:checkout_flutter/checkout_flutter.dart';
import 'package:checkout_flutter/checkout_flutter_method_channel.dart';
import 'package:checkout_flutter/checkout_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TestDefaultBinaryMessenger get messenger =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelCheckoutFlutter platform;
  final calls = <MethodCall>[];
  Object? nativeResult = true;

  /// Sends a callback from the "native" side, like the iOS and Android plugins do.
  Future<void> nativeSends(String method, [String? data]) async {
    final message = const StandardMethodCodec()
        .encodeMethodCall(MethodCall(method, data == null ? null : {'data': data}));
    await messenger.handlePlatformMessage('checkout_flutter', message, (_) {});
  }

  setUp(() {
    calls.clear();
    nativeResult = true;
    platform = MethodChannelCheckoutFlutter();
    CheckoutFlutterPlatform.instance = platform;
    messenger.setMockMethodCallHandler(platform.methodChannel, (call) async {
      calls.add(call);
      if (nativeResult is PlatformException) throw nativeResult!;
      return nativeResult;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(platform.methodChannel, null));

  test('the method channel is the default platform', () {
    expect(MethodChannelCheckoutFlutter(), isA<CheckoutFlutterPlatform>());
  });

  test('startCheckout sends the configurations unchanged', () async {
    final configurations = {
      'gateway': {'publicKey': 'pk_test_x'},
      'amount': 0.1,
      'order': {
        'items': [
          {'quantity': 1, 'amount': 0.1},
        ],
      },
    };
    expect(await startCheckout(configurations: configurations), isTrue);
    expect(calls.single.method, 'startCheckout');
    expect(calls.single.arguments, {'configurations': configurations});
  });

  test('a rejected start returns false', () async {
    nativeResult = PlatformException(code: 'INVALID_CONFIGURATION');
    expect(await startCheckout(configurations: {}), isFalse);
  });

  test('every native callback reaches its Dart callback', () async {
    final events = <String>[];
    await startCheckout(
      configurations: {},
      onReady: () => events.add('ready'),
      onChargeCreated: (data) => events.add('charge $data'),
      onSuccess: (data) => events.add('success $data'),
      onError: (data) => events.add('error $data'),
      onClose: () => events.add('close'),
    );
    await nativeSends('onReady');
    await nativeSends('onChargeCreated', '{"id":"chg_1"}');
    await nativeSends('onSuccess', '{"chargeId":"chg_1"}');
    await nativeSends('onError', '{"error":"x"}');
    await nativeSends('onClose');
    expect(events, [
      'ready',
      'charge {"id":"chg_1"}',
      'success {"chargeId":"chg_1"}',
      'error {"error":"x"}',
      'close',
    ]);
  });

  test('the deprecated onCancel still fires when the checkout closes', () async {
    var cancelled = false;
    // ignore: deprecated_member_use_from_same_package
    await startCheckout(configurations: {}, onCancel: () => cancelled = true);
    await nativeSends('onClose');
    expect(cancelled, isTrue);
  });

  test('a new checkout replaces the callbacks of the previous one', () async {
    final events = <String>[];
    await startCheckout(configurations: {}, onClose: () => events.add('first'));
    await startCheckout(configurations: {}, onClose: () => events.add('second'));
    await nativeSends('onClose');
    expect(events, ['second']);
  });

  test('a callback without data gets an empty string', () async {
    String? received;
    await startCheckout(configurations: {}, onError: (data) => received = data);
    await nativeSends('onError');
    expect(received, '');
  });
}
