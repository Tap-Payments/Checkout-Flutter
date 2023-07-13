import 'package:checkout_flutter/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CheckoutFlutter {
  static final Map<dynamic, dynamic> _tapCheckoutSDKResult =
      <dynamic, dynamic>{};

  static const MethodChannel _channel = MethodChannel('checkout_flutter');

  static Future<dynamic> get startCheckoutSDK async {
    //  if (!_validateAppConfig()) return _tapCheckoutSDKResult;
    dynamic result = await _channel.invokeMethod('start', sdkConfigurations);
    if (kDebugMode) {
      print("Result >>>>>> $result");
    }
    return result;
  }

  static Map<String, dynamic> sdkConfigurations = {};

  /// App configurations
  static void configureSDK({
    required SecretKeyModel secretKey,
    required String bundleID,
    required String locale,
    required bool flippingStatus,
    required bool displayColoredDark,
    required TapCurrencyCode currencyCode,
    List<String>? supportedCurrencies,
    required List<ItemModel> items,
    required double amount,
    required String applePayMerchantID,
    required bool swipeDownToDismiss,
    required PaymentType paymentType,
    required CloseButtonStyle closeButtonStyle,
    required bool showDragHandler,
    required TransactionModeType transactionMode,
    required TapCustomerModel tapCustomer,
    List<DestinationModel>? destinations,
    String? tapMerchantID,
    List<TaxModel>? taxes,
    ShippingModel? shipping,
    required AllowedCardType allowedCardType,
    String? postURL,
    String? paymentDescription,
    required Map<String, dynamic> metadata,
    ReferenceModel? reference,
    String? paymentStatementDescriptor,
    required String require3DSecure,
    ReceiptModel? receipt,
    required AuthorizeActionModel authorizeAction,
    required bool allowsToSaveSameCardMoreThanOnce,
    required bool enableSaveCard,
    required bool isSaveCardSwitchOnByDefault,
    required SDKMode sdkMode,
    required bool collectCreditCardName,
    required bool creditCardNameEditable,
    required String creditCardNamePreload,
    required ShowSaveCreditCard showSaveCreditCard,
    required bool isSubscription,
    required bool recurringPaymentRequest,
    required ApplePayButtonType applePayButtonType,
    required ApplePayButtonStyle applePayButtonStyle,
    required bool shouldFlipCardData,
  }) {
    sdkConfigurations = <String, dynamic>{
      "secretKey": secretKey,
      "bundleID": bundleID,
      "localeIdentifier": locale,
      "flippingStatus": flippingStatus,
      "displayColoredDark": displayColoredDark,
      "currency": currencyCode,
      "supportedCurrencies": supportedCurrencies,
      "amount": amount,
      "items": items,
      "applePayMerchantID": applePayMerchantID,
      "swipeDownToDismiss": swipeDownToDismiss,
      "paymentType": paymentType,
      "closeButtonStyle": closeButtonStyle,
      "showDragHandler": showDragHandler,
      "transactionMode": transactionMode,
      "customer": tapCustomer,
      "destinations": destinations,
      "tapMerchantID": tapMerchantID,
      "taxes": taxes,
      "shipping": shipping,
      "allowedCardTypes": [allowedCardType],
      "postURL": postURL,
      "paymentDescription": paymentDescription,
      "paymentMetadata": metadata,
      "paymentReference": reference,
      "paymentStatementDescriptor": paymentStatementDescriptor,
      "require3DSecure": require3DSecure,
      "receiptSettings": receipt,
      "authorizeAction": authorizeAction,
      "allowsToSaveSameCardMoreThanOnce": allowsToSaveSameCardMoreThanOnce,
      "enableSaveCard": enableSaveCard,
      "isSaveCardSwitchOnByDefault": isSaveCardSwitchOnByDefault,
      "sdkMode": sdkMode,
      "collectCreditCardName": collectCreditCardName,
      "creditCardNameEditable": creditCardNameEditable,
      "creditCardNamePreload": creditCardNamePreload,
      "showSaveCreditCard": showSaveCreditCard,
      "isSubscription": isSubscription,
      "recurringPaymentRequest": recurringPaymentRequest,
      "applePayButtonType": applePayButtonType,
      "applePayButtonStyle": applePayButtonStyle,
      "shouldFlipCardData": shouldFlipCardData,
    };
  }
}
