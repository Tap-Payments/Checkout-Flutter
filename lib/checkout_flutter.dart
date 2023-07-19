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
  static Map<String, dynamic> sessionParameters = {};

  /// App configurations
  static void startPayment({
    required SecretKeyModel secretKeyModel,
    required TapCustomerModel tapCustomer,
    required String bundleID,
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
    TapCurrencyCode currencyCode = TapCurrencyCode.USD,
    List<String>? supportedCurrencies,
    double amount = 1.0,
    String? applePayMerchantID,
    bool swipeDownToDismiss = false,
    PaymentType paymentType = PaymentType.All,
    CloseButtonStyle closeButtonStyle = CloseButtonStyle.Title,
    bool showDragHandler = false,
    TransactionModeType transactionMode = TransactionModeType.PURCHASE,
    String tapMerchantID = "",
    AllowedCardType allowedCardType = AllowedCardType.ALL,
    String postURL = "",
    String paymentDescription = "",
    String paymentStatementDescriptor = "",
    bool require3DSecure = true,
    bool allowsToSaveSameCardMoreThanOnce = true,
    bool enableSaveCard = true,
    bool isSaveCardSwitchOnByDefault = true,
    SDKMode sdkMode = SDKMode.Sandbox,
    bool collectCreditCardName = false,
    bool creditCardNameEditable = true,
    String creditCardNamePreload = "",
    ShowSaveCreditCard showSaveCreditCard = ShowSaveCreditCard.None,
    bool isSubscription = false,
    bool recurringPaymentRequest = false,
    ApplePayButtonType applePayButtonType = ApplePayButtonType.AppleLogoOnly,
    ApplePayButtonStyle applePayButtonStyle = ApplePayButtonStyle.Black,
    TapLoggingType tapLoggingType = TapLoggingType.CONSOLE,
  }) {
    sdkConfigurations = <String, dynamic>{
      "secretKey": secretKeyModel,
      "bundleID": bundleID,
      "localeIdentifier": locale,
      "flippingStatus":
          flippingStatus ?? FlippingStatus.FlipOnLoadWithFlippingBack,
      "displayColoredDark": displayColoredDark,
      "currency": currencyCode,
      "supportedCurrencies": supportedCurrencies ?? [],
      "amount": amount,
      "items": items ?? [],
      "applePayMerchantID": applePayMerchantID ?? "merchant.tap.gosell",
      "swipeDownToDismiss": swipeDownToDismiss,
      "paymentType": paymentType,
      "closeButtonStyle": closeButtonStyle,
      "showDragHandler": showDragHandler,
      "transactionMode": transactionMode,
      "customer": tapCustomer,
      "destinations": destinations ?? [],
      "tapMerchantID": tapMerchantID,
      "enableApiLogging": [tapLoggingType],
      "taxes": taxes ?? [],
      "shipping": shipping ??
          ShippingModel(
            currency: TapCurrencyCode.USD,
            amount: 1.0,
            name: "",
          ),
      "allowedCardTypes": [allowedCardType],
      "postURL": postURL,
      "paymentDescription": paymentDescription,
      "paymentMetadata": metadata,
      "paymentReference": reference ??
          ReferenceModel(
            acquirer: "",
            gatewayReference: "",
            gosellID: "",
            orderNumber: "",
            paymentReference: "",
            trackingNumber: "",
            transactionNumber: "",
          ),
      "paymentStatementDescriptor": paymentStatementDescriptor,
      "require3DSecure": require3DSecure,
      "receiptSettings": receipt ??
          ReceiptModel(
            email: true,
            sms: true,
            identifier: "",
          ),
      "authorizeAction": authorizeAction ??
          AuthorizeActionModel(
            type: AuthorizeActionType.Void,
            timeInHours: 168,
          ),
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
