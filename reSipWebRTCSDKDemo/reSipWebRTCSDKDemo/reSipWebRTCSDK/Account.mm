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
    [registrationManager registerAccount:self];
}

- (NSInteger)getAccId
{
    return _accId;
}

- (void)unregister: (int)accId {
    [registrationManager makeDeRegister:accId];
    [registrationManager unregisterAccount:self];
}
    
- (void)refreshRegistration: (int)accId {
    [registrationManager refreshRegistration:accId];
}

@end
