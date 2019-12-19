
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <reSipWebRTCSDK/SipEngineManager.h>

@class CallingScreenViewController;

@interface KeyPadViewController : UIViewController <SipEngineUICallDelegate, SipEngineUIRegistrationDelegate,UITextFieldDelegate,UIActionSheetDelegate,ABNewPersonViewControllerDelegate>
{
    IBOutlet UILabel *mStatusLabel;
}

@property(nonatomic) CallingScreenViewController *calling_screen_view;


+(KeyPadViewController *)instance;

-(void)showCallingViewController:(BOOL)video_call
                     playRinging:(BOOL)yesno;

-(void)newOutgoingCall:(Call *)call video_call:(BOOL)video_call;

-(void)setCallingNumber:(NSString *)number;

@end
