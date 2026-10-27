#
# Used when the app builds with CocoaPods. checkout_flutter/Package.swift is the Swift Package
# Manager equivalent; keep the Checkout-IOS versions in step.
# Run `pod lib lint checkout_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'checkout_flutter'
  s.version          = '1.0.5'
  s.summary          = 'Tap Payments checkout for Flutter.'
  s.description      = <<-DESC
Accept a payment with one or multiple payment methods securely. Powered by Tap Payments.
                       DESC
  s.homepage         = 'https://github.com/Tap-Payments/Checkout-Flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tap Payments' => 'm.allam@tap.company' }
  s.source           = { :path => '.' }
  s.source_files     = 'checkout_flutter/Sources/checkout_flutter/**/*.swift'
  s.resource_bundles = { 'checkout_flutter_privacy' => ['checkout_flutter/Sources/checkout_flutter/PrivacyInfo.xcprivacy'] }
  s.dependency 'Flutter'
  s.dependency 'Checkout-IOS', '1.0.7'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
