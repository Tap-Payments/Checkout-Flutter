// Every input of the Tap web demo (https://demo.tap.company/v2/sdk/checkout), stored with
// shared_preferences (the web demo keeps the same state in localStorage), plus the mapping that
// turns them into the configuration map passed to `startCheckout(configurations:)`.
// The mapping mirrors what the web demo sends to the web SDK, so both behave the same.
// Same fields and defaults as CheckoutSettings.swift (iOS) and CheckoutSettings.kt (Android).

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'keys.dart';

class OrderItem {
  OrderItem({
    this.name = 'Item Title 1',
    this.description = 'item description 1',
    this.quantity = 1,
    this.amount = 0.1,
  });

  String name;
  String description;
  int quantity;
  double amount;

  Map<String, dynamic> toJson() =>
      {'name': name, 'description': description, 'quantity': quantity, 'amount': amount};

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final item = OrderItem();
    _read<String>(json, 'name', (v) => item.name = v);
    _read<String>(json, 'description', (v) => item.description = v);
    _read<num>(json, 'quantity', (v) => item.quantity = v.toInt());
    _read<num>(json, 'amount', (v) => item.amount = v.toDouble());
    return item;
  }
}

class CheckoutSettings {
  CheckoutSettings();

  // SDK configuration

  String publicKey = Keys.publicKey;
  String merchantId = Keys.merchantId;

  /// Any of ALL, AUTO, KWD, BHD, SAR, AED, OMR, EGP, GBP, USD, EUR.
  List<String> supportedCurrencies = ['ALL'];

  /// ALL, WEB, CARD or DEVICE.
  String paymentType = 'ALL';
  List<String> supportedPaymentMethods = ['ALL'];
  String selectedCurrency = 'SAR';

  /// auto, en, ar or dynamic (Android: device language). "auto" lets the checkout decide, so the key is not sent.
  String language = 'en';
  List<String> supportedRegions = [];
  List<String> supportedCountries = [];
  List<String> supportedPaymentTypes = [];
  List<String> supportedSchemes = [];
  bool isApplePayAvailableOnClient = true;

  // User configuration

  String customerId = '';
  String firstName = 'Ahmed';
  String lastName = 'Sharkawy';
  String email = 'example@gmail.com';
  String countryCode = '20';
  String phoneNumber = '1099137773';

  // Card configuration

  bool showBrands = true;
  bool showLoadingState = false;
  bool collectHolderName = true;
  String preLoadCardName = '';
  bool cardNameEditable = true;

  /// all, credit or debit.
  String cardFundingSource = 'all';

  /// all, merchant, tap or none.
  String saveCardOption = 'all';
  bool forceLtr = false;

  /// Not in the web demo: shows the native card scanner button (iOS needs NSCameraUsageDescription).
  bool cardScanner = false;

  /// Android only, not in the web demo: shows the NFC card reader button.
  bool cardNFC = false;

  // Order configuration

  String orderId = '';

  /// "F" = fixed amount, "P" = percentage of the items total.
  String discountType = 'F';
  double discountValue = 0;
  List<OrderItem> items = [OrderItem()];

  // Transaction configuration

  /// "charge" or "authorize".
  String mode = 'charge';

  /// light, dark, light_mono, dark_colored, dynamic (Android: device mode) or auto ("auto" = key not sent).
  String theme = 'light';

  /// popup or page.
  String checkoutMode = 'popup';
  bool threeDSecure = true;
  bool saveCard = true;

  /// `transaction.<mode>.redirect.url`; the web demo returns to its own page.
  String redirectUrl = redirectURL;
  String hashString = '';

  /// CAPTURE or VOID: what happens automatically to an authorization. Only editable in authorize mode.
  String authorizeType = 'VOID';

  /// Hours before [authorizeType] is applied.
  int authorizeTime = 100;
  bool agreedPayment = false;

  /// SCHEDULED or UNSCHEDULED.
  String agreementType = 'SCHEDULED';

  /// FIXED or VARIABLE.
  String amountVariability = 'FIXED';

  /// "Defined" (use [paymentCount]) or "Undefined" (txn_count 0).
  String numberOfPayments = 'Undefined';
  int paymentCount = 1;
  String subscriptionName = 'Recurring';
  String subscriptionDescription =
      'A description of the recurring payment to display to the user in the payment sheet.';
  String billingAgreement =
      'A localized billing agreement displayed to the user in the payment sheet prior to the payment authorization.';

  /// "", "yes" or "no". The web demo starts with the airline choice unset and then still sends
  /// `airline` with an empty booking reference; only an explicit "no" removes it.
  String airline = '';
  String bookingReference = '';

  // Derived values

  static const placeholderPublicKey = 'YOUR_TAP_PUBLIC_KEY';

