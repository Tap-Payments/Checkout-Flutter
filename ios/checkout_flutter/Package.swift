// swift-tools-version: 5.9
// Used when the app builds with Swift Package Manager (flutter config --enable-swift-package-manager).
// checkout_flutter.podspec is the CocoaPods equivalent; keep the Checkout-IOS versions in step.

import PackageDescription

let package = Package(
    name: "checkout_flutter",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "checkout-flutter", targets: ["checkout_flutter"])
    ],
    dependencies: [
        .package(url: "https://github.com/Tap-Payments/Checkout-IOS.git", exact: "1.0.7")
    ],
    targets: [
        .target(
            name: "checkout_flutter",
            dependencies: [
                .product(name: "Checkout-IOS", package: "Checkout-IOS")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
