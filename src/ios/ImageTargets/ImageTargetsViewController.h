/*===============================================================================
 Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States
 and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
 ===============================================================================*/

#import <UIKit/UIKit.h>
#import "ImageTargetsEAGLView.h"
#import "ApplicationSession.h"
#import <QCAR/DataSet.h>

@interface ImageTargetsViewController : UIViewController <ApplicationControl>{
    CGRect viewFrame;
    ImageTargetsEAGLView* eaglView;
    QCAR::DataSet*  dataSetCurrent;
    QCAR::DataSet*  dataSetTargets;
    UITapGestureRecognizer * tapGestureRecognizer;
    ApplicationSession * vapp;
    
    BOOL switchToTarmac;
    BOOL switchToStonesAndChips;
    BOOL extendedTrackingIsOn;
    
}


@property (retain) NSString *imageTargetFile;
@property (retain) NSArray *imageTargetNames;
@property (retain) NSString *overlayText;
@property (retain) NSString *vuforiaLicenseKey;

@property (nonatomic) bool delaying;

- (id)initWithOverlayText:(NSString *)overlayText vuforiaLicenseKey:(NSString *)vuforiaLicenseKey;

@end
