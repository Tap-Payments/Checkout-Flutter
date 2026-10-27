import 'package:checkout_example/checkout_example.dart';
import 'package:flutter/material.dart';

// The app itself lives in ../shared (package:checkout_example); this example only differs from
// the other one in how iOS pulls in Checkout-IOS.
void main() => runApp(const CheckoutExampleApp(title: 'Checkout SPM'));
