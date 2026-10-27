package com.example.checkout_flutter

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
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

/**
 * Bridges the `checkout_flutter` method channel to Checkout-Android: `startCheckout` adds a full-screen
 * `TapCheckout` view over the Flutter activity, and the delegate callbacks are sent back to Dart with
 * the same names the iOS plugin uses (onReady, onChargeCreated, onSuccess, onError, onClose).
 */
class CheckoutFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private var channel: MethodChannel? = null
  private var activity: Activity? = null
  private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

  /** The view of the checkout that is on screen, if any. */
  private var checkoutView: TapCheckout? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "checkout_flutter").also { it.setMethodCallHandler(this) }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    channel = null
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "startCheckout" -> startCheckout(call, result)
      else -> result.notImplemented()
    }
  }

  private fun startCheckout(call: MethodCall, result: Result) {
    val configurations = call.argument<Map<String, Any?>>("configurations")
    if (configurations == null) {
      result.error("INVALID_ARGUMENT", "Configurations are required", null)
      return
    }
    val publicKey = CheckoutArguments.publicKey(configurations)
    if (publicKey.isNullOrEmpty()) {
      result.error("INVALID_CONFIGURATION", "gateway.publicKey is required", null)
      return
    }
    val currentActivity = activity
    if (currentActivity == null) {
      result.error("NO_ACTIVITY", "No activity available", null)
      return
    }

    try {
      // A checkout that is still open is replaced by the new one.
      removeCheckoutView()
      val view = TapCheckout(currentActivity)
      currentActivity.findViewById<ViewGroup>(android.R.id.content).addView(
        view,
        ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT),
      )
      // The view shows the SDK's loader right away and stays until the flow ends.
      view.visibility = View.VISIBLE
      checkoutView = view

      CheckoutConfiguration.configureWithTapCheckoutDictionary(
        currentActivity,
        publicKey,
        view,
        CheckoutArguments.configuration(configurations),
        Delegate(view),
      )
      result.success(true)
    } catch (e: Exception) {
      removeCheckoutView()
      result.error("CHECKOUT_ERROR", "Failed to start checkout: ${e.message}", e.toString())
    }
  }

  /**
   * One delegate per checkout. Once the flow has ended (success, error or close) its view is removed
   * and later events are dropped: the page can still report a stale "Card loading timeout" error
   * minutes after a success.
   */
  private inner class Delegate(private val view: TapCheckout) : TapCheckoutStatusDelegate {
    private var finished = false

    private fun send(method: String, data: String? = null, ends: Boolean = false) = mainHandler.post {
      if (finished) return@post
      if (ends) {
        finished = true
        if (checkoutView === view) removeCheckoutView()
      }
      channel?.invokeMethod(method, data?.let { mapOf("data" to it) })
    }

    override fun onCheckoutReady() { send("onReady") }
    override fun onCheckoutChargeCreated(data: String) { send("onChargeCreated", data) }
    override fun onCheckoutSuccess(data: String) { send("onSuccess", data, ends = true) }
    override fun onCheckoutError(error: String) { send("onError", error, ends = true) }
    override fun onCheckoutcancel() { send("onClose", ends = true) }
  }

  private fun removeCheckoutView() {
    checkoutView?.let { view -> (view.parent as? ViewGroup)?.removeView(view) }
    checkoutView = null
  }

  // ActivityAware

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
    removeCheckoutView()
    activity = null
  }
}

/** Turns the arguments of `startCheckout` into what Checkout-Android expects. Plain JVM, so it is unit tested. */
internal object CheckoutArguments {

  fun publicKey(configurations: Map<String, Any?>): String? =
    (configurations["gateway"] as? Map<*, *>)?.get("publicKey") as? String

  /**
   * The SDK takes a `HashMap<String, Any>` whose nested objects are maps and lists, which is what the
   * method channel delivers. Only `null` values have to go: the map cannot hold them.
   */
  fun configuration(configurations: Map<String, Any?>): HashMap<String, Any> {
    val result = HashMap<String, Any>()
    for ((key, value) in configurations) {
      clean(value)?.let { result[key] = it }
    }
    return result
  }

  private fun clean(value: Any?): Any? = when (value) {
    null -> null
    is Map<*, *> -> LinkedHashMap<String, Any>().apply {
      for ((key, nested) in value) clean(nested)?.let { put(key.toString(), it) }
    }
    is List<*> -> value.mapNotNull { clean(it) }
    else -> value
  }
}
