/*===============================================================================
 Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

 Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States
 and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
 ===============================================================================*/
#import "AppDelegate.h"
#import "ViewController.h"
#import "GLResourceHandler.h"

#import <UIKit/UIKit.h>
#import "ImageTargetsViewController.h"
#import <QCAR/QCAR.h>
#import <QCAR/TrackerManager.h>
#import <QCAR/ObjectTracker.h>
#import <QCAR/Trackable.h>
#import <QCAR/TrackableResult.h>
#import <QCAR/DataSet.h>
#import <QCAR/CameraDevice.h>

#import <QCAR/QCAR_iOS.h>

@interface ImageTargetsViewController ()

@property (assign, nonatomic) id<GLResourceHandler> glResourceHandler;


@end

@implementation ImageTargetsViewController

- (id)initWithOverlayOptions:(NSDictionary *)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey
{
    NSLog(@"Vuforia Plugin :: INIT IMAGE TARGETS VIEW CONTROLLER");
    NSLog(@"Vuforia Plugin :: OVERLAY: %@", overlayOptions);
    NSLog(@"Vuforia Plugin :: LICENSE: %@", vuforiaLicenseKey);

    self.overlayOptions = overlayOptions;
    self.vuforiaLicenseKey = vuforiaLicenseKey;

    self = [self initWithNibName:nil bundle:nil];

    self.delaying = false;

    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"Vuoria Plugin :: vuforiaLicenseKey: %@", self.vuforiaLicenseKey);
        vapp = [[ApplicationSession alloc] initWithDelegate:self vuforiaLicenseKey:self.vuforiaLicenseKey];

        // Custom initialization
        self.title = @"Image Targets";

        // get whether the user opted to show the device icon
        bool showDevicesIcon = [[self.overlayOptions objectForKey:@"showDevicesIcon"] integerValue];

        // Create the EAGLView with the screen dimensions
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        viewFrame = screenBounds;

        // If this device has a retina display, scale the view bounds that will
        // be passed to QCAR; this allows it to calculate the size and position of
        // the viewport correctly when rendering the video background
        if (YES == vapp.isRetinaDisplay) {
            viewFrame.size.width *= 2.0;
            viewFrame.size.height *= 2.0;
        }

        dataSetCurrent = nil;
        extendedTrackingIsOn = NO;

        // a single tap will trigger a single autofocus operation
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autofocus:)];

        // we use the iOS notification to pause/resume the AR when the application goes (or come back from) background

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(pauseAR)
         name:UIApplicationWillResignActiveNotification
         object:nil];

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(resumeAR)
         name:UIApplicationDidBecomeActiveNotification
         object:nil];

        // set up the overlay back bar
        UIView *vuforiaBarView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 75)];
        vuforiaBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        vuforiaBarView.tag = 8;
        [self.view addSubview:vuforiaBarView];

        // set up the close button
        UIImage * buttonImage = [UIImage imageNamed:@"close-button.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"" forState:UIControlStateNormal];
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 65, (vuforiaBarView.frame.size.height / 2.0) - 30, 60, 60);
        button.tag = 10;
        [vuforiaBarView addSubview:button];

        // if the device logo is set by the user
        if(showDevicesIcon) {
            UIImage *image = [UIImage imageNamed:@"iOSDevices.png"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(10, (vuforiaBarView.frame.size.height / 2.0) - 25, 50, 50);
            imageView.tag = 11;
            [vuforiaBarView addSubview:imageView];
        }

        // set up the detail label
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, vuforiaBarView.frame.size.width / 2 - button.frame.size.width, 60)];
        [detailLabel setTextColor:[UIColor colorWithRed:0.74 green:0.74 blue:0.74 alpha:1.0]];
        [detailLabel setBackgroundColor:[UIColor clearColor]];
        [detailLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 15.0f]];

        // get and set the overlay text (if passed by user). if the text is empty, make the back bar transparent
        NSString *overlayText = [self.overlayOptions objectForKey:@"overlayText"];

        [detailLabel setText: overlayText];
        detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        detailLabel.numberOfLines = 0;
        detailLabel.tag = 9;
        [detailLabel sizeToFit];
        if([overlayText length] == 0) {
            vuforiaBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0f];
        }

        // if the device icon is to be shown, adapt the text to fit.
        CGRect detailFrame = detailLabel.frame;
        if(showDevicesIcon) {
            detailFrame = CGRectMake(70, 10, [[UIScreen mainScreen] bounds].size.width - 130, detailLabel.frame.size.height);
        }
        else {
            detailFrame = CGRectMake(20, 10, [[UIScreen mainScreen] bounds].size.width - 130, detailLabel.frame.size.height);
        }
        detailLabel.frame = detailFrame;
        [detailLabel sizeToFit];
        [vuforiaBarView addSubview:detailLabel];

        if(detailLabel.frame.size.height > button.frame.size.height) {
            CGRect vuforiaFrame = vuforiaBarView.frame;
            vuforiaFrame.size.height = detailLabel.frame.size.height + 25;
            vuforiaBarView.frame = vuforiaFrame;

            CGRect buttonFrame = button.frame;
            buttonFrame.origin.y = detailLabel.frame.size.height / 3.0;
            button.frame = buttonFrame;

            if(showDevicesIcon) {
                UIImageView *imageView = (UIImageView *)[eaglView viewWithTag:11];
                CGRect imageFrame = imageView.frame;
                imageFrame.origin.y = detailLabel.frame.size.height / 3.0;
                imageView.frame = imageFrame;
            }
        }
    }
    return self;
}

