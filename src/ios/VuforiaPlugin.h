#import <Cordova/CDV.h>

@interface VuforiaPlugin : CDVPlugin

- (void) cordovaStartVuforia:(CDVInvokedUrlCommand *)command;
- (void) cordovaStopVuforia:(CDVInvokedUrlCommand *)command;

@end
