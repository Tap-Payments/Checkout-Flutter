package com.example.checkout_flutter

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.anyString
import org.mockito.ArgumentMatchers.eq
import org.mockito.Mockito

/*
 * Unit tests of the Kotlin side of the plugin. Run them from the example app:
 *   cd example/cocoapods_example/android && ./gradlew :checkout_flutter:testDebugUnitTest
 */
internal class CheckoutFlutterPluginTest {

  private fun call(method: String, arguments: Any?): MethodChannel.Result {
    val result = Mockito.mock(MethodChannel.Result::class.java)
    CheckoutFlutterPlugin().onMethodCall(MethodCall(method, arguments), result)
    return result
  }

  @Test
  fun unknownMethodIsNotImplemented() {
    Mockito.verify(call("getPlatformVersion", null)).notImplemented()
  }

  @Test
  fun startCheckoutNeedsConfigurations() {
    Mockito.verify(call("startCheckout", emptyMap<String, Any>())).error(eq("INVALID_ARGUMENT"), anyString(), any())
  }

  @Test
  fun startCheckoutNeedsAPublicKey() {
    val arguments = mapOf("configurations" to mapOf("gateway" to mapOf("publicKey" to "")))
    Mockito.verify(call("startCheckout", arguments)).error(eq("INVALID_CONFIGURATION"), anyString(), any())
  }

  @Test
  fun startCheckoutNeedsAnActivity() {
    val arguments = mapOf("configurations" to mapOf("gateway" to mapOf("publicKey" to "pk_test_x")))
    Mockito.verify(call("startCheckout", arguments)).error(eq("NO_ACTIVITY"), anyString(), any())
  }

  @Test
  fun publicKeyIsReadFromTheGateway() {
    assertEquals("pk_test_x", CheckoutArguments.publicKey(mapOf("gateway" to mapOf("publicKey" to "pk_test_x"))))
    assertNull(CheckoutArguments.publicKey(mapOf("publicKey" to "pk_test_x")))
  }

  @Test
  fun configurationKeepsNestingAndDropsNulls() {
    val configuration = CheckoutArguments.configuration(
      mapOf(
        "amount" to 0.1,
        "hashString" to null,
        "gateway" to mapOf("publicKey" to "pk_test_x", "merchantId" to null),
        "order" to mapOf("items" to listOf(mapOf("quantity" to 1, "name" to null), null)),
        "supportedCurrencies" to listOf("SAR", "KWD"),
      ),
    )
    assertEquals(
      mapOf(
        "amount" to 0.1,
        "gateway" to mapOf("publicKey" to "pk_test_x"),
        "order" to mapOf("items" to listOf(mapOf("quantity" to 1))),
        "supportedCurrencies" to listOf("SAR", "KWD"),
      ),
      configuration,
    )
  }
}
