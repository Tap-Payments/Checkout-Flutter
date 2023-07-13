/// We have two sdk mode
/// Sandbox is for Test environment
/// Production mode is for Live environment
enum SDKMode {
  Sandbox,
  Production,
}

/// Supported languages
/// en for English and ar for Arabic
enum LocaleIdentifier {
  ar,
  en,
}

/// Transaction modes types
/// We have 4 Types of transaction mode Purchase/Authorize_Capture/Save_Card/Tokenize_card
/// You can select any one of them
enum TransactionModeType {
  PURCHASE,
  AUTHORIZE_CAPTURE,
  SAVE_CARD,
  TOKENIZE_CARD,
}

/// There is two types of address
/// Residential and Commercial
enum AddressType {
  Residential,
  Commercial,
}

/// There is four different styles of apply pay button
/// You can choose from Black/White/WhiteOutline/Auto
/// Default style will be Auto
enum ApplePayButtonStyle {
  Black,
  White,
  WhiteOutline,
  Auto,
}

/// There is two types of amount modifications
/// You can use either percentage or fixed
enum AmountModificationModelType {
  Percentage,
  Fixed,
}

/// There is several types of apply pay button
/// You can choose any one of them and it will display according to selection
enum ApplePayButtonType {
  AppleLogoOnly,
  BuyWithApplePay,
  SetupApplePay,
  PayWithApplePay,
  DonateWithApplePay,
  CheckoutWithApplePay,
  BookWithApplePay,
  SubscribeWithApplePay,
}

/// There is two types of close button available
/// You can set and Icon or a Title
enum CloseButtonStyle {
  Icon,
  Title,
}

/// There is three flipping statues available
enum FlippingStatus {
  NoFlipping,
  FlipOnLoadWithFlippingBack,
  FlipOnLoadWithOutFlippingBack,
}

/// There is several payment types available
/// You can use any of them
/// By default it will be ALL
enum PaymentType {
  All,
  Web,
  Card,
  Telecom,
  ApplePay,
  Device,
  SavedCard,
}

/// There is few types of saved credit cards
/// You can select any one from them
enum ShowSaveCreditCard {
  None,
  Merchant,
  Tap,
  All,
}

enum AuthorizeActionType {
  Capture,
  Void,
}

enum TapLoggingType {
  UI,
  API,
  EVENTS,
  CONSOLE,
}

enum AllowedCardType {
  CREDIT,
  DEBIT,
  ALL,
}
