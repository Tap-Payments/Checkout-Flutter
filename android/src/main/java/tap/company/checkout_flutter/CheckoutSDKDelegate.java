package tap.company.checkout_flutter;


import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import company.tap.checkout.TapCheckOutSDK;
import company.tap.checkout.internal.api.models.Authorize;
import company.tap.checkout.internal.api.models.Charge;
import company.tap.checkout.internal.api.models.Token;
import company.tap.checkout.open.controller.SDKSession;
import company.tap.checkout.open.enums.CardType;
import company.tap.checkout.open.enums.SdkMode;
import company.tap.checkout.open.exceptions.CurrencyException;
import company.tap.checkout.open.interfaces.CheckOutDelegate;
import company.tap.checkout.open.models.AuthorizeAction;
import company.tap.checkout.open.models.CardsList;
import company.tap.checkout.open.models.Destinations;
import company.tap.checkout.open.models.OrderObject;
import company.tap.checkout.open.models.TapCurrency;
import company.tap.checkout.open.models.TapCustomer;
import company.tap.tapnetworkkit.exception.GoSellError;
import company.tap.tapuilibraryy.themekit.ThemeManager;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import tap.company.checkout_flutter.deserializers.DeserializationUtil;

public class CheckoutSDKDelegate extends FragmentManager implements PluginRegistry.ActivityResultListener,
        PluginRegistry.RequestPermissionsResultListener, CheckOutDelegate {

    private SDKSession sdkSession;
    private Activity activity;
    private MethodChannel.Result pendingResult;
    private MethodCall methodCall;

    public CheckoutSDKDelegate(Activity _activity) {
        this.activity = _activity;

    }


    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        return false;
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        return false;
    }

    public void startSDK(MethodCall methodCall, MethodChannel.Result result,
                         HashMap<String, Object> sdkConfigurations) {

        if (!setPendingMethodCallAndResult(methodCall, result)) {
            finishWithAlreadyActiveError(result);
            return;
        }

       // ThemeManager.loadTapTheme(this.activity.getResources(), R.raw.defaultlighttheme, "lighttheme");

        showSDK(sdkConfigurations, result);
    }

    public void terminateSDKSession() {
        if (activity != null) {
            //  sdkSession.cancelSession(activity);
        }
    }

    private void showSDK(HashMap<String, Object> sdkConfigurations, MethodChannel.Result result) {
        HashMap<String, Object> sdkConfiguration = (HashMap<String, Object>) sdkConfigurations
                .get("configuration");
        System.out.println("SDK CONFIGURATION >>>>>>>" + sdkConfiguration);
        String sandboxKey = (String) sdkConfiguration.get("sandbox");

        String productionKey = (String) sdkConfiguration.get("production");
        String locale = (String) sdkConfiguration.get("localeIdentifier");
        String bundleID = (String) sdkConfiguration.get("bundleID");
        System.out.println("SECRET KEY >>>>>>>" + sandboxKey);
        System.out.println("PRODUCTION KEY >>>>>>>" + productionKey);
        System.out.println("LOCALE >>>>>>>" + locale);
        System.out.println("BUNDLE ID >>>>>>>" + bundleID);

        configureApp(sandboxKey, productionKey, bundleID, locale);

        // configureSDKThemeObject();

        /**
         * Required step. Configure SDK Session with all required data.
         */
        System.out.println("SDK SESSION CONFIGURATION");
        configureSDKSession(sdkConfiguration, result);

        sdkSession.startSDK(this, activity, activity);
    }

    private void configureSDKSession(HashMap<String, Object> sessionParameters, MethodChannel.Result result) {

        System.out.println("Complete Configuration" + sessionParameters);
        if (sdkSession == null) {
            sdkSession = SDKSession.INSTANCE;
        }
        //sdkSession = SDKSession.INSTANCE;
        sdkSession.addSessionDelegate(this);
        System.out.println("addSessionDelegate");

        sdkSession.instantiatePaymentDataSource();
        System.out.println("instantiatePaymentDataSource");

        sdkSession.setCustomer(Objects.requireNonNull(DeserializationUtil.getCustomer(sessionParameters)));
        System.out.println("setCustomer");
        sdkSession.setTransactionMode(DeserializationUtil.getTransactionMode((String) sessionParameters.get("transactionMode")));
        System.out.println("setTransactionMode");
        BigDecimal amount;
        try {
            amount = new BigDecimal(Double.toString((Double) sessionParameters.get("amount")));
        } catch (Exception e) {
//            Log.d("CheckoutSDKDelegate : ", "Invalid amount can't be parsed to double : "
//                    + (String) Objects.requireNonNull(sessionParameters.get("amount")));
            amount = BigDecimal.ZERO;
        }
        sdkSession.setAmount(amount);
        System.out.println("setAmount");

        sdkSession.setCardType(CardType.ALL);  // sdkSession.setCardType(DeserializationUtil.getCardType((String) sessionParameters.get("allowedCardTypes")));
        System.out.println("setCardType");
        sdkSession.setAuthorizeAction(null); // sdkSession.setAuthorizeAction(DeserializationUtil.getAuthorizeAction(sessionParameters.get("authorizeAction")));
        System.out.println("setAuthorizeAction");

        sdkSession.setReceiptSettings(null); // sdkSession.setReceiptSettings(DeserializationUtil.getReceipt(sessionParameters.get("receiptSettings")));
        System.out.println("setReceiptSettings");
        sdkSession.setDestination(null);
        System.out.println("setDestination");
        //   sdkSession.setDestination(DeserializationUtil.getDestinations(Objects.requireNonNull(sessionParameters.get("destinations")))); // Issue here
        sdkSession.setShipping(null);
        System.out.println("setShipping");
        sdkSession.setPaymentItems(null);
        System.out.println("setPaymentItems");
        //     sdkSession.setShipping(DeserializationUtil.getShipping(sessionParameters.get("shipping"))); Issue here
        //     sdkSession.setPaymentItems(DeserializationUtil.getPaymentItems(sessionParameters.get("items")));// ** Issue here


        // Set Taxes array list : TODO will update later
        sdkSession.setTaxes(null); // sdkSession.setTaxes(DeserializationUtil.getTaxes(sessionParameters.get("taxes")));// ** Optional ** you can pass
        System.out.println("setTaxes");
        // empty array list


        // Post URL
        sdkSession.setPostURL(sessionParameters.get("postURL").toString());// ** Optional **
        System.out.println("setPostURL");
        // Payment Description
        sdkSession.setPaymentDescription(sessionParameters.get("paymentDescription").toString()); // ** Optional **
        System.out.println("setPaymentDescription");
        // Payment Extra Info

        HashMap<String, String> hashMap = new HashMap<>();
        hashMap.put("name","azhar");
        sdkSession.setPaymentMetadata(hashMap);// **
        System.out.println("setPaymentMetadata");
        // Payment Reference
        sdkSession.setPaymentReference(null); // sdkSession.setPaymentReference(DeserializationUtil.getReference(sessionParameters.get("paymentReference"))); // **
        System.out.println("setPaymentReference");
        // Payment Statement Descriptor
        sdkSession.setPaymentStatementDescriptor(sessionParameters.get("paymentStatementDescriptor").toString()); // **
        System.out.println("setPaymentStatementDescriptor");
        // Optional
        // **

        // Enable or Disable Saving Card
        sdkSession.isUserAllowedToSaveCard(true); // sdkSession.isUserAllowedToSaveCard((boolean) sessionParameters.get("isUserAllowedToSaveCard")); // ** Required
        System.out.println("isUserAllowedToSaveCard");
        // ** you can
        // pass boolean

        // Enable or Disable 3DSecure
        sdkSession.isRequires3DSecure(true); // sdkSession.isRequires3DSecure((boolean) sessionParameters.get("isRequires3DSecure"));
        System.out.println("isRequires3DSecure");

        // Set Authorize Action
        sdkSession.setAuthorizeAction(null); // sdkSession.setAuthorizeAction(DeserializationUtil.getAuthorizeAction(sessionParameters.get("authorizeAction"))); // **
        System.out.println("setAuthorizeAction");

        sdkSession.setMerchantID(null); // sdkSession.setMerchantID(Objects.requireNonNull(sessionParameters.get("merchantID")).toString()); // ** Optional ** you can pass
        System.out.println("setMerchantID");
        // merchant id or null

        sdkSession.setCardType(CardType.ALL); // sdkSession.setCardType(DeserializationUtil.getCardType(sessionParameters.get("allowedCadTypes").toString())); // **
        System.out.println("setCardType");

        sdkSession.setPaymentType("ALL"); // sdkSession.setPaymentType(DeserializationUtil.getPaymentType((String) sessionParameters.get("paymentType")));
        System.out.println("setPaymentType");
        sdkSession.setSdkMode(SdkMode.SAND_BOX);  //sdkSession.setSdkMode(DeserializationUtil.getSDKMode((String) sessionParameters.get("sdkMode")));
        System.out.println("setSdkMode");
        sdkSession.setDefaultCardHolderName(null);//   sdkSession.setDefaultCardHolderName(Objects.requireNonNull(sessionParameters.get("cardHolderName")).toString()); // ** Optional ** you
        System.out.println("setDefaultCardHolderName");
        sdkSession.isUserAllowedToEnableCardHolderName(false); //   sdkSession.isUserAllowedToEnableCardHolderName((boolean) sessionParameters.get("editCardHolderName"));
        System.out.println("isUserAllowedToEnableCardHolderName");
        // set transaction currency associated to your account
//        TapCurrency transactionCurrency;
//        try {
//            transactionCurrency = new TapCurrency(
//                    (String) Objects.requireNonNull(sessionParameters.get("currency")));
//        } catch (CurrencyException c) {
//            Log.d("CheckoutSDKDelegate : ", "Unknown currency exception thrown : "
//                    + (String) Objects.requireNonNull(sessionParameters.get("currency")));
//            transactionCurrency = new TapCurrency("KWD");
//        } catch (Exception e) {
//            Log.d("CheckoutSDKDelegate : ", "Unknown currency: "
//                    + (String) Objects.requireNonNull(sessionParameters.get("currency")));
//            transactionCurrency = new TapCurrency("KWD");
//        }
        sdkSession.setTransactionCurrency(new TapCurrency("KWD")); // ** Required **
        System.out.println("setTransactionCurrency");
        sdkSession.setOrderObject(new OrderObject(BigDecimal.ONE, "KWD",new TapCustomer("cus_TS012520211349Za012907577","Muhammad","Azhar","Maqbool","a.maqbool@tap.company",null,null,"+92",null,"en"), null, null, null, null, null, null));

        sdkSession.startPayment(this);
        System.out.println("Start payment");

    }


    private void finishWithAlreadyActiveError(MethodChannel.Result result) {
        result.error("already_active", "SDK is already active", null);
    }

    private boolean setPendingMethodCallAndResult(MethodCall methodCall, MethodChannel.Result result) {
        if (pendingResult != null) {
            return false;
        }

        this.methodCall = methodCall;
        pendingResult = result;

        return true;
    }

    private void configureApp(String secrete_key, String production_key, String bundleID, String language) {
        TapCheckOutSDK.INSTANCE.init(this.activity, secrete_key, production_key, bundleID, Locale.forLanguageTag(language));
    }

    private void sendChargeResult(Charge charge, String paymentStatus, String trx_mode) {


    }

    private void sendTokenResult(Token token, String paymentStatus, boolean saveCard) {

    }

    private void sendSDKError(int errorCode, String errorMessage, String errorBody) {

    }


    @Override
    public void asyncPaymentStarted(@NonNull Charge charge) {

    }

    @Override
    public void backendUnknownError(@Nullable GoSellError goSellError) {
        if (goSellError != null) {
            System.out.println("SDK Process Error : " + goSellError.getErrorBody());
            System.out.println("SDK Process Error : " + goSellError.getErrorMessage());
            System.out.println("SDK Process Error : " + goSellError.getErrorCode());
        }
        sendSDKError(goSellError.getErrorCode(), goSellError.getErrorMessage(), goSellError.getErrorBody());

    }

    @Override
    public void cardSaved(@NonNull Charge charge) {
        sendChargeResult(charge, "SUCCESS", "SAVE_CARD");
    }

    @Override
    public void cardSavingFailed(@NonNull Charge charge) {
        sendChargeResult(charge, "FAILED", "SAVE_CARD");
    }

    @Override
    public void cardTokenizedSuccessfully(@NonNull Token token, boolean b) {
        sendTokenResult(token, "SUCCESS", false);
    }

    @Override
    public void checkoutAuthorizeCaptured(@NonNull Authorize authorize) {
        sendChargeResult(authorize, "SUCCESS", "AUTHORIZE");


    }

    @Override
    public void checkoutAuthorizeFailed(@Nullable Authorize authorize) {
        sendChargeResult(authorize, "FAILED", "AUTHORIZE");
    }

    @Override
    public void checkoutChargeCaptured(@NonNull Charge charge) {
        sendChargeResult(charge, "SUCCESS", "CHARGE");
    }

    @Override
    public void checkoutChargeFailed(@Nullable Charge charge) {
        sendChargeResult(charge, "FAILED", "CHARGE");
    }

    @Override
    public void checkoutSdkError(@Nullable GoSellError goSellError) {
        if (goSellError != null) {
            System.out.println("SDK Process Error : " + goSellError.getErrorBody());
            System.out.println("SDK Process Error : " + goSellError.getErrorMessage());
            System.out.println("SDK Process Error : " + goSellError.getErrorCode());
        }
        sendSDKError(goSellError.getErrorCode(), goSellError.getErrorMessage(), goSellError.getErrorBody());

    }

    @Override
    public void invalidCardDetails() {
        System.out.println(" Card details are invalid....");
    }

    @Override
    public void invalidCustomerID() {
        System.out.println("Invalid Customer ID .......");
        sendSDKError(501, "Invalid Customer ID ", "Invalid Customer ID ");

    }

    @Override
    public void invalidTransactionMode() {
        System.out.println(" invalidTransactionMode  ......");
        sendSDKError(502, "invalidTransactionMode", "invalidTransactionMode");

    }

    @Override
    public void savedCardsList(@NonNull CardsList cardsList) {

    }

    @Override
    public void sessionCancelled() {
        Log.d("MainActivity", "Session Cancelled.........");
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("sdk_result", "CANCELLED");
        pendingResult.success(resultMap);
        pendingResult = null;
    }

    @Override
    public void sessionFailedToStart() {
        Log.d("MainActivity", "Session Failed to start.........");

    }

    @Override
    public void sessionHasStarted() {
        System.out.println(" Session Has Started .......");
    }

    @Override
    public void sessionIsStarting() {
        System.out.println(" Session Is Starting.....");
    }

    @Override
    public void userEnabledSaveCardOption(boolean b) {
        System.out.println("userEnabledSaveCardOption :  " + b);

    }


}
