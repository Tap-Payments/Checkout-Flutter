import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:checkout_flutter/checkout_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _checkoutStatus = 'Ready to checkout';

  @override
  void initState() {
    super.initState();
  }

  /// Start the checkout process using direct function calls
  /// No need for CheckoutFlutter class - just call startCheckout() directly
  Future<void> _startCheckout() async {
    try {
      setState(() {
        _checkoutStatus = 'Starting checkout...';
      });
      Map<String, dynamic> configurations = {
        "hashString": "",
        "language": "en",
        "themeMode": "light",
        "supportedPaymentMethods": "ALL",
        "paymentType": "ALL",
        "selectedCurrency": "KWD",
        "supportedCurrencies": "ALL",
        "supportedPaymentTypes": [],
        "supportedRegions": [],
        "supportedSchemes": [],
        "supportedCountries": [],
        "gateway": {
          "publicKey": "pk_test_ohzQrUWRnTkCLD1cqMeudyjX",
          "merchantId": "",
        },
        "customer": {
          "firstName": "Android",
          "lastName": "Test",
          "email": "example@gmail.com",
          "phone": {"countryCode": "965", "number": "55567890"},
        },
        "transaction": {
          "mode": "charge",
          "charge": {
            "saveCard": true,
            "auto": {"type": "VOID", "time": 100},
            "redirect": {
              "url": "https://demo.staging.tap.company/v2/sdk/checkout",
            },
            "threeDSecure": true,
            "subscription": {
              "type": "SCHEDULED",
              "amount_variability": "FIXED",
              "txn_count": 0,
            },
            "airline": {
              "reference": {"booking": ""},
            },
          },
        },
        "amount": "5",
        "order": {
          "id": "",
          "currency": "KWD",
          "amount": "5",
          "items": [
            {
              "amount": "5",
              "currency": "KWD",
              "name": "Item Title 1",
              "quantity": 1,
              "description": "item description 1",
            },
          ],
        },
        "cardOptions": {
          "showBrands": true,
          "showLoadingState": false,
          "collectHolderName": true,
          "preLoadCardName": "",
          "cardNameEditable": true,
          "cardFundingSource": "all",
          "saveCardOption": "all",
          "forceLtr": false,
          "alternativeCardInputs": {"cardScanner": true, "cardNFC": true},
        },
        "isApplePayAvailableOnClient": true,
      };

      // Call startCheckout function directly
      final success = await startCheckout(
        configurations: configurations,
        onReady: () {
          setState(() {
            _checkoutStatus = 'Checkout is ready!';
          });
          print('Checkout is ready!');
        },
        onSuccess: (data) {
          setState(() {
            _checkoutStatus = 'Payment successful: $data';
          });
          print('Payment successful: $data');
        },
        onError: (error) {
          setState(() {
            _checkoutStatus = 'Payment failed: $error';
          });
          print('Payment failed: $error');
        },
        onClose: () {
          setState(() {
            _checkoutStatus = 'Checkout closed';
          });
          print('Checkout closed');
        },
      );

      if (!success) {
        setState(() {
          _checkoutStatus = 'Failed to start checkout';
        });
      }
    } catch (e) {
      setState(() {
        _checkoutStatus = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout Flutter Example'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _checkoutStatus,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _startCheckout,
                icon: Icon(Icons.credit_card),
                label: Text('Start Checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
