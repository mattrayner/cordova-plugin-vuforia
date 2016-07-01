#import "ViewController.h"
#import "ImageTargetsViewController.h"

#import <QCAR/TrackerManager.h>
#import <QCAR/ObjectTracker.h>

@interface ViewController ()

@property BOOL launchedCamera;
@property ImageTargetsViewController *imageTargetsViewController;

@end

@implementation ViewController


-(id)initWithFileName:(NSString *)fileName targetNames:(NSArray *)imageTargetNames overlayOptions:( NSDictionary *)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey {

    self = [super init];
    self.imageTargets = [[NSDictionary alloc] initWithObjectsAndKeys: fileName, @"imageTargetFile", imageTargetNames, @"imageTargetNames", nil];
    self.overlayOptions = overlayOptions;
    self.vuforiaLicenseKey = vuforiaLicenseKey;
    NSLog(@"Vuforia Plugin :: initWithFileName: %@", fileName);
    NSLog(@"Vuforia Plugin :: overlayOptions: %@", self.overlayOptions);
    NSLog(@"Vuforia Plugin :: License key: %@", self.vuforiaLicenseKey);
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    NSLog(@"Vuforia Plugin :: viewController did load");
    self.launchedCamera = false;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.launchedCamera == false) {
        self.imageTargetsViewController = [[ImageTargetsViewController alloc]  initWithOverlayOptions:self.overlayOptions vuforiaLicenseKey:self.vuforiaLicenseKey];
        self.launchedCamera = true;

        self.imageTargetsViewController.imageTargetFile = [self.imageTargets objectForKey:@"imageTargetFile"];
        self.imageTargetsViewController.imageTargetNames = [self.imageTargets objectForKey:@"imageTargetNames"];

        [self.navigationController pushViewController:self.imageTargetsViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (bool) stopTrackers {
    return [self.imageTargetsViewController doStopTrackers];
}

- (bool) startTrackers {
    return [self.imageTargetsViewController doStartTrackers];
}

- (bool) updateTargets:(NSArray *)targets {
    return [self.imageTargetsViewController doUpdateTargets:targets];
}

- (void)dismissMe {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CameraHasFound" object:self];
}

@end
