
#import <Foundation/Foundation.h>

@protocol RegistrationStateDelegate<NSObject>

-(void) OnRegistrationProgress:(int)accId;

-(void) OnRegistrationSucess:(int)accId;

-(void) OnRegistrationCleared:(int)accId;

-(void) OnRegisterationFailed:(int)accId
                withErrorCode:(int)code
              withErrorReason:(NSString *)reason;

@end
