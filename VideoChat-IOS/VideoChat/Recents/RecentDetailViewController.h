
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "UserContactUtil.h"
#import "UserCallReportUtil.h"

@interface RecentDetailViewController : UIViewController <MFMessageComposeViewControllerDelegate>


@property (nonatomic) Contact* contact;
@property (nonatomic) call_report_t *cdr;

@end
