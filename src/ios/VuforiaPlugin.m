#import "VuforiaPlugin.h"
#import "ViewController.h"

@interface VuforiaPlugin()

@property CDVInvokedUrlCommand *command;
@property ViewController *imageRecViewController;
@property BOOL startedVuforia;

@end

@implementation VuforiaPlugin

- (void) cordovaStartVuforia:(CDVInvokedUrlCommand *)command {

    NSLog(@"Vuforia Plugin :: Start plugin");

    NSLog(@"Arguments: %@", command.arguments);
    NSLog(@"KEY: %@", [command.arguments objectAtIndex:3]);

    [self startVuforiaWithImageTargetFile:[command.arguments objectAtIndex:0] imageTargetNames: [command.arguments objectAtIndex:1] customOverlayText: [command.arguments objectAtIndex:2] vuforiaLicenseKey: [command.arguments objectAtIndex:3]];
    self.command = command;

    self.startedVuforia = true;
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

    self.startedVuforia = false;
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];

    UINavigationController *nc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [nc popToRootViewControllerAnimated:YES];

}

- (void) cordovaStopVuforia:(CDVInvokedUrlCommand *)command {
    self.command = command;

    NSDictionary *jsonObj = [NSDictionary alloc];

    if(self.startedVuforia == true){
        NSLog(@"Vuforia Plugin :: Stopping plugin");

        jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                     @"true", @"success",
                     nil
                   ];
    }else{
        NSLog(@"Vuforia Plugin :: Cannot stop the plugin because it wasn't started");

        jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                     @"false", @"success",
                     @"No Vuforia session running", @"message",
                     nil
                   ];
    }

    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                    ];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];

    if(self.startedVuforia == true){
        UINavigationController *nc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [nc popToRootViewControllerAnimated:YES];

        self.startedVuforia = false;
    }
}

@end
