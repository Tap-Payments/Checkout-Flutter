// Checks that the configuration the example apps send matches the defaults documented in README.md
// (which are the Tap web demo's) and the mapping rules of the configuration reference.
// Port of CheckoutSettingsTests.swift (iOS) and CheckoutSettingsTest.kt (Android).

import 'package:checkout_example/checkout_example.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> config([CheckoutSettings? settings]) => (settings ?? CheckoutSettings()).makeConfiguration();

Map<String, dynamic> map(Map<String, dynamic> parent, String key) => parent[key] as Map<String, dynamic>;

CheckoutSettings settingsWith(void Function(CheckoutSettings s) change) => CheckoutSettings()..let(change);

extension on CheckoutSettings {
  void let(void Function(CheckoutSettings s) change) => change(this);
}

void main() {
  test('defaults match the README', () {
    final c = config(settingsWith((s) => s.publicKey = 'pk_test_x'));
    expect(c['open'], true);
    expect(c['hashString'], '');
    expect(c['checkoutMode'], 'popup');
    expect(c['language'], 'en');
    expect(c['themeMode'], 'light');
    expect(c['paymentType'], 'ALL');
    expect(c['supportedPaymentMethods'], 'ALL');
    expect(c['selectedCurrency'], 'SAR');
    expect(c['supportedCurrencies'], 'ALL');
    expect(c['isApplePayAvailableOnClient'], true);
    expect(c['amount'], 0.1);
    expect(c['gateway'], {'publicKey': 'pk_test_x'});
    for (final key in ['supportedRegions', 'supportedCountries', 'supportedPaymentTypes', 'supportedSchemes']) {
      expect(c.containsKey(key), isFalse, reason: '$key should be omitted');
    }
  });

  test('customer defaults', () {
    expect(map(config(), 'customer'), {
      'firstName': 'Ahmed',
      'lastName': 'Sharkawy',
      'email': 'example@gmail.com',
      'phone': {'countryCode': '20', 'number': '1099137773'},
    });
    expect(map(config(settingsWith((s) => s.customerId = 'cus_1')), 'customer')['id'], 'cus_1');
  });

  test('card option defaults', () {
    expect(map(config(), 'cardOptions'), {
      'showBrands': true,
      'showLoadingState': false,
      'collectHolderName': true,
      'preLoadCardName': '',
      'cardNameEditable': true,
      'cardFundingSource': 'all',
      'saveCardOption': 'all',
      'forceLtr': false,
    });
    final withInputs = map(config(settingsWith((s) => s..cardScanner = true..cardNFC = true)), 'cardOptions');
    expect(withInputs['alternativeCardInputs'], {'cardScanner': true, 'cardNFC': true});
    final scannerOnly = map(config(settingsWith((s) => s.cardScanner = true)), 'cardOptions');
    expect(scannerOnly['alternativeCardInputs'], {'cardScanner': true});
  });

  test('order defaults', () {
    final order = map(config(), 'order');
    expect(order['id'], '');
    expect(order['currency'], 'SAR');
    expect(order['amount'], 0.1);
    expect(order['items'], [
      {'amount': 0.1, 'currency': 'SAR', 'name': 'Item Title 1', 'quantity': 1, 'description': 'item description 1'},
    ]);
    expect(order.containsKey('discount'), isFalse, reason: 'no discount by default');
  });

  test('charge transaction defaults', () {
    final transaction = map(config(), 'transaction');
    expect(transaction['mode'], 'charge');
    expect(transaction['charge'], {
      'saveCard': true,
      'auto': {'type': 'VOID', 'time': 100},
      'redirect': {'url': 'https://demo.tap.company/v2/sdk/checkout'},
      'threeDSecure': true,
      'subscription': {'type': 'SCHEDULED', 'amount_variability': 'FIXED', 'txn_count': 0},
      'airline': {
        'reference': {'booking': ''},
      },
    });
  });

  test('authorize uses an object named after the mode', () {
    final transaction = map(config(settingsWith((s) => s..mode = 'authorize'..authorizeType = 'CAPTURE')), 'transaction');
    expect(transaction['mode'], 'authorize');
    expect(transaction.containsKey('charge'), isFalse);
    expect(map(transaction, 'authorize')['auto'], {'type': 'CAPTURE', 'time': 100});
  });

  test('discount and totals', () {
    final percent = settingsWith((s) => s
      ..items = [OrderItem(amount: 0.1), OrderItem(name: 'Item Title 2', amount: 0.2)]
      ..discountType = 'P'
      ..discountValue = 10);
    expect(config(percent)['amount'], 0.27);
    expect(map(config(percent), 'order')['discount'], {'type': 'P', 'value': 10.0});

    final tooMuch = settingsWith((s) => s..discountType = 'F'..discountValue = 5);
    expect(config(tooMuch)['amount'], 1.0, reason: 'a total of 0 or less becomes 1, like the web demo');

    final quantity = settingsWith((s) => s.items = [OrderItem(quantity: 3, amount: 0.1)]);
    expect(config(quantity)['amount'], 0.3);
  });

  test('auto and empty values are not sent', () {
    final c = config(settingsWith((s) => s..language = 'auto'..theme = 'auto'));
    expect(c.containsKey('language'), isFalse);
    expect(c.containsKey('themeMode'), isFalse);
    expect(map(c, 'gateway').containsKey('merchantId'), isFalse);
    expect(map(config(settingsWith((s) => s.merchantId = 'm_1')), 'gateway')['merchantId'], 'm_1');
  });

  test('lists and collapsing', () {
    expect(config(settingsWith((s) => s.supportedCurrencies = ['AUTO', 'SAR']))['supportedCurrencies'], 'AUTO');
    expect(config(settingsWith((s) => s.supportedCurrencies = ['SAR', 'ALL']))['supportedCurrencies'], 'ALL');
    expect(config(settingsWith((s) => s.supportedCurrencies = ['SAR', 'KWD']))['supportedCurrencies'], ['SAR', 'KWD']);
    expect(config(settingsWith((s) => s.supportedPaymentMethods = ['VISA']))['supportedPaymentMethods'], ['VISA']);
    expect(config(settingsWith((s) => s.supportedCountries = ['SA']))['supportedCountries'], ['SA']);
  });

  test('agreement and subscription', () {
    final unscheduled = map(
      map(config(settingsWith((s) => s..agreedPayment = true..agreementType = 'UNSCHEDULED')), 'transaction'),
      'charge',
    );
    expect(unscheduled['agreement'], {'type': 'UNSCHEDULED'});
    expect(unscheduled.containsKey('subscription'), isFalse, reason: 'no subscription when UNSCHEDULED');
    expect(unscheduled.containsKey('applePayRecurringPaymentRequest'), isTrue);

    final defined = map(
      map(config(settingsWith((s) => s..agreedPayment = true..numberOfPayments = 'Defined'..paymentCount = 4)),
          'transaction'),
      'charge',
    );
    expect(defined['agreement'], {'type': 'SCHEDULED', 'amount_variability': 'FIXED'});
    expect(map(defined, 'subscription')['txn_count'], 4);
  });

  test('the Apple Pay recurring request uses a UTC timestamp with milliseconds', () {
    final now = DateTime.utc(2026, 10, 27, 9, 5, 3, 7, 999);
    final charge = map(
      map(settingsWith((s) => s.agreedPayment = true).makeConfiguration(now: now), 'transaction'),
      'charge',
    );
    final request = map(charge, 'applePayRecurringPaymentRequest');
    expect(map(request, 'regularBilling')['recurringPaymentStartDate'], '2026-10-27T09:05:03.007Z');
    expect(request['managementURL'], 'https://demo.tap.company');
  });

  test('airline is sent unless no', () {
    expect(map(map(config(settingsWith((s) => s.airline = 'no')), 'transaction'), 'charge').containsKey('airline'),
        isFalse);
    final yes = map(
      map(config(settingsWith((s) => s..airline = 'yes'..bookingReference = 'ABC123')), 'transaction'),
      'charge',
    );
    expect(yes['airline'], {
      'reference': {'booking': 'ABC123'},
    });
  });

  test('the placeholder key is not a key', () {
    expect(settingsWith((s) => s.publicKey = CheckoutSettings.placeholderPublicKey).hasPublicKey, isFalse);
    expect(settingsWith((s) => s.publicKey = '  ').hasPublicKey, isFalse);
    expect(settingsWith((s) => s.publicKey = 'pk_test_x').hasPublicKey, isTrue);
  });

  test('test overrides merge and remove', () {
    final merged = TestHooks.merge(config(), {
      'language': 'ar',
      'cardOptions': {'showBrands': false},
      'hashString': null,
    });
    expect(merged['language'], 'ar');
    expect(map(merged, 'cardOptions')['showBrands'], false);
    expect(map(merged, 'cardOptions')['saveCardOption'], 'all', reason: 'other card options are kept');
    expect(merged.containsKey('hashString'), isFalse);
  });

  test('test hooks only apply while active', () {
    addTearDown(TestHooks.reset);
    TestHooks.publicKey = 'pk_test_hook';
    TestHooks.overrides = {'language': 'ar'};
    expect(TestHooks.apply(config())['language'], 'en');
    TestHooks.isActive = true;
    final applied = TestHooks.apply(config());
    expect(applied['language'], 'ar');
    expect(map(applied, 'gateway')['publicKey'], 'pk_test_hook');
  });

  group('persistence', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('settings survive save and load', () async {
      final settings = settingsWith((s) => s
        ..publicKey = 'pk_test_saved'
        ..mode = 'authorize'
        ..supportedCurrencies = ['SAR', 'KWD']
        ..discountValue = 2.5
        ..items = [OrderItem(name: 'Saved', quantity: 2, amount: 1.5)]);
      await settings.save();
      final loaded = await CheckoutSettings.load();
      expect(loaded.makeConfiguration(now: DateTime.utc(2026)), settings.makeConfiguration(now: DateTime.utc(2026)));
    });

    test('nothing saved, or something unreadable, gives the defaults', () async {
      expect((await CheckoutSettings.load()).makeConfiguration(now: DateTime.utc(2026)),
          CheckoutSettings().makeConfiguration(now: DateTime.utc(2026)));
      SharedPreferences.setMockInitialValues({'CheckoutSettings.v1': 'not json'});
      expect((await CheckoutSettings.load()).firstName, 'Ahmed');
    });

    test('fields missing from saved settings keep their defaults', () async {
      SharedPreferences.setMockInitialValues({'CheckoutSettings.v1': '{"firstName":"Sara","items":[]}'});
      final loaded = await CheckoutSettings.load();
      expect(loaded.firstName, 'Sara');
      expect(loaded.lastName, 'Sharkawy');
      expect(loaded.items.single.name, 'Item Title 1');
    });

    test('a saved placeholder key follows keys.dart', () async {
      await settingsWith((s) => s.publicKey = CheckoutSettings.placeholderPublicKey).save();
      expect((await CheckoutSettings.load()).publicKey, Keys.publicKey);
    });

    test('reset clears the saved settings', () async {
      await settingsWith((s) => s.firstName = 'Sara').save();
      await CheckoutSettings.reset();
      expect((await CheckoutSettings.load()).firstName, 'Ahmed');
    });
  });
}
