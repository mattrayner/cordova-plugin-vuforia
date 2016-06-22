#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (retain, nonatomic) NSDictionary *imageTargets;
@property (retain, nonatomic) NSDictionary *overlayOptions;
@property (retain, nonatomic) NSString *overlayText;
@property (retain, nonatomic) NSString *vuforiaLicenseKey;

-(id)initWithFileName:(NSString *)fileName targetNames:(NSArray *)imageTargetNames overlayOptions:(NSString *)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey;

@end
