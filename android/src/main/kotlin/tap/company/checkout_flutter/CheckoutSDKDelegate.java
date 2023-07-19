package tap.company.checkout_flutter;

import android.app.Activity;
import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;


import java.math.BigDecimal;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class CheckoutSDKDelegate implements PluginRegistry.ActivityResultListener,
        PluginRegistry.RequestPermissionsResultListener, CheckOutDelegate {


    private Activity activity;
    private SDKSession dataConfiguration;
    private CurrencyViewHolder currencyViewHolder;
    private MethodChannel.Result pendingResult;
    private MethodCall methodCall;


    public CheckoutSDKDelegate(Activity _activity) {
        this.activity = _activity;
        this.dataConfiguration = DataConfiguration.INSTANCE;
    }
}