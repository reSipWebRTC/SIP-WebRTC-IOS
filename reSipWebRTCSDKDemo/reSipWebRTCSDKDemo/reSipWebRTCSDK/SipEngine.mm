
#import "SipEngine.h"

BOOL Initialized_;

static SipEngine *the_instance_ = NULL;

@implementation SipEngine {
}

@synthesize rtcSipEngine = _rtcSipEngine;

+(SipEngine *)instance
{
    if(the_instance_ == NULL)
    {
        the_instance_ = [[SipEngine alloc] init];
    }
    
    return the_instance_;
}

- (id)init
{
    if ((self = [super init])) {
       _rtcSipEngine = [[RTCSipEngine alloc] init];
    }
    return self;
}

- (int)Initialize{
    return 0;
}
    
- (void)Terminate{
    
}
    
- (CallManager*)getCallManager{
    return [CallManager instance];
}
    
- (RegistrationManager*)getRegistrationManager{
    return [RegistrationManager instance];
}

@end
