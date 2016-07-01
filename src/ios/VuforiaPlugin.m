#import "VuforiaPlugin.h"
#import "ViewController.h"

@interface VuforiaPlugin()

@property CDVInvokedUrlCommand *command;
@property ViewController *imageRecViewController;
@property BOOL startedVuforia;
@property BOOL autostopOnImageFound;

@end

@implementation VuforiaPlugin

- (void) cordovaStartVuforia:(CDVInvokedUrlCommand *)command {

    NSLog(@"Vuforia Plugin :: Start plugin");

    NSLog(@"Arguments: %@", command.arguments);
    NSLog(@"KEY: %@", [command.arguments objectAtIndex:3]);

    NSDictionary *overlayOptions =  [[NSDictionary alloc] initWithObjectsAndKeys: [command.arguments objectAtIndex:2], @"overlayText", [NSNumber numberWithBool:[[command.arguments objectAtIndex:5] integerValue]], @"showDevicesIcon", nil];

    self.autostopOnImageFound = [[command.arguments objectAtIndex:6] integerValue];

    [self startVuforiaWithImageTargetFile:[command.arguments objectAtIndex:0] imageTargetNames: [command.arguments objectAtIndex:1] overlayOptions: overlayOptions vuforiaLicenseKey: [command.arguments objectAtIndex:3]];
    self.command = command;

    self.startedVuforia = true;
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

    [self VP_closeView];
}

- (void) cordovaStopTrackers:(CDVInvokedUrlCommand *)command{
    bool result = [self.imageRecViewController stopTrackers];

    [self handleResultMessage:result command:command];
}

- (void) cordovaStartTrackers:(CDVInvokedUrlCommand *)command{
    bool result = [self.imageRecViewController startTrackers];

    [self handleResultMessage:result command:command];
}

- (void) cordovaUpdateTargets:(CDVInvokedUrlCommand *)command{
    NSArray *targets = [command.arguments objectAtIndex:0];

    // We need to ensure our targets are flatened, if we pass an array of items it'll crash if we dont
    NSMutableArray *flattenedTargets = [[NSMutableArray alloc] init];
    for (int i = 0; i < targets.count ; i++)
    {
        if([[targets objectAtIndex:i] respondsToSelector:@selector(count)]) {
            [flattenedTargets addObjectsFromArray:[targets objectAtIndex:i]];
        } else {
            [flattenedTargets addObject:[targets objectAtIndex:i]];
        }
    }

    targets = [flattenedTargets copy];

    NSLog(@"Updating targets: %@", targets);

    bool result = [self.imageRecViewController updateTargets:targets];

    [self handleResultMessage:result command:command];
}

#pragma mark - Util_Methods
- (void) startVuforiaWithImageTargetFile:(NSString *)imageTargetfile imageTargetNames:(NSArray *)imageTargetNames overlayOptions:(NSDictionary *)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ImageMatched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageMatched:) name:@"ImageMatched" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CloseRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeRequest:) name:@"CloseRequest" object:nil];

    UINavigationController *nc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    self.imageRecViewController = [[ViewController alloc] initWithFileName:imageTargetfile targetNames:imageTargetNames overlayOptions:overlayOptions vuforiaLicenseKey:vuforiaLicenseKey];

    [nc pushViewController:self.imageRecViewController animated:YES];
}


- (void)imageMatched:(NSNotification *)notification {

    NSDictionary* userInfo = notification.userInfo;

    NSLog(@"Vuforia Plugin :: image matched");
    NSDictionary* jsonObj = @{@"status": @{@"imageFound": @true, @"message": @"Image Found."}, @"result": @{@"imageName": userInfo[@"result"][@"imageName"]}};

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: jsonObj];

    if(!self.autostopOnImageFound){
        [pluginResult setKeepCallbackAsBool:TRUE];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];

    if(self.autostopOnImageFound){
        [self VP_closeView];
    }
}

- (void)closeRequest:(NSNotification *)notification {

    NSDictionary* jsonObj = @{@"status": @{@"manuallyClosed": @true, @"message": @"User manually closed the plugin."}};

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: jsonObj];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
    [self VP_closeView];
}

- (void) VP_closeView {
    if(self.startedVuforia == true){
        UINavigationController *nc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [nc popToRootViewControllerAnimated:YES];

        self.startedVuforia = false;
    }
}

-(void) handleResultMessage:(bool)result command:(CDVInvokedUrlCommand *)command {
    if(result){
        [self sendSuccessMessage:command];
    } else {
        [self sendErrorMessage:command];
    }
}

-(void) sendSuccessMessage:(CDVInvokedUrlCommand *)command {
    NSDictionary *jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                             @"true", @"success",
                             nil
                             ];

    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) sendErrorMessage:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_ERROR
                                     messageAsString: @"Did not successfully complete"
                                     ];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
