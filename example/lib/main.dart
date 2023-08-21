import 'dart:io';

import 'package:checkout_flutter/checkout_flutter.dart';
import 'package:checkout_flutter/models/models.dart';
import 'package:checkout_flutter_example/tap_loader/awesome_loader.dart';
import 'package:flutter/foundation.dart';
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
  Map<dynamic, dynamic>? tapSDKResult;
  String responseID = "";
  String sdkStatus = "";
  String sdkErrorCode = "";
  String sdkErrorMessage = "";
  String sdkErrorDescription = "";
  AwesomeLoaderController loaderController = AwesomeLoaderController();

  @override
  void initState() {
    super.initState();
    sessionConfigurations();
  }

  Future<void> sessionConfigurations() async {
    try {
      CheckoutFlutter.startPayment(
        sandboxKey: "pk_test_YhUjg9PNT8oDlKJ1aE2fMRz7",
        productionKey: "sk_live_V4UDhitI0r7sFwHCfNB6xMKp",
        tapCustomer: TapCustomerModel(
          firstName: "Muhammad",
          middleName: "Azhar",
          lastName: "Maqbool",
          descriptionText: "",
          title: "",
          nationality: "",
          identifier: "cus_TS012520211349Za012907577",
          locale: "",
          phoneNumber: TapPhoneModel(
            isdNumber: "+92",
            phoneNumber: "3015082929",
          ),
          address: AddressModel(
            type: AddressType.Residential,
            country: CountryModel(
              isoCode: "92",
            ),
            line1: null,
            line2: null,
            line3: null,
            line4: null,
            city: null,
            state: null,
            zipCode: null,
            apartment: null,
            area: null,
            avenue: null,
            block: null,
            buildingHouse: null,
            postalBox: null,
            postalCode: null,
            office: null,
            street: null,
            floor: null,
            countryGovernorate: null,
          ),
          // currency: TapCurrencyCode.USD,
          emailAddress: TapEmailAddressModel(
            value: "a.maqbool@tap.company",
          ),
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
    setState(() {
      loaderController.start();
    });

    var tapSDKResult = await CheckoutFlutter.startCheckoutSDK;

    if (kDebugMode) {
      print('SDK RESULT>>>> ${tapSDKResult['sdk_result']}');
    }
    loaderController.stopWhenFull();
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
          if (kDebugMode) {
            print('sdk error............');
            print(tapSDKResult['sdk_error_code']);
            print(tapSDKResult['sdk_error_message']);
            print(tapSDKResult['sdk_error_description']);
            print('sdk error............');
          }
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
    if (kDebugMode) {
      print('>>>> ${tapSDKResult!['trx_mode']}');
    }

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
        if (kDebugMode) {
          print('TOKENIZE token : ${tapSDKResult!['token']}');
          print(
              'TOKENIZE token_currency  : ${tapSDKResult!['token_currency']}');
          print('TOKENIZE card_first_six : ${tapSDKResult!['card_first_six']}');
          print('TOKENIZE card_last_four : ${tapSDKResult!['card_last_four']}');
          print('TOKENIZE card_object  : ${tapSDKResult!['card_object']}');
          print('TOKENIZE card_exp_month : ${tapSDKResult!['card_exp_month']}');
          print(
              'TOKENIZE card_exp_year    : ${tapSDKResult!['card_exp_year']}');
        }

        responseID = tapSDKResult!['token'];
        break;
    }
  }

  void printSDKResult(String trxMode) {
    if (kDebugMode) {
      print('$trxMode status                : ${tapSDKResult!['status']}');
    }
    if (trxMode == "Authorize") {
      if (kDebugMode) {
        print('$trxMode id              : ${tapSDKResult!['authorize_id']}');
      }
    } else {
      if (kDebugMode) {
        print('$trxMode id               : ${tapSDKResult!['charge_id']}');
      }
    }
    if (kDebugMode) {
      print('$trxMode  description        : ${tapSDKResult!['description']}');
      print('$trxMode  message           : ${tapSDKResult!['message']}');
      print('$trxMode  card_first_six : ${tapSDKResult!['card_first_six']}');
      print('$trxMode  card_last_four   : ${tapSDKResult!['card_last_four']}');
      print('$trxMode  card_object         : ${tapSDKResult!['card_object']}');
      print('$trxMode  card_brand          : ${tapSDKResult!['card_brand']}');
      print('$trxMode  card_exp_month  : ${tapSDKResult!['card_exp_month']}');
      print('$trxMode  card_exp_year: ${tapSDKResult!['card_exp_year']}');
      print('$trxMode  acquirer_id  : ${tapSDKResult!['acquirer_id']}');
      print(
          '$trxMode  acquirer_response_code : ${tapSDKResult!['acquirer_response_code']}');
      print(
          '$trxMode  acquirer_response_message: ${tapSDKResult!['acquirer_response_message']}');
      print('$trxMode  source_id: ${tapSDKResult!['source_id']}');
      print(
          '$trxMode  source_channel     : ${tapSDKResult!['source_channel']}');
      print('$trxMode  source_object      : ${tapSDKResult!['source_object']}');
      print(
          '$trxMode source_payment_type : ${tapSDKResult!['source_payment_type']}');
    }

    if (trxMode == "Authorize") {
      responseID = tapSDKResult!['authorize_id'];
    } else {
      responseID = tapSDKResult!['charge_id'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          centerTitle: true,
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
                  height: 50,
                  child: FilledButton(
                    onPressed: startSDK,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 25,
                          height: 25,
                          child: AwesomeLoader(
                            outerColor: Colors.white,
                            innerColor: Colors.white,
                            strokeWidth: 3.0,
                            controller: loaderController,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'START',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                        ),
                      ],
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
