import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:apple_pay/apple_pay.dart';
import 'package:apple_pay/request_objects.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _applePayToken = "Unknown";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await ApplePay.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              Text('Apple pay token: $_applePayToken\n'),
              FlatButton(
                child: Text("Apple Pay Button"),
                onPressed: onButtonPressed,
              )
          ]    
          ),
        ),
      ),
    );
  }

  void onButtonPressed() async{
    PaymentItem testItem = PaymentItem(label: "Test Item", amount: 99.0);
    List<PaymentItem> testList = [];
    testList.add(testItem);
    PaymentDataRequest testRequest = PaymentDataRequest(publishableKey: "<STRIPE>", merchantName: "Test Merchant", country: "US", currencyCode: "USD", items: testList);
    setState((){_applePayToken = "Fetching";});
    try {
      await ApplePay.openApplePaySetup(
          request: testRequest,
          onApplePaySuccess: onSuccess,
          onApplePayFailure: onFailure,
          onApplePayCanceled: onCancelled);
      setState((){_applePayToken = "Done Fetching";});
    } on PlatformException catch (ex) {
      setState((){_applePayToken = "Failed Fetching";});
    }
    
  }

  void onSuccess(String token){ 
    setState((){_applePayToken = token;});
  }

  void onFailure(){ 
    setState((){_applePayToken = "Failure";});
  }

  void onCancelled(){ 
    setState((){_applePayToken = "Cancelled";});
  }
}
