#import "VuforiaPlugin.h"
#import "ViewController.h"

@interface VuforiaPlugin()

@property CDVInvokedUrlCommand *command;
@property ViewController *imageRecViewController;

@end

@implementation VuforiaPlugin

- (void) cordovaStartVuforia:(CDVInvokedUrlCommand *)command {

    NSLog(@"Vuforia Plugin :: Start plugin");

    NSLog(@"Arguments: %@", command.arguments);
    NSLog(@"KEY: %@", [command.arguments objectAtIndex:3]);
    
    [self startVuforiaWithImageTargetFile:[command.arguments objectAtIndex:0] imageTargetNames: [command.arguments objectAtIndex:1] customOverlayText: [command.arguments objectAtIndex:2] vuforiaLicenseKey: [command.arguments objectAtIndex:3]];
    self.command = command;
}

#pragma mark - Util_Methods
- (void) startVuforiaWithImageTargetFile:(NSString *)imageTargetfile imageTargetNames:(NSArray *)imageTargetNames customOverlayText:(NSString *)customOverlayText vuforiaLicenseKey:(NSString *)vuforiaLicenseKey {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ImageMatched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageMatched:) name:@"ImageMatched" object:nil];
    
    UINavigationController *nc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    self.imageRecViewController = [[ViewController alloc] initWithFileName:imageTargetfile targetNames:imageTargetNames customOverlayText:customOverlayText vuforiaLicenseKey:vuforiaLicenseKey];
    
    [nc pushViewController:self.imageRecViewController animated:YES];
}


- (void)imageMatched:(NSNotification *)notification {
    
    NSDictionary* userInfo = notification.userInfo;
    
    NSLog(@"Vuforia Plugin :: image matched");
    // Create an object with a simple success property.
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             userInfo[@"imageName"], @"imageName",
                             @"true", @"success",
                             nil
                             ];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];

    UINavigationController *nc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [nc popToRootViewControllerAnimated:YES];
}

@end