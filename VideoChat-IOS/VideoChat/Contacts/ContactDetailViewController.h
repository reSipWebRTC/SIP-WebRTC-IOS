
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "UserContactUtil.h"

@interface ContactDetailViewController : UIViewController <MFMessageComposeViewControllerDelegate>


@property (nonatomic) Contact* contact;

@end
