import 'dart:io';

import 'package:checkout_flutter/checkout_flutter.dart';
import 'package:checkout_flutter/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String _platformVersion = 'Unknown';
  final _checkoutFlutterPlugin = CheckoutFlutter();

  Map<dynamic, dynamic>? tapSDKResult;
  String responseID = "";
  String sdkStatus = "";
  String sdkErrorCode = "";
  String sdkErrorMessage = "";
  String sdkErrorDescription = "";

  @override
  void initState() {
    super.initState();
    sessionConfigurations();
  }

  Future<void> sessionConfigurations() async {
    try {
      CheckoutFlutter.startPayment(
        secretKeyModel: SecretKeyModel(
          sandbox: "pk_test_YhUjg9PNT8oDlKJ1aE2fMRz7",
          production: "sk_live_V4UDhitI0r7sFwHCfNB6xMKp",
        ),
        tapCustomer: TapCustomerModel(
          firstName: "Muhammad",
          middleName: "Azhar",
          lastName: "Maqbool",
          descriptionText: "",
          title: "",
          nationality: "",
          identifier: "",
          locale: "",
          phoneNumber: TapPhoneModel(
            isdNumber: "+92",
            phoneNumber: "3015082929",
          ),
          address: null,
          currency: null,
          emailAddress: null,
          metadata: {},
        ),
        bundleID: "tap.CheckoutSDK-iOS",
        metadata: {},
      );
    } on PlatformException {
      // platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      tapSDKResult = {};
    });
  }

  Future<void> startSDK() async {
    var tapSDKResult = await CheckoutFlutter.startCheckoutSDK;

    print('>>>> ${tapSDKResult['sdk_result']}');

    setState(() {
      switch (tapSDKResult['sdk_result']) {
        case "SUCCESS":
          sdkStatus = "SUCCESS";
          handleSDKResult();
          break;
        case "FAILED":
          sdkStatus = "FAILED";
          handleSDKResult();
          break;
        case "SDK_ERROR":
          print('sdk error............');
          print(tapSDKResult['sdk_error_code']);
          print(tapSDKResult['sdk_error_message']);
          print(tapSDKResult['sdk_error_description']);
          print('sdk error............');
          sdkErrorCode = tapSDKResult['sdk_error_code'].toString();
          sdkErrorMessage = tapSDKResult['sdk_error_message'];
          sdkErrorDescription = tapSDKResult['sdk_error_description'];
          break;

        case "NOT_IMPLEMENTED":
          sdkStatus = "NOT_IMPLEMENTED";
          break;
      }
    });
  }

  void handleSDKResult() {
    print('>>>> ${tapSDKResult!['trx_mode']}');

    switch (tapSDKResult!['trx_mode']) {
      case "CHARGE":
        printSDKResult('Charge');
        break;

      case "AUTHORIZE":
        printSDKResult('Authorize');
        break;

      case "SAVE_CARD":
        printSDKResult('Save Card');
        break;

      case "TOKENIZE":
        print('TOKENIZE token : ${tapSDKResult!['token']}');
        print('TOKENIZE token_currency  : ${tapSDKResult!['token_currency']}');
        print('TOKENIZE card_first_six : ${tapSDKResult!['card_first_six']}');
        print('TOKENIZE card_last_four : ${tapSDKResult!['card_last_four']}');
        print('TOKENIZE card_object  : ${tapSDKResult!['card_object']}');
        print('TOKENIZE card_exp_month : ${tapSDKResult!['card_exp_month']}');
        print('TOKENIZE card_exp_year    : ${tapSDKResult!['card_exp_year']}');

        responseID = tapSDKResult!['token'];
        break;
    }
  }

  void printSDKResult(String trx_mode) {
    print('$trx_mode status                : ${tapSDKResult!['status']}');
    if (trx_mode == "Authorize") {
      print('$trx_mode id              : ${tapSDKResult!['authorize_id']}');
    } else {
      print('$trx_mode id               : ${tapSDKResult!['charge_id']}');
    }
    print('$trx_mode  description        : ${tapSDKResult!['description']}');
    print('$trx_mode  message           : ${tapSDKResult!['message']}');
    print('$trx_mode  card_first_six : ${tapSDKResult!['card_first_six']}');
    print('$trx_mode  card_last_four   : ${tapSDKResult!['card_last_four']}');
    print('$trx_mode  card_object         : ${tapSDKResult!['card_object']}');
    print('$trx_mode  card_brand          : ${tapSDKResult!['card_brand']}');
    print('$trx_mode  card_exp_month  : ${tapSDKResult!['card_exp_month']}');
    print('$trx_mode  card_exp_year: ${tapSDKResult!['card_exp_year']}');
    print('$trx_mode  acquirer_id  : ${tapSDKResult!['acquirer_id']}');
    print(
        '$trx_mode  acquirer_response_code : ${tapSDKResult!['acquirer_response_code']}');
    print(
        '$trx_mode  acquirer_response_message: ${tapSDKResult!['acquirer_response_message']}');
    print('$trx_mode  source_id: ${tapSDKResult!['source_id']}');
    print('$trx_mode  source_channel     : ${tapSDKResult!['source_channel']}');
    print('$trx_mode  source_object      : ${tapSDKResult!['source_object']}');
    print(
        '$trx_mode source_payment_type : ${tapSDKResult!['source_payment_type']}');

    if (trx_mode == "Authorize") {
      responseID = tapSDKResult!['authorize_id'];
    } else {
      responseID = tapSDKResult!['charge_id'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 300,
                left: 18,
                right: 18,
                child: Text(
                  "Status: [$sdkStatus $responseID ]",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto",
                    fontStyle: FontStyle.normal,
                    fontSize: 15.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                bottom: Platform.isIOS ? 0 : 10,
                left: 18,
                right: 18,
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    clipBehavior: Clip.hardEdge,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    onPressed: startSDK,
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
