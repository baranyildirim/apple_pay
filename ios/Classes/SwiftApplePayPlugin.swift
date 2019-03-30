import Flutter
import UIKit
import Stripe

public class SwiftApplePayPlugin: NSObject, FlutterPlugin {
    var _channel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "apple_pay", binaryMessenger: registrar.messenger())
        let instance = SwiftApplePayPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance._channel = channel;
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "getPlatformVersion"){
            result("iOS " + UIDevice.current.systemVersion)
        }
        else if(call.method == "openApplePaySetup"){
            openApplePaySetup(result, arguments: call.arguments)
        }
        else if(call.method == "checkIsReadyToPay"){
            checkIsReadyToPay(result)

        }
    }
    
    private func checkIsReadyToPay(_ result: @escaping FlutterResult){
        result(Stripe.deviceSupportsApplePay());
    }
    
    private func openApplePaySetup(_ result: @escaping FlutterResult, arguments: Any?){
        do{
            let jsonString = arguments as! String
            let data = jsonString.data(using: .utf8)
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            STPPaymentConfiguration.shared().publishableKey = json!["publishableKey"] as! String
            let merchantIdentifier = json!["merchantName"] as! String
            let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: json!["country"] as! String, currency: json!["currencyCode"] as! String)
            let items = json!["items"] as! [[String:Any]]
            for item in items{
                let label = item["label"] as! String
                let amount = item["amount"] as! Double
                let amountDecimal = NSDecimalNumber.init(value: amount)
                paymentRequest.paymentSummaryItems.append(PKPaymentSummaryItem(label: label, amount: amountDecimal))
            }
            
            if Stripe.canSubmitPaymentRequest(paymentRequest) {
                // Setup payment authorization view controller
                let viewController =  UIApplication.shared.keyWindow?.rootViewController
                viewController?.dismiss(animated: false, completion: nil)
                
                let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                paymentAuthorizationViewController!.delegate = self as? PKPaymentAuthorizationViewControllerDelegate
                
                
                viewController!.present(paymentAuthorizationViewController!, animated: true, completion: nil)
                result(nil)
            }
            else {
               self._channel?.invokeMethod("onApplePayFailed", arguments: nil)
            }
        }
        catch{
            self._channel?.invokeMethod("onApplePayFailed", arguments: nil)
        }

    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        STPAPIClient.shared().createToken(with: payment) { (token: STPToken?, error: Error?) in
            guard let token = token, error == nil else {
                self._channel?.invokeMethod("onApplePayFailed", arguments: nil)
                return
            }
            var args = [String : String]()
            args["token"] = token.tokenId;
            self._channel?.invokeMethod("onApplePaySuccess", arguments: token)
        }
    }
    
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        var viewController =  UIApplication.shared.keyWindow?.rootViewController
    
        if(viewController is UINavigationController){
        viewController?.navigationController?.popViewController(animated: true)
        }
        else {
            viewController?.dismiss(animated: true, completion: nil)
        }
        viewController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    
}
