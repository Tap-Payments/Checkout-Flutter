/// The checkout_flutter example app, shared by cocoapods_example and spm_example: they only differ
/// in how iOS pulls in Checkout-IOS (CocoaPods or Swift Package Manager).
library;

import 'package:flutter/material.dart';

import 'src/home_screen.dart';
import 'src/widgets.dart';

export 'src/checkout_settings.dart';
export 'src/keys.dart';
export 'src/test_hooks.dart';

class CheckoutExampleApp extends StatelessWidget {
  const CheckoutExampleApp({super.key, this.title = 'Tap Checkout'});

  /// The window / task switcher title; each example app passes its own.
  final String title;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: title,
        debugShowCheckedModeBanner: false,
        theme: exampleTheme(Brightness.light),
        darkTheme: exampleTheme(Brightness.dark),
        home: const HomeScreen(),
      );
}
