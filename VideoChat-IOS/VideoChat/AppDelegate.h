
#import <UIKit/UIKit.h>
#import <reSipWebRTCSDK/SipEngineManager.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) Account *current_account;
@property (nonatomic,retain) CallParams *callParams;

-(void)loadConfig;

@end
