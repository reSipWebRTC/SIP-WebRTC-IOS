
#import "RegistrationManager.h"
#import "SipEngineManager.h"
#import <reSIProcate/RTCRegistrationManager.h>

static RegistrationManager *the_registrationManager_ = NULL;

@implementation RegistrationManager {
    RTCRegistrationManager *rtcRegistrationManager;
}

@synthesize registrationDelegate = _registrationDelegate;

+(RegistrationManager *)instance
{
        if(the_registrationManager_ == NULL)
        {
            the_registrationManager_ = [[RegistrationManager alloc] init];
        }
        
        return the_registrationManager_;
}
    
- (id)init {
    if ((self = [super init])) {
        rtcRegistrationManager = [[[SipEngineManager instance] getSipEngine].rtcSipEngine GetRegistrationManager];
        [rtcRegistrationManager RegisterRegistrationDelegate:self];
    }
    
    return self;
}

-(Account*)createAccount{
    Account* account = [[Account alloc]init];
    return account;
}
    
- (int)makeRegister: (AccountConfig *)accountConfig {
    NSString *username = accountConfig.username;
    NSString *authname = accountConfig.auth_name;
    NSString *password = accountConfig.password;
    NSString *server = accountConfig.server;
    NSString *proxy = accountConfig.proxy;
    NSString *transport = @"tcp";
    //NSInteger expire = accountConfig.ex
    NSString *displayname = accountConfig.display_name;
    
    return [rtcRegistrationManager MakeRegister:username authname:authname password:password server:server proxy:proxy transport:transport expire:3600 display_name:displayname];
    
}
    
- (void)makeDeRegister: (int)accId {
    if(rtcRegistrationManager != NULL)
       [rtcRegistrationManager MakeDeRegister:accId];
}
    
- (void)refreshRegistration: (int)accId {
    if(rtcRegistrationManager != NULL)
        [rtcRegistrationManager RefreshRegistration:accId];
}
    
- (void)registerUIRegistrationDelegate: (id<SipEngineUIRegistrationDelegate>)delegate {
    _registrationDelegate = delegate;
}
    
- (void)deRegisterRegistrationDelegate {
    
}
    
- (void)setNetworkReachable: (BOOL)yesno {
    
}

- (void)OnRegistrationProgress:(int)accId {
    
}

- (void)OnRegistrationSucess:(int)accId {
    if(_registrationDelegate != nullptr)
       [_registrationDelegate OnRegistrationSucess:nullptr];
}

- (void)OnRegisterationFailed:(int)accId withErrorCode:(int)code withErrorReason:(NSString *)reason {
     NSLog(@"=====OnRegisterationFailed======");
}

- (void)OnRegistrationCleared:(int)accId {
    
}

@end
