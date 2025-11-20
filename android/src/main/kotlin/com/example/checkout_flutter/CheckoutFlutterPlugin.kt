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
    return try {
      convertToLinkedHashMap(configurations)
    } catch (e: Exception) {
      println("Configuration mapping error: ${e.message}")
      LinkedHashMap()
    }
  }
  
  private fun convertToLinkedHashMap(source: Map<String, Any?>): LinkedHashMap<String, Any> {
    val result = LinkedHashMap<String, Any>()
    
    for ((key, value) in source) {
      val convertedValue = convertValue(value)
      if (convertedValue != null) {
        result[key] = convertedValue
      }
    }
    
    return result
  }
  
  private fun convertValue(value: Any?): Any? {
    return when (value) {
      null -> null
      is String, is Boolean, is Int, is Long, is Double, is Float -> value
      is ByteArray -> value // Binary data from Flutter
      is Map<*, *> -> {
        // Recursively convert nested maps to JSONObject
        @Suppress("UNCHECKED_CAST")
        val nestedMap = value as Map<String, Any?>
        JSONObject(convertToLinkedHashMap(nestedMap))
      }
      is List<*> -> {
        // Convert lists to JSONArray, handling all possible types in lists
        val jsonArray = JSONArray()
        for (item in value) {
          val convertedItem = convertValue(item)
          if (convertedItem != null) {
            jsonArray.put(convertedItem)
          }
        }
        jsonArray
      }
      else -> value // Fallback for any other types
    }
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
        channel.invokeMethod("onError", mapOf("data" to error))
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
