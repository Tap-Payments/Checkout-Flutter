
import 'checkout_flutter_platform_interface.dart';

class CheckoutFlutter {
  Future<String?> getPlatformVersion() {
    return CheckoutFlutterPlatform.instance.getPlatformVersion();
  }
}