-(void)buttonPressed {

    [self doStopTrackers];
    NSLog(@"Vuforia Plugin :: button pressed!!!");
    NSDictionary* userInfo = @{@"status": @{@"manuallyClosed": @true, @"message": @"User manually closed the plugin."}};

    [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseRequest" object:self userInfo:userInfo];
}


- (BOOL)shouldAutorotate {
    return NO;
}

- (void) pauseAR {
    NSError * error = nil;
    if (![vapp pauseAR:&error]) {
        NSLog(@"Error pausing AR:%@", [error description]);
    }
}

- (void) resumeAR {
    NSError * error = nil;
    if(! [vapp resumeAR:&error]) {
        NSLog(@"Error resuming AR:%@", [error description]);
    }
    // on resume, we reset the flash and the associated menu item
    QCAR::CameraDevice::getInstance().setFlashTorchMode(false);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tapGestureRecognizer release];

    [vapp release];
    [eaglView release];

    [super dealloc];
}

- (void)loadView
{
    // Create the EAGLView
    eaglView = [[ImageTargetsEAGLView alloc] initWithFrame:viewFrame appSession:vapp];
    [self setView:eaglView];
    self.glResourceHandler = eaglView;

    // show loading animation while AR is being initialized
    [self showLoadingAnimation];

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [vapp initAR:QCAR::GL_20 ARViewBoundsSize:viewFrame.size orientation:orientation];

    [self performSelector:@selector(test) withObject:nil afterDelay:.5];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view addGestureRecognizer:tapGestureRecognizer];

    NSLog(@"self.navigationController.navigationBarHidden: %s", self.navigationController.navigationBarHidden ? "Yes" : "No");

}

- (void)viewWillDisappear:(BOOL)animated {

    [self stopVuforia];

    // Be a good OpenGL ES citizen: now that QCAR is paused and the render
    // thread is not executing, inform the root view controller that the
    // EAGLView should finish any OpenGL ES commands
    [eaglView finishOpenGLESCommands];
    [eaglView freeOpenGLESResources];

    self.glResourceHandler = nil;

    [super viewWillDisappear:animated];
}

- (void)finishOpenGLESCommands
{
    // Called in response to applicationWillResignActive.  Inform the EAGLView
    [eaglView finishOpenGLESCommands];
}


