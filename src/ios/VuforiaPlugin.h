#import <Cordova/CDV.h>

@interface VuforiaPlugin : CDVPlugin

- (void) cordovaStartVuforia:(CDVInvokedUrlCommand *)command;
- (void) cordovaStopVuforia:(CDVInvokedUrlCommand *)command;
- (void) cordovaStopTrackers:(CDVInvokedUrlCommand *)command;
- (void) cordovaStartTrackers:(CDVInvokedUrlCommand *)command;
- (void) cordovaUpdateTargets:(CDVInvokedUrlCommand *)command;

@end
