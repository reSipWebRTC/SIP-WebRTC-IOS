#import "AccountConfig.h"

@implementation AccountConfig {
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

@end
