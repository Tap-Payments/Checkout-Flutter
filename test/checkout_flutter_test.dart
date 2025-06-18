import 'package:flutter_test/flutter_test.dart';
import 'package:checkout_flutter/checkout_flutter.dart';
import 'package:checkout_flutter/checkout_flutter_platform_interface.dart';
import 'package:checkout_flutter/checkout_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCheckoutFlutterPlatform
    with MockPlatformInterfaceMixin
    implements CheckoutFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CheckoutFlutterPlatform initialPlatform = CheckoutFlutterPlatform.instance;

  test('$MethodChannelCheckoutFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCheckoutFlutter>());
  });

  test('getPlatformVersion', () async {
    CheckoutFlutter checkoutFlutterPlugin = CheckoutFlutter();
    MockCheckoutFlutterPlatform fakePlatform = MockCheckoutFlutterPlatform();
    CheckoutFlutterPlatform.instance = fakePlatform;

    expect(await checkoutFlutterPlugin.getPlatformVersion(), '42');
  });
}
