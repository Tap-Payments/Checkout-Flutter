package com.example.checkout_flutter

import android.app.Activity
import android.content.Context
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.FrameLayout
import company.tap.tapcheckout_android.CheckoutConfiguration
import company.tap.tapcheckout_android.TapCheckout
import company.tap.tapcheckout_android.TapCheckoutStatusDelegate
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONObject

/** CheckoutFlutterPlugin */
class CheckoutFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null
  private var context: Context? = null
  private var tapCheckoutView: TapCheckout? = null

  // Store reference to the fullscreen view for removal
  private var fullscreenView: android.view.View? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "checkout_flutter")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "startCheckout" -> {
        startCheckout(call, result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun startCheckout(call: MethodCall, result: Result) {
    val configurations = call.argument<Map<String, Any?>>("configurations")
    
    if (configurations == null) {
      result.error("INVALID_ARGUMENT", "Configurations are required", null)
      return
    }

    val currentActivity = activity
    if (currentActivity == null) {
      result.error("NO_ACTIVITY", "No activity available", null)
      return
    }

    try {
      // Inflate the layout
      val view = LayoutInflater.from(currentActivity).inflate(R.layout.tap_checkout_kit_layout, null)
      tapCheckoutView = view.findViewById(R.id.redirect_pay)
      
      // Store reference for later removal
      fullscreenView = view
      
      // Set fullscreen layout parameters
      val layoutParams = ViewGroup.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.MATCH_PARENT
      )
      view.layoutParams = layoutParams
      
      // Add the view to activity's content view as fullscreen
      val contentView = currentActivity.findViewById<ViewGroup>(android.R.id.content)
      contentView.addView(view, layoutParams)

      // Store reference to the fullscreen view
      fullscreenView = view


      val androidConfiguration = createAndroidConfiguration(configurations)
      
      // Extract public key from configurations
      val gateway = configurations["gateway"] as? Map<String, Any?>
      val publicKey = gateway?.get("publicKey") as? String ?: ""
      
      if (publicKey.isEmpty()) {
        result.error("INVALID_CONFIGURATION", "Public key is required", null)
        return
      }
      
      // Create delegate object instead of implementing interface
      val delegate = createCheckoutDelegate()
      
      // Call CheckoutConfiguration.configureWithTapCheckoutDictionary
      CheckoutConfiguration.configureWithTapCheckoutDictionary(
        currentActivity,
        publicKey,
        tapCheckoutView!!,
        androidConfiguration,
        delegate
      )
      
      result.success(true)
    } catch (e: Exception) {
      result.error("CHECKOUT_ERROR", "Failed to start checkout: ${e.message}", e.toString())
    }
  }

  private fun createAndroidConfiguration(configurations: Map<String, Any?>): LinkedHashMap<String, Any> {
    val configuration = LinkedHashMap<String, Any>()
    
    try {
      // Basic configuration
      configuration["open"] = true
      configuration["hashString"] = configurations["hashString"] ?: ""
      configuration["checkoutMode"] = "page"
      configuration["language"] = configurations["language"] ?: "en"
      configuration["themeMode"] = configurations["themeMode"] ?: "light"
      
      // Payment methods
      val supportedPaymentMethods = configurations["supportedPaymentMethods"]
      if (supportedPaymentMethods == "ALL") {
        configuration["supportedPaymentMethods"] = "ALL"
      } else if (supportedPaymentMethods is List<*>) {
        val jsonArrayPaymentMethod = JSONArray(supportedPaymentMethods)
        configuration["supportedPaymentMethods"] = jsonArrayPaymentMethod
      } else {
        configuration["supportedPaymentMethods"] = "ALL"
      }
      
      configuration["paymentType"] = configurations["paymentType"] ?: "ALL"
      configuration["selectedCurrency"] = configurations["selectedCurrency"] ?: "KWD"
      configuration["supportedCurrencies"] = "ALL"
      
      // Gateway
      val gateway = configurations["gateway"] as? Map<String, Any?>
      if (gateway != null) {
        val gatewayObj = JSONObject()
        gatewayObj.put("publicKey", gateway["publicKey"] ?: "")
        gatewayObj.put("merchantId", gateway["merchantId"] ?: "")
        configuration["gateway"] = gatewayObj
      }
      
      // Customer
      val customer = configurations["customer"] as? Map<String, Any?>
      if (customer != null) {
        val customerObj = JSONObject()
        customerObj.put("firstName", customer["firstName"] ?: "")
        customerObj.put("lastName", customer["lastName"] ?: "")
        customerObj.put("email", customer["email"] ?: "")
        
        val phone = customer["phone"] as? Map<String, Any?>
        if (phone != null) {
          val phoneObj = JSONObject()
          phoneObj.put("countryCode", phone["countryCode"] ?: "")
          phoneObj.put("number", phone["number"] ?: "")
          customerObj.put("phone", phoneObj)
        }
        
        configuration["customer"] = customerObj
      }
      
      // Transaction
      val transaction = configurations["transaction"] as? Map<String, Any?>
      if (transaction != null) {
        val transactionObj = JSONObject()
        val mode = transaction["mode"] ?: "charge"
        transactionObj.put("mode", mode)
        
        val charge = transaction["charge"] as? Map<String, Any?>
        if (charge != null) {
          val chargeObj = JSONObject()
          chargeObj.put("saveCard", charge["saveCard"] ?: true)
          chargeObj.put("threeDSecure", charge["threeDSecure"] ?: true)
          
          val auto = charge["auto"] as? Map<String, Any?>
          if (auto != null) {
            val autoObj = JSONObject()
            autoObj.put("type", auto["type"] ?: "VOID")
            autoObj.put("time", auto["time"] ?: 100)
            chargeObj.put("auto", autoObj)
          }
          
          val redirect = charge["redirect"] as? Map<String, Any?>
          if (redirect != null) {
            val redirectObj = JSONObject()
            redirectObj.put("url", redirect["url"] ?: "")
            chargeObj.put("redirect", redirectObj)
          }
          
          if (mode.toString().contains("authorize")) {
            transactionObj.put("authorize", chargeObj)
          } else {
            transactionObj.put("charge", chargeObj)
          }
        }
        
        configuration["transaction"] = transactionObj
      }
      
      // Amount
      configuration["amount"] = configurations["amount"] ?: "1"
      
      // Order
      val order = configurations["order"] as? Map<String, Any?>
      if (order != null) {
        val orderObj = JSONObject()
        orderObj.put("id", order["id"] ?: "")
        orderObj.put("currency", order["currency"] ?: "KWD")
        orderObj.put("amount", order["amount"] ?: "1")
        
        val items = order["items"] as? List<Map<String, Any?>>
        if (items != null) {
          val itemsArray = JSONArray()
          for (item in items) {
            val itemObj = JSONObject()
            itemObj.put("amount", item["amount"] ?: "1")
            itemObj.put("currency", item["currency"] ?: "KWD")
            itemObj.put("name", item["name"] ?: "")
            itemObj.put("quantity", item["quantity"] ?: 1)
            itemObj.put("description", item["description"] ?: "")
            itemsArray.put(itemObj)
          }
          orderObj.put("items", itemsArray)
        }
        
        configuration["order"] = orderObj
      }
      
      // Card Options
      val cardOptions = configurations["cardOptions"] as? Map<String, Any?>
      if (cardOptions != null) {
        val cardOptionsObj = JSONObject()
        cardOptionsObj.put("showBrands", cardOptions["showBrands"] ?: true)
        cardOptionsObj.put("showLoadingState", cardOptions["showLoadingState"] ?: false)
        cardOptionsObj.put("collectHolderName", cardOptions["collectHolderName"] ?: true)
        cardOptionsObj.put("preLoadCardName", cardOptions["preLoadCardName"] ?: "")
        cardOptionsObj.put("cardNameEditable", cardOptions["cardNameEditable"] ?: true)
        cardOptionsObj.put("cardFundingSource", cardOptions["cardFundingSource"] ?: "all")
        cardOptionsObj.put("saveCardOption", "all")
        cardOptionsObj.put("forceLtr", cardOptions["forceLtr"] ?: false)
        
        val alternativeCardInputs = cardOptions["alternativeCardInputs"] as? Map<String, Any?>
        if (alternativeCardInputs != null) {
          val altInputsObj = JSONObject()
          altInputsObj.put("cardScanner", alternativeCardInputs["cardScanner"] ?: true)
          altInputsObj.put("cardNFC", alternativeCardInputs["cardNFC"] ?: true)
          cardOptionsObj.put("alternativeCardInputs", altInputsObj)
        }
        
        configuration["cardOptions"] = cardOptionsObj
      }
      
      // Apple Pay availability (always false for Android)
      configuration["isApplePayAvailableOnClient"] = false
      
    } catch (e: Exception) {
      // If there's any error in configuration mapping, log it but continue
      println("Configuration mapping error: ${e.message}")
    }
    
    return configuration
  }

  // Create a separate delegate object instead of implementing the interface in the plugin class
  private fun createCheckoutDelegate(): TapCheckoutStatusDelegate {
    return object : TapCheckoutStatusDelegate {
      override fun onCheckoutSuccess(data: String) {
        channel.invokeMethod("onSuccess", mapOf("data" to data))
        removeFullscreenView()
      }

      override fun onCheckoutReady() {
        channel.invokeMethod("onReady", emptyMap<String, Any>())
      }

      override fun onCheckoutClick() {
      }

      override fun onCheckoutOrderCreated(data: String) {
      }

      override fun onCheckoutChargeCreated(data: String) {
      }

      override fun onCheckoutError(error: String) {
        removeFullscreenView()
        channel.invokeMethod("onError", mapOf("error" to error))
      }

      override fun onCheckoutcancel() {
        channel.invokeMethod("onCancel", emptyMap<String, Any>())
        // Remove the fullscreen view on cancel
        removeFullscreenView()
      }
    }
  }

  // ActivityAware implementation
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
    tapCheckoutView = null
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun removeFullscreenView() {
    fullscreenView?.let { view ->
      val contentView = activity?.findViewById<ViewGroup>(android.R.id.content)
      contentView?.removeView(view)
      fullscreenView = null
    }
  }
}
