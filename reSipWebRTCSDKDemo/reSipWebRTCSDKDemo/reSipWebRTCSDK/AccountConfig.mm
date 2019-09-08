
#import "AccountConfig+Private.h"
#import "AccountConfigStore.h"

@implementation AccountConfig {
   AccountConfigStore * _accountConfigStore;
}

@synthesize username = _username;
@synthesize display_name =_display_name;
@synthesize auth_name = _auth_name;
@synthesize password = _password;
@synthesize domain = _domain;
@synthesize server = _server;
@synthesize proxy = _proxy;
@synthesize realm = _realm;
@synthesize trans_type =_trans_type;

- (id)init
{
    if ((self = [super init])) {
        self->_username = nullptr;
        self->_display_name = nullptr;
        self->_auth_name = nullptr;
        self->_password = nullptr;
        self->_domain = nullptr;
        self->_proxy = nullptr;
        self->_realm = nullptr;
        self->_trans_type = kTCP;
    }
    return self;
}

- (AccountConfigStore *)callConfigStore {
    if (!_accountConfigStore) {
        _accountConfigStore = [[AccountConfigStore alloc] init];
        [self registerStoreDefaults];
    }
    return _accountConfigStore;
}

- (void)registerStoreDefaults {
    [AccountConfigStore setDefaultsForAccountConfig:@"" authname:@"" password:@"" server:@"" proxy:@"" displayname:@""];
}

@end
