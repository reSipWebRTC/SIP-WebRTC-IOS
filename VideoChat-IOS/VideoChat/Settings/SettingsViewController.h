
#import <UIKit/UIKit.h>
#import "IASKAppSettingsViewController.h"

@interface SettingsViewController : UIViewController<IASKSettingsDelegate, UIPopoverControllerDelegate, UITextViewDelegate>
{
    BOOL settting_changed_;
}
@property (strong, nonatomic) IASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic, retain) UINavigationController *navigationController;
@end
