#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (retain, nonatomic) NSDictionary *imageTargets;
@property (retain, nonatomic) NSString *overlayText;
@property (retain, nonatomic) NSString *vuforiaLicenseKey;

-(id)initWithFileName:(NSString *)fileName targetNames:(NSArray *)imageTargetNames customOverlayText:(NSString *)overlayText vuforiaLicenseKey:(NSString *)vuforiaLicenseKey;

@end

