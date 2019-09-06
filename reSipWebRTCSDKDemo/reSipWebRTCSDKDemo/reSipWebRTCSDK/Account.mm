#import "Account.h"
#import "RegistrationManager.h"

@implementation Account {
    RegistrationManager* registrationManager;
    AccountConfig* _accountConfig;
}

@synthesize accId = _accId;

- (id)init
{
    if ((self = [super init])) {
        self->registrationManager = [RegistrationManager instance];
        self->_accId = -1;
    }
    return self;
}

- (void)register:(AccountConfig *)accountConfig {
    self->_accountConfig = accountConfig;
    int acc_Id = [registrationManager makeRegister:self->_accountConfig];
    self->_accId = acc_Id;
}
    
- (void)unregister: (int)accId {
    [registrationManager makeDeRegister:accId];
}
    
- (void)refreshRegistration: (int)accId {
    [registrationManager refreshRegistration:accId];
}

@end
