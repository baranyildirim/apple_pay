import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import './request_objects.dart';


typedef ApplePaySuccessCallback = void Function(String token);
typedef ApplePayFailureCallback = void Function();
typedef ApplePayCancelCallback = void Function();

class ApplePay {
  static  MethodChannel _channel = 
    MethodChannel('apple_pay')
    ..setMethodCallHandler(_nativeCallHandler);

static ApplePaySuccessCallback _applePaySuccessCallback = null;
  static ApplePayFailureCallback _applePayFailureCallback = null;
  static ApplePayCancelCallback _applePayCancelCallback = null;


  static Future openApplePaySetup(
      {PaymentDataRequest request,
      ApplePaySuccessCallback onApplePaySuccess,
      ApplePayFailureCallback onApplePayFailure,
      ApplePayCancelCallback onApplePayCanceled}) async{

    _applePaySuccessCallback = onApplePaySuccess;
    _applePayFailureCallback = onApplePayFailure;
    _applePayCancelCallback = onApplePayCanceled;
  
    try {
      await _channel.invokeMethod('openApplePaySetup', jsonEncode(request));
    } on PlatformException catch (ex) {
      print('Platform exception in openApplePaySetup:\n');
      print(ex);
    }
  }

  static Future<dynamic> _nativeCallHandler(MethodCall call) async {
    print('Call to native call handler:\n');
    print(call.method);
    print(call.arguments);
    try {
      switch (call.method) {
        case 'onApplePayCanceled':
          if (_applePayCancelCallback != null) {
            print('Executing Apple pay cancel callback');
            _applePayCancelCallback();
          }
          break;
        case 'onApplePaySuccess':
          if (_applePaySuccessCallback != null) {
            var result = call.arguments;
            _applePaySuccessCallback(result['token']);
          }
          break;
        case 'onApplePayFailed':
          if (_applePayFailureCallback != null) {
            print('Executing Apple pay failure callback');
            _applePayFailureCallback();
          }
          break;
        default:
          throw Exception('unknown method called from native');
      }
    } on Exception catch (ex) {
      print('nativeCallHandler caught an exception:\n');
      print(ex);
    }
    return false;
  }

  static Future<String> get platformVersion async {
    String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> get checkIsReadyToPay async {
    bool isApplePayAvailable = await _channel.invokeMethod('checkIsReadyToPay');
    return isApplePayAvailable;
  }

}