- (void)freeOpenGLESResources
{
    // Called in response to applicationDidEnterBackground.  Inform the EAGLView
    [eaglView freeOpenGLESResources];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - loading animation

- (void) showLoadingAnimation {
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    CGRect indicatorBounds = CGRectMake(mainBounds.size.width / 2 - 12,
                                        mainBounds.size.height / 2 - 12, 24, 24);
    UIActivityIndicatorView *loadingIndicator = [[[UIActivityIndicatorView alloc]
                                                  initWithFrame:indicatorBounds]autorelease];

    loadingIndicator.tag  = 1;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [eaglView addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
}

-(void) positionLoadingAnimation {

}

- (void) hideLoadingAnimation {
    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[eaglView viewWithTag:1];
    [loadingIndicator removeFromSuperview];
}


#pragma mark - ApplicationControl

- (bool) doInitTrackers {
    // Initialize the image or marker tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();

    // Image Tracker...
    QCAR::Tracker* trackerBase = trackerManager.initTracker(QCAR::ObjectTracker::getClassType());
    if (trackerBase == NULL)
    {
        NSLog(@"Failed to initialize ObjectTracker.");
        return false;
    }
    NSLog(@"Successfully initialized ObjectTracker.");
    return true;
}

- (bool) doLoadTrackersData {

    NSLog(@"Vuforia Plugin :: imageTargetFile = %@", self.imageTargetFile);
    dataSetTargets = [self loadObjectTrackerDataSet:self.imageTargetFile];
    if (dataSetTargets == NULL) {
        NSLog(@"Failed to load datasets");
        return NO;
    }
    if (! [self activateDataSet:dataSetTargets]) {
        NSLog(@"Failed to activate dataset");
        return NO;
    }


    return YES;
}

- (bool) doStartTrackers {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ObjectTracker::getClassType());
    if(tracker == 0) {
        return NO;
    }

    tracker->start();
    return YES;
}

// callback: the AR initialization is done
- (void) onInitARDone:(NSError *)initError {
    [self hideLoadingAnimation];

    if (initError == nil) {

        NSError * error = nil;
        [vapp startAR:QCAR::CameraDevice::CAMERA_BACK error:&error];

        // by default, we try to set the continuous auto focus mode
    } else {
        NSLog(@"Error initializing AR:%@", [initError description]);
        dispatch_async( dispatch_get_main_queue(), ^{

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[initError localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kMenuDismissViewController" object:nil];
}



//	Update function called while camera is tracking images
- (void) onQCARUpdate: (QCAR::State *) state {

    for (int i = 0; i < state->getNumTrackableResults(); ++i) {

        const QCAR::TrackableResult* result = state->getTrackableResult(i);
        const QCAR::Trackable& trackable = result->getTrackable();


        for(NSString *imageName in self.imageTargetNames) {
            //	Check if matched target is matched
            if (!strcmp(trackable.getName(), imageName.UTF8String))
            {
                [self doStopTrackers];
                NSLog(@"Vuforia Plugin :: image found!!!");
                NSDictionary* userInfo = @{@"status": @{@"imageFound": @true, @"message": @"Image Found."}, @"result": @{@"imageName": imageName}};

                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSLog(@"Vuforia Plugin :: messaged dispatched!!!");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageMatched" object:self userInfo:userInfo];
                });
            }
        }
    }
}


// Load the image tracker data set
- (QCAR::DataSet *)loadObjectTrackerDataSet:(NSString*)dataFile
{
    NSLog(@"loadObjectTrackerDataSet (%@)", dataFile);
    QCAR::DataSet * dataSet = NULL;

    // Get the QCAR tracker manager image tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* objectTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));

    if (NULL == objectTracker) {
        NSLog(@"ERROR: failed to get the ObjectTracker from the tracker manager");
        return NULL;
    } else {
        dataSet = objectTracker->createDataSet();

        if (NULL != dataSet) {
            NSLog(@"INFO: successfully loaded data set");

            //Determine the storage type.
            QCAR::STORAGE_TYPE storageType;
            if([dataFile hasPrefix:@"file://"]) {
                dataFile = [dataFile stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                storageType = QCAR::STORAGE_ABSOLUTE;
                NSLog(@"Reading the absolute path to target file : %@", dataFile);

            }else{
                NSLog(@"Reading the path to target file %@ from resources folder", dataFile);
                storageType = QCAR::STORAGE_APPRESOURCE;
            }

            // Load the data set from the app's resources location
            if (!dataSet->load([dataFile cStringUsingEncoding:NSASCIIStringEncoding], storageType)) {
                NSLog(@"ERROR: failed to load data set");
                objectTracker->destroyDataSet(dataSet);
                dataSet = NULL;
            }
        }
        else {
            NSLog(@"ERROR: failed to create data set");
        }
    }

    return dataSet;
}


- (bool) doStopTrackers {
    // Stop the tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ObjectTracker::getClassType());

    if (NULL != tracker) {
        tracker->stop();
        NSLog(@"INFO: successfully stopped tracker");
        return YES;
    }
    else {
        NSLog(@"ERROR: failed to get the tracker from the tracker manager");
        return NO;
    }
}

- (bool) doUnloadTrackersData {
    [self deactivateDataSet: dataSetCurrent];
    dataSetCurrent = nil;

    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* objectTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));

    // Destroy the data sets:
    if (!objectTracker->destroyDataSet(dataSetTargets))
    {
        NSLog(@"Failed to destroy data set.");
    }

    NSLog(@"datasets destroyed");
    return YES;
}

- (BOOL)activateDataSet:(QCAR::DataSet *)theDataSet
{
    // if we've previously recorded an activation, deactivate it
    if (dataSetCurrent != nil)
    {
        [self deactivateDataSet:dataSetCurrent];
    }
    BOOL success = NO;

    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* objectTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));

    if (objectTracker == NULL) {
        NSLog(@"Failed to load tracking data set because the ObjectTracker has not been initialized.");
    }
    else
    {
        // Activate the data set:
        if (!objectTracker->activateDataSet(theDataSet))
        {
            NSLog(@"Failed to activate data set.");
        }
        else
        {
            NSLog(@"Successfully activated data set.");
            dataSetCurrent = theDataSet;
            success = YES;
        }
    }

    // we set the off target tracking mode to the current state
    if (success) {
        [self setExtendedTrackingForDataSet:dataSetCurrent start:extendedTrackingIsOn];
    }

    return success;
}

