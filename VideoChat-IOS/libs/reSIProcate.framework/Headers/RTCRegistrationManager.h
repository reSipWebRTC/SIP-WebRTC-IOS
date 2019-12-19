
#import <Foundation/Foundation.h>
//#import "RTCMacros.h"

#import "RegistrationStateDelegate.h"

@class RTCSipEngine;

//RTC_OBJC_EXPORT

@interface RTCRegistrationManager : NSObject
    
@property(nonatomic, weak) id<RegistrationStateDelegate> delegate;
    
- (int)MakeRegister: (NSString *)username
            authname:(NSString *)authname
            password:(NSString *)password
              server:(NSString *)server
               proxy:(NSString *)proxy
           transport:(NSString *)transport
              expire:(NSInteger)expire
        display_name:(NSString *)displayname;

- (void)MakeDeRegister: (int)accId;
- (void)RefreshRegistration: (int)accId;
- (void)RegisterRegistrationDelegate: (id<RegistrationStateDelegate>)delegate;
- (void)DeRegisterRegistrationDelegate;
- (void)SetNetworkReachable: (BOOL)yesno;

@end
