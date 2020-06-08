#import <Foundation/Foundation.h>
#import <reSIProcate/RegistrationStateDelegate.h>
#import "Account.h"
#import "SipEngineDelegate.h"
#import <reSIProcate/RTCRegistrationManager.h>

@interface RegistrationManager : NSObject<RegistrationStateDelegate>
    
@property(nonatomic, weak) id<SipEngineUIRegistrationDelegate> registrationDelegate;
 
+(RegistrationManager *)instance;

- (instancetype)initWithRtcRegistrationManager:(RTCRegistrationManager *)registrationManager;

- (Account*)createAccount;
- (int)makeRegister: (AccountConfig *)accountConfig;
- (void)makeDeRegister: (int)accId;
- (void)registerAccount: (Account *)account;
- (void)unregisterAccount: (Account *)account;
- (void)refreshRegistration: (int)accId;
- (void)registerUIRegistrationDelegate: (id<SipEngineUIRegistrationDelegate>)delegate;
- (void)deRegisterRegistrationDelegate;
- (void)setNetworkReachable: (BOOL)yesno;
    
@end