- (BOOL)deactivateDataSet:(QCAR::DataSet *)theDataSet
{
    if ((dataSetCurrent == nil) || (theDataSet != dataSetCurrent))
    {
        NSLog(@"Invalid request to deactivate data set.");
        return NO;
    }

    BOOL success = NO;

    // we deactivate the enhanced tracking
    [self setExtendedTrackingForDataSet:theDataSet start:NO];

    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* objectTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));

    if (objectTracker == NULL)
    {
        NSLog(@"Failed to unload tracking data set because the ObjectTracker has not been initialized.");
    }
    else
    {
        // Activate the data set:
        if (!objectTracker->deactivateDataSet(theDataSet))
        {
            NSLog(@"Failed to deactivate data set.");
        }
        else
        {
            success = YES;
        }
    }

    dataSetCurrent = nil;

    return success;
}

- (BOOL) setExtendedTrackingForDataSet:(QCAR::DataSet *)theDataSet start:(BOOL) start {
    BOOL result = YES;
    for (int tIdx = 0; tIdx < theDataSet->getNumTrackables(); tIdx++) {
        QCAR::Trackable* trackable = theDataSet->getTrackable(tIdx);
        if (start) {
            if (!trackable->startExtendedTracking())
            {
                NSLog(@"Failed to start extended tracking on: %s", trackable->getName());
                result = false;
            }
        } else {
            if (!trackable->stopExtendedTracking())
            {
                NSLog(@"Failed to stop extended tracking on: %s", trackable->getName());
                result = false;
            }
        }
    }
    return result;
}

- (bool) doDeinitTrackers {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    trackerManager.deinitTracker(QCAR::ObjectTracker::getClassType());
    return YES;
}

- (void)autofocus:(UITapGestureRecognizer *)sender
{
    [self performSelector:@selector(cameraPerformAutoFocus) withObject:nil afterDelay:.4];
}

