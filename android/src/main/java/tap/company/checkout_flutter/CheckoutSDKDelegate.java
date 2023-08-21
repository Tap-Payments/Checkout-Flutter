package tap.company.checkout_flutter;


import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import company.tap.checkout.TapCheckOutSDK;
import company.tap.checkout.internal.api.models.Authorize;
import company.tap.checkout.internal.api.models.Charge;
import company.tap.checkout.internal.api.models.Token;
import company.tap.checkout.open.controller.SDKSession;
import company.tap.checkout.open.interfaces.CheckOutDelegate;
import company.tap.checkout.open.models.CardsList;
import company.tap.checkout.open.models.OrderObject;
import company.tap.checkout.open.models.TapCurrency;
import company.tap.checkout.open.models.TapCustomer;
import company.tap.tapnetworkkit.exception.GoSellError;
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
        showSDK(sdkConfigurations, result);
    }

    public void terminateSDKSession() {
        if (activity != null) {
            //  sdkSession.cancelSession(activity);
        }
    }

    private void showSDK(HashMap<String, Object> sdkConfigurations, MethodChannel.Result result) {
        HashMap<String, Object> config = (HashMap<String, Object>) sdkConfigurations
                .get("configuration");
        System.out.println("SDK CONFIGURATION >>>>>>>" + config);
        String sandboxKey = (String) config.get("sandbox");

        String productionKey = (String) config.get("production");
        String locale = (String) config.get("localeIdentifier");
        String bundleID = (String) config.get("bundleID");

        configureApp(sandboxKey, productionKey, bundleID, locale);
        configureSDKSession(config, result);

        sdkSession.startSDK(this, activity, activity);
    }

    private void configureSDKSession(HashMap<String, Object> sessionParameters, MethodChannel.Result result) {

        System.out.println("Complete Configuration" + sessionParameters);
        if (sdkSession == null) {
            sdkSession = SDKSession.INSTANCE;
        }
        sdkSession.addSessionDelegate(this);
        sdkSession.instantiatePaymentDataSource();
        sdkSession.setCustomer(Objects.requireNonNull(DeserializationUtil.getCustomer(sessionParameters)));
        sdkSession.setTransactionMode(DeserializationUtil.getTransactionMode((String) sessionParameters.get("transactionMode")));
        BigDecimal amount;
        try {
            amount = new BigDecimal(Double.toString((Double) sessionParameters.get("amount")));
        } catch (Exception e) {
            Log.d("CheckoutSDKDelegate : ", "Invalid amount can't be parsed to double ");
            amount = BigDecimal.ZERO;
        }
        sdkSession.setAmount(amount);
        sdkSession.setCardType(DeserializationUtil.getCardType((String) sessionParameters.get("allowedCardTypes")));

        sdkSession.setAuthorizeAction(DeserializationUtil.getAuthorizeAction(sessionParameters.get("authorizeAction")));
        sdkSession.setReceiptSettings(DeserializationUtil.getReceipt(sessionParameters.get("receiptSettings")));
        sdkSession.setDestination(null);
        /// This set destination object should be an array instead of single object
        /// sdkSession.setDestination(DeserializationUtil.getDestinations(Objects.requireNonNull(sessionParameters.get("destinations")))); // Issue here

        sdkSession.setShipping(null);
        /// This shipping method getting Array List, it should be a single object
        // sdkSession.setShipping(DeserializationUtil.getShipping(sessionParameters.get("shipping")));
        sdkSession.setPaymentItems(DeserializationUtil.getPaymentItems(sessionParameters.get("items")));
        sdkSession.setTaxes(DeserializationUtil.getTaxes(sessionParameters.get("taxes")));
        sdkSession.setPostURL(sessionParameters.get("postURL").toString());
        sdkSession.setPaymentDescription(sessionParameters.get("paymentDescription").toString());
        HashMap<String, String> hashMap = new HashMap<>();
        hashMap.put("a", "b");
        sdkSession.setPaymentMetadata(hashMap);
        sdkSession.setPaymentReference(DeserializationUtil.getReference(sessionParameters.get("paymentReference")));
        sdkSession.setPaymentStatementDescriptor(sessionParameters.get("paymentStatementDescriptor").toString());
        sdkSession.isRequires3DSecure((boolean) sessionParameters.get("require3DSecure"));
        sdkSession.setAuthorizeAction(DeserializationUtil.getAuthorizeAction(sessionParameters.get("authorizeAction")));
        sdkSession.setMerchantID((String) sessionParameters.get("merchantID"));
        sdkSession.setCardType(DeserializationUtil.getCardType((String) sessionParameters.get("allowedCadTypes")));
        sdkSession.setPaymentType(DeserializationUtil.getPaymentType((String) sessionParameters.get("paymentType")));
        sdkSession.setSdkMode(DeserializationUtil.getSDKMode((String) sessionParameters.get("sdkMode")));
        sdkSession.setDefaultCardHolderName((String) sessionParameters.get("cardHolderName"));
        sdkSession.setTransactionCurrency(new TapCurrency(Objects.requireNonNull(sessionParameters.get("currency")).toString()));
        sdkSession.setOrderObject(new OrderObject(BigDecimal.ONE, "KWD", new TapCustomer("cus_TS012520211349Za012907577", "Muhammad", "Azhar", "Maqbool", "a.maqbool@tap.company", null, null, "+92", null, "en"), null, null, null, null, null, null));
        sdkSession.startPayment(this);

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
        System.out.println("CHARGE RESULT RESPONSE >>>>>>>>>>" + charge);
        Map<String, Object> resultMap = new HashMap<>();
        if (charge.getStatus() != null)
            resultMap.put("sdk_result", paymentStatus);
        resultMap.put("trx_mode", trx_mode);
        pendingResult.success(resultMap);
        pendingResult = null;

    }

    private void sendTokenResult(Token token, String paymentStatus, boolean saveCard) {

    }

    private void sendSDKError(int errorCode, String errorMessage, String errorBody) {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("sdk_result", "SDK_ERROR");
        resultMap.put("sdk_error_code", errorCode);
        resultMap.put("sdk_error_message", errorMessage);
        resultMap.put("sdk_error_description", errorBody);
        pendingResult.success(resultMap);
        pendingResult = null;
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