  /// The page the web demo returns to after a redirect. The native SDKs ignore it, but the
  /// checkout config still expects `transaction.<mode>.redirect.url`.
  static const redirectURL = 'https://demo.tap.company/v2/sdk/checkout';

  bool get hasPublicKey {
    final key = publicKey.trim();
    return key.isNotEmpty && key != placeholderPublicKey;
  }

  /// Sum of `amount * quantity` over all items.
  double get itemsTotal => items.fold(0, (sum, item) => sum + item.amount * item.quantity);

  /// Amount charged: items total minus the discount, or 1 when that is zero or negative (as the web demo does).
  double get totalAmount {
    final discount = discountType == 'P' ? itemsTotal * (discountValue / 100) : discountValue;
    final total = itemsTotal - discount;
    return total <= 0 ? 1 : total;
  }

  // Configuration map

  /// Builds the map for `startCheckout(configurations:)`, following the web demo's mapping.
  Map<String, dynamic> makeConfiguration({DateTime? now}) {
    final config = <String, dynamic>{
      'open': true,
      'hashString': hashString,
      'checkoutMode': checkoutMode,
      'paymentType': paymentType,
      'supportedPaymentMethods':
          supportedPaymentMethods.contains('ALL') ? 'ALL' : [...supportedPaymentMethods],
      'selectedCurrency': selectedCurrency,
      'supportedCurrencies': _collapsedCurrencies,
      'gateway': _gateway,
      'customer': _customer,
      'transaction': {'mode': mode, mode: _transaction(now ?? DateTime.now())},
      'amount': jsonNumber(totalAmount),
      'order': _order,
      'cardOptions': _cardOptions,
      'isApplePayAvailableOnClient': isApplePayAvailableOnClient,
    };

    // "auto" means "let the checkout decide": the key is not sent at all.
    if (language != 'auto') config['language'] = language;
    if (theme != 'auto') config['themeMode'] = theme;

    // Empty filters are not sent.
    if (supportedRegions.isNotEmpty) config['supportedRegions'] = [...supportedRegions];
    if (supportedCountries.isNotEmpty) config['supportedCountries'] = [...supportedCountries];
    if (supportedPaymentTypes.isNotEmpty) config['supportedPaymentTypes'] = [...supportedPaymentTypes];
    if (supportedSchemes.isNotEmpty) config['supportedSchemes'] = [...supportedSchemes];
    return config;
  }

  /// ALL wins over AUTO, which wins over an explicit list.
  Object get _collapsedCurrencies {
    if (supportedCurrencies.contains('ALL')) return 'ALL';
    if (supportedCurrencies.contains('AUTO')) return 'AUTO';
    return [...supportedCurrencies];
  }

  Map<String, dynamic> get _gateway => {
        'publicKey': publicKey,
        if (merchantId.isNotEmpty) 'merchantId': merchantId,
      };