- (void)cameraPerformAutoFocus
{
    QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_TRIGGERAUTO);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    bool showDevicesIcon = [[self.overlayOptions objectForKey:@"showDevicesIcon"] integerValue];

    // Code here will execute before the rotation begins.
    // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if(!self.delaying){
            //[self stopVuforia];
            [vapp pauseAR:nil];

            [self showLoadingAnimation];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if(!self.delaying) {
            self.delaying = true;

            [self performSelector:@selector(startVuforia) withObject:nil afterDelay:1];
        }

        CGRect mainBounds = [[UIScreen mainScreen] bounds];

        UIView *vuforiaBarView = (UIView *)[eaglView viewWithTag:8];

        UIButton *closeButton = (UIButton *)[eaglView viewWithTag:10];
        UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[eaglView viewWithTag:1];

        UILabel *detailLabel = (UILabel *)[eaglView viewWithTag:9];
        UIActivityIndicatorView *labelLoadingIndicator = (UIActivityIndicatorView *)[eaglView viewWithTag:1];

        [UIView animateWithDuration:0.33 animations:^{

            // handle close button location
            CGRect closeRect = closeButton.frame;
            closeRect.origin.x = [[UIScreen mainScreen] bounds].size.width - 65;
            closeButton.frame = closeRect;

            // if the device icon is to be shown, adapt the text to fit.
            CGRect detailFrame = detailLabel.frame;
            if(showDevicesIcon) {
                detailFrame = CGRectMake(70, 10, [[UIScreen mainScreen] bounds].size.width - 130, detailLabel.frame.size.height);
            }
            else {
                detailFrame = CGRectMake(20, 10, [[UIScreen mainScreen] bounds].size.width - 130, detailLabel.frame.size.height);
            }
            detailLabel.frame = detailFrame;
            [detailLabel sizeToFit];
            [vuforiaBarView addSubview:detailLabel];

            CGRect vuforiaFrame = vuforiaBarView.frame;
            vuforiaFrame.size.height = detailLabel.frame.size.height + 25;
            vuforiaBarView.frame = vuforiaFrame;

            if(detailLabel.frame.size.height > closeButton.frame.size.height) {
                CGRect buttonFrame = closeButton.frame;
                buttonFrame.origin.y = detailLabel.frame.size.height / 3.0;
                closeButton.frame = buttonFrame;
            }
            else {
                // handle close button location
                CGRect closeRect = closeButton.frame;
                closeRect.origin.y = 5;
                closeButton.frame = closeRect;

                // handle case where text is short
                vuforiaFrame.size.height = 75;
                vuforiaBarView.frame = vuforiaFrame;
            }

            // handle showDevicesIcon if it exists
            if(showDevicesIcon) {
                UIImageView *imageView = (UIImageView *)[eaglView viewWithTag:11];
                CGRect imageFrame = imageView.frame;
                imageFrame.origin.y = detailLabel.frame.size.height / 3.0;
                imageView.frame = imageFrame;
            }
        }];


    }];
}

- (void)stopVuforia
{
    //[vapp pauseAR:nil];

    [vapp stopAR:nil];
    // Be a good OpenGL ES citizen: now that QCAR is paused and the render
    // thread is not executing, inform the root view controller that the
    // EAGLView should finish any OpenGL ES commands
    [eaglView finishOpenGLESCommands];
    [eaglView freeOpenGLESResources];

    self.glResourceHandler = nil;

}

-(void)startVuforia
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    // Frames from the camera are always landscape, no matter what the
    // orientation of the device.  Tell QCAR to rotate the video background (and
    // the projection matrix it provides to us for rendering our augmentation)
    // by the proper angle in order to match the EAGLView orientation
    if (orientation == UIInterfaceOrientationPortrait)
    {
        QCAR::setRotation(QCAR::ROTATE_IOS_90);
    }
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        QCAR::setRotation(QCAR::ROTATE_IOS_270);
    }
    else if (orientation == UIInterfaceOrientationLandscapeLeft)
    {
        QCAR::setRotation(QCAR::ROTATE_IOS_180);
    }
    else if (orientation == UIInterfaceOrientationLandscapeRight)
    {
        QCAR::setRotation(1);
    }


    // initialize the AR session
    //[vapp initAR:QCAR::GL_20 ARViewBoundsSize:viewFrame.size orientation:orientation];
    [vapp resumeAR:nil];

    [self performSelector:@selector(test) withObject:nil afterDelay:.5];
}

-(void)test
{
    self.delaying = false;

    [self hideLoadingAnimation];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end