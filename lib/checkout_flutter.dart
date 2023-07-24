import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/models.dart';

class CheckoutFlutter {
  static final Map<dynamic, dynamic> _tapCheckoutSDKResult =
      <dynamic, dynamic>{};

  static const MethodChannel _channel = MethodChannel('checkout_flutter');

  static Future<dynamic> get startCheckoutSDK async {
    //  if (!_validateAppConfig()) return _tapCheckoutSDKResult;

    dynamic result = await _channel
        .invokeMethod('start', {"configuration": sdkConfigurations});
    if (kDebugMode) {
      print("Configuration =>$sdkConfigurations");
    }

    if (kDebugMode) {
      print("Result >>>>>> $result");
    }
    return result;
  }

  static Map<String, dynamic> sdkConfigurations = {};

  /// App configurations
  static void startPayment({
    required TapCustomerModel tapCustomer,
    required String bundleID,
    required String sandboxKey,
    required String productionKey,
    required Map<String, dynamic> metadata,
    List<ItemModel>? items,
    List<DestinationModel>? destinations,
    ReferenceModel? reference,
    ReceiptModel? receipt,
    AuthorizeActionModel? authorizeAction,
    List<TaxModel>? taxes,
    ShippingModel? shipping,
    String locale = "en",
    bool shouldFlipCardData = true,
    FlippingStatus? flippingStatus,
    bool displayColoredDark = false,
    TapCurrencyCode? currencyCode,
    List<String>? supportedCurrencies,
    double amount = 1.0,
    String? applePayMerchantID,
    bool swipeDownToDismiss = false,
    PaymentType? paymentType,
    CloseButtonStyle? closeButtonStyle,
    bool showDragHandler = false,
    TransactionModeType? transactionMode,
    String tapMerchantID = "",
    AllowedCardType? allowedCardType,
    String postURL = "",
    String paymentDescription = "",
    String paymentStatementDescriptor = "",
    bool require3DSecure = true,
    bool allowsToSaveSameCardMoreThanOnce = true,
    bool enableSaveCard = true,
    bool isSaveCardSwitchOnByDefault = true,
    SDKMode? sdkMode,
    bool collectCreditCardName = false,
    bool creditCardNameEditable = true,
    String creditCardNamePreload = "",
    ShowSaveCreditCard? showSaveCreditCard,
    bool isSubscription = false,
    bool recurringPaymentRequest = false,
    ApplePayButtonType? applePayButtonType,
    ApplePayButtonStyle? applePayButtonStyle,
    TapLoggingType? tapLoggingType,
  }) {
    sdkConfigurations = <String, dynamic>{
      "sandbox": sandboxKey,
      "production": productionKey,
      "bundleID": bundleID,
      "localeIdentifier": locale,
      "flippingStatus":
          flippingStatus ?? FlippingStatus.FlipOnLoadWithFlippingBack.name,
      "displayColoredDark": displayColoredDark,
      "currency": currencyCode ?? TapCurrencyCode.KWD.name,
      "supportedCurrencies": supportedCurrencies ?? [],
      "amount": amount,
      "items": items ?? [],
      "applePayMerchantID": applePayMerchantID ?? "merchant.tap.gosell",
      "swipeDownToDismiss": swipeDownToDismiss,
      "paymentType": paymentType ?? PaymentType.All.name.toString(),
      "closeButtonStyle":
          closeButtonStyle ?? CloseButtonStyle.Title.name.toString(),
      "showDragHandler": showDragHandler,
      "transactionMode":
          transactionMode ?? TransactionModeType.PURCHASE.name.toString(),
      "customer": jsonEncode(tapCustomer),
      "destinations": destinations == null ? [] : jsonEncode(destinations),
      "tapMerchantID": tapMerchantID,
      "enableApiLogging":
          tapLoggingType ?? [TapLoggingType.CONSOLE.name.toString()],
      "taxes": taxes == null ? [] : jsonEncode(taxes),
      "shipping": shipping == null ? null : jsonEncode(shipping),
      "allowedCardTypes":
          allowedCardType ?? [AllowedCardType.ALL.name.toString()],
      "postURL": postURL,
      "paymentDescription": paymentDescription,
      "paymentMetadata": metadata,
      "paymentReference": reference == null ? null : jsonEncode(reference),
      "paymentStatementDescriptor": paymentStatementDescriptor,
      "require3DSecure": require3DSecure,
      "receiptSettings": receipt == null ? null : jsonEncode(receipt),
      "authorizeAction":
          authorizeAction == null ? null : jsonEncode(authorizeAction),
      "allowsToSaveSameCardMoreThanOnce": allowsToSaveSameCardMoreThanOnce,
      "enableSaveCard": enableSaveCard,
      "isSaveCardSwitchOnByDefault": isSaveCardSwitchOnByDefault,
      "sdkMode": sdkMode ?? SDKMode.Sandbox.name.toString(),
      "collectCreditCardName": collectCreditCardName,
      "creditCardNameEditable": creditCardNameEditable,
      "creditCardNamePreload": creditCardNamePreload,
      "showSaveCreditCard":
          showSaveCreditCard ?? ShowSaveCreditCard.None.name.toString(),
      "isSubscription": isSubscription,
      "recurringPaymentRequest": recurringPaymentRequest,
      "applePayButtonType": applePayButtonType ??
          ApplePayButtonType.AppleLogoOnly.name.toString(),
      "applePayButtonStyle":
          applePayButtonStyle ?? ApplePayButtonStyle.Black.name.toString(),
      "shouldFlipCardData": shouldFlipCardData,
    };
  }
}
