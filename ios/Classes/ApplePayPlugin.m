#import "ApplePayPlugin.h"
#import <apple_pay/apple_pay-Swift.h>


@implementation ApplePayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftApplePayPlugin registerWithRegistrar:registrar];
}
@end