  Map<String, dynamic> get _customer => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': {'countryCode': countryCode, 'number': phoneNumber},
        if (customerId.isNotEmpty) 'id': customerId,
      };

  Map<String, dynamic> get _cardOptions {
    // Sent only when switched on, like the native examples.
    final inputs = {
      if (cardScanner) 'cardScanner': true,
      if (cardNFC) 'cardNFC': true,
    };
    return {
      'showBrands': showBrands,
      'showLoadingState': showLoadingState,
      'collectHolderName': collectHolderName,
      'preLoadCardName': preLoadCardName,
      'cardNameEditable': cardNameEditable,
      'cardFundingSource': cardFundingSource,
      'saveCardOption': saveCardOption,
      'forceLtr': forceLtr,
      if (inputs.isNotEmpty) 'alternativeCardInputs': inputs,
    };
  }

  Map<String, dynamic> get _order => {
        'id': orderId,
        'currency': selectedCurrency,
        'amount': jsonNumber(totalAmount),
        'items': [
          for (final item in items)
            {
              'amount': jsonNumber(item.amount),
              'currency': selectedCurrency,
              'name': item.name,
              'quantity': item.quantity,
              'description': item.description,
            },
        ],
        if (discountValue > 0) 'discount': {'type': discountType, 'value': jsonNumber(discountValue)},
      };

  /// The `transaction.<mode>` object. Charge and authorize send the very same keys; only the
  /// name of this object (and `transaction.mode`) differs.
  Map<String, dynamic> _transaction(DateTime now) {
    final transaction = <String, dynamic>{
      'saveCard': saveCard,
      // Sent in both modes. `type` and `time` only matter (and are only editable) for authorizations.
      'auto': {'type': authorizeType, 'time': authorizeTime},
      'redirect': {'url': redirectUrl},
      'threeDSecure': threeDSecure,
    };

    if (agreedPayment) {
      transaction['agreement'] = agreementType == 'UNSCHEDULED'
          ? {'type': 'UNSCHEDULED'}
          : {'type': agreementType, 'amount_variability': amountVariability};
      transaction['applePayRecurringPaymentRequest'] = _applePayRecurringPaymentRequest(now);
    }

    // Like the web demo, `subscription` does not depend on "Agreed payment": it is sent
    // whenever the agreement type is not UNSCHEDULED (which is the default).
    if (agreementType != 'UNSCHEDULED') {
      transaction['subscription'] = {
        'type': agreementType,
        'amount_variability': amountVariability,
        'txn_count': numberOfPayments == 'Defined' ? paymentCount : 0,
      };
    }

    // Also like the web demo: sent unless the airline choice is explicitly "no".
    if (airline != 'no') {
      transaction['airline'] = {
        'reference': {'booking': bookingReference},
      };
    }
    return transaction;
  }

  Map<String, dynamic> _applePayRecurringPaymentRequest(DateTime now) => {
        'paymentDescription': subscriptionDescription,
        'regularBilling': {
          'label': subscriptionName,
          'paymentTiming': 'recurring',
          'recurringPaymentStartDate': isoTimestamp(now),
        },
        'billingAgreement': billingAgreement,
        // The web demo uses the page origin for both URLs.
        'managementURL': 'https://demo.tap.company',
        'tokenNotificationURL': 'https://demo.tap.company',
      };

  /// 0.1 + 0.2 is 0.30000000000000004 as a double. Rounding to 3 decimals (the most any currency
  /// uses) sends 0.3, like the web demo.
  static double jsonNumber(double value) => double.parse(value.toStringAsFixed(3));

  /// `2026-10-27T10:30:00.000Z`: UTC with milliseconds, like the web demo's `toISOString()`.
  static String isoTimestamp(DateTime time) {
    final utc = time.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-${two(utc.day)}'
        'T${two(utc.hour)}:${two(utc.minute)}:${two(utc.second)}.${utc.millisecond.toString().padLeft(3, '0')}Z';
  }

  // Persistence

  static const _storageKey = 'CheckoutSettings.v1';

  /// Loads the saved settings, or the web demo defaults when nothing valid is saved.
  static Future<CheckoutSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_storageKey);
    if (saved == null) return CheckoutSettings();
    try {
      final settings = CheckoutSettings.fromJson(jsonDecode(saved) as Map<String, dynamic>);
      // A key saved while keys.dart still held the placeholder follows keys.dart once it is filled in.
      if (settings.publicKey == placeholderPublicKey) settings.publicKey = Keys.publicKey;
      return settings;
    } catch (_) {
      return CheckoutSettings();
    }
  }

  Future<void> save() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(toJson()));
  }

  static Future<void> reset() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }

  Map<String, dynamic> toJson() => {
        'publicKey': publicKey,
        'merchantId': merchantId,
        'supportedCurrencies': supportedCurrencies,
        'paymentType': paymentType,
        'supportedPaymentMethods': supportedPaymentMethods,
        'selectedCurrency': selectedCurrency,
        'language': language,
        'supportedRegions': supportedRegions,
        'supportedCountries': supportedCountries,
        'supportedPaymentTypes': supportedPaymentTypes,
        'supportedSchemes': supportedSchemes,
        'isApplePayAvailableOnClient': isApplePayAvailableOnClient,
        'customerId': customerId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'countryCode': countryCode,
        'phoneNumber': phoneNumber,
        'showBrands': showBrands,
        'showLoadingState': showLoadingState,
        'collectHolderName': collectHolderName,
        'preLoadCardName': preLoadCardName,
        'cardNameEditable': cardNameEditable,
        'cardFundingSource': cardFundingSource,
        'saveCardOption': saveCardOption,
        'forceLtr': forceLtr,
        'cardScanner': cardScanner,
        'cardNFC': cardNFC,
        'orderId': orderId,
        'discountType': discountType,
        'discountValue': discountValue,
        'items': [for (final item in items) item.toJson()],
        'mode': mode,
        'theme': theme,
        'checkoutMode': checkoutMode,
        'threeDSecure': threeDSecure,
        'saveCard': saveCard,
        'redirectUrl': redirectUrl,
        'hashString': hashString,
        'authorizeType': authorizeType,
        'authorizeTime': authorizeTime,
        'agreedPayment': agreedPayment,
        'agreementType': agreementType,
        'amountVariability': amountVariability,
        'numberOfPayments': numberOfPayments,
        'paymentCount': paymentCount,
        'subscriptionName': subscriptionName,
        'subscriptionDescription': subscriptionDescription,
        'billingAgreement': billingAgreement,
        'airline': airline,
        'bookingReference': bookingReference,
      };

  /// Every field keeps its default when it is missing (or of the wrong type) in [json].
  factory CheckoutSettings.fromJson(Map<String, dynamic> json) {
    final s = CheckoutSettings();
    List<String> strings(Object v) => (v as List).whereType<String>().toList();
    _read<String>(json, 'publicKey', (v) => s.publicKey = v);
    _read<String>(json, 'merchantId', (v) => s.merchantId = v);
    _read<List>(json, 'supportedCurrencies', (v) => s.supportedCurrencies = strings(v));
    _read<String>(json, 'paymentType', (v) => s.paymentType = v);
    _read<List>(json, 'supportedPaymentMethods', (v) => s.supportedPaymentMethods = strings(v));
    _read<String>(json, 'selectedCurrency', (v) => s.selectedCurrency = v);
    _read<String>(json, 'language', (v) => s.language = v);
    _read<List>(json, 'supportedRegions', (v) => s.supportedRegions = strings(v));
    _read<List>(json, 'supportedCountries', (v) => s.supportedCountries = strings(v));
    _read<List>(json, 'supportedPaymentTypes', (v) => s.supportedPaymentTypes = strings(v));
    _read<List>(json, 'supportedSchemes', (v) => s.supportedSchemes = strings(v));
    _read<bool>(json, 'isApplePayAvailableOnClient', (v) => s.isApplePayAvailableOnClient = v);
    _read<String>(json, 'customerId', (v) => s.customerId = v);
    _read<String>(json, 'firstName', (v) => s.firstName = v);
    _read<String>(json, 'lastName', (v) => s.lastName = v);
    _read<String>(json, 'email', (v) => s.email = v);
    _read<String>(json, 'countryCode', (v) => s.countryCode = v);
    _read<String>(json, 'phoneNumber', (v) => s.phoneNumber = v);
    _read<bool>(json, 'showBrands', (v) => s.showBrands = v);
    _read<bool>(json, 'showLoadingState', (v) => s.showLoadingState = v);
    _read<bool>(json, 'collectHolderName', (v) => s.collectHolderName = v);
    _read<String>(json, 'preLoadCardName', (v) => s.preLoadCardName = v);
    _read<bool>(json, 'cardNameEditable', (v) => s.cardNameEditable = v);
    _read<String>(json, 'cardFundingSource', (v) => s.cardFundingSource = v);
    _read<String>(json, 'saveCardOption', (v) => s.saveCardOption = v);
    _read<bool>(json, 'forceLtr', (v) => s.forceLtr = v);
    _read<bool>(json, 'cardScanner', (v) => s.cardScanner = v);
    _read<bool>(json, 'cardNFC', (v) => s.cardNFC = v);
    _read<String>(json, 'orderId', (v) => s.orderId = v);
    _read<String>(json, 'discountType', (v) => s.discountType = v);
    _read<num>(json, 'discountValue', (v) => s.discountValue = v.toDouble());
    _read<List>(json, 'items', (v) {
      final items = v.whereType<Map<String, dynamic>>().map(OrderItem.fromJson).toList();
      if (items.isNotEmpty) s.items = items;
    });
    _read<String>(json, 'mode', (v) => s.mode = v);
    _read<String>(json, 'theme', (v) => s.theme = v);
    _read<String>(json, 'checkoutMode', (v) => s.checkoutMode = v);
    _read<bool>(json, 'threeDSecure', (v) => s.threeDSecure = v);
    _read<bool>(json, 'saveCard', (v) => s.saveCard = v);
    _read<String>(json, 'redirectUrl', (v) => s.redirectUrl = v);
    _read<String>(json, 'hashString', (v) => s.hashString = v);
    _read<String>(json, 'authorizeType', (v) => s.authorizeType = v);
    _read<num>(json, 'authorizeTime', (v) => s.authorizeTime = v.toInt());
    _read<bool>(json, 'agreedPayment', (v) => s.agreedPayment = v);
    _read<String>(json, 'agreementType', (v) => s.agreementType = v);
    _read<String>(json, 'amountVariability', (v) => s.amountVariability = v);
    _read<String>(json, 'numberOfPayments', (v) => s.numberOfPayments = v);
    _read<num>(json, 'paymentCount', (v) => s.paymentCount = v.toInt());
    _read<String>(json, 'subscriptionName', (v) => s.subscriptionName = v);
    _read<String>(json, 'subscriptionDescription', (v) => s.subscriptionDescription = v);
    _read<String>(json, 'billingAgreement', (v) => s.billingAgreement = v);
    _read<String>(json, 'airline', (v) => s.airline = v);
    _read<String>(json, 'bookingReference', (v) => s.bookingReference = v);
    return s;
  }
}

void _read<T>(Map<String, dynamic> json, String key, void Function(T value) set) {
  final value = json[key];
  if (value is T) set(value);
}
