#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint checkout_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'checkout_flutter'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'https://tap.company'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tap Payments' => 'a.maqbool@tap.company' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'CheckoutSDK-iOS', '0.0.91'
  s.platform = :ios, '13.0'


  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
