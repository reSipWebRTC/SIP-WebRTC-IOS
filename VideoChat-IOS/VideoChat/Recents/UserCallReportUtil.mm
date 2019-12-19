
#import "UserCallReportUtil.h"
#import "CommonTypes.h"

static UserCallReportUtil *the_instance_ = nil;
static CdrDatabase cdr_db_;

@implementation UserCallReportUtil

+(UserCallReportUtil*) instance
{
    @synchronized(the_instance_)
    {
        if (!the_instance_) {
            the_instance_ = [[UserCallReportUtil alloc] init];
        }
        return the_instance_;
    }
}


-(CdrDatabase *)getCdrDatabase
{
    return &cdr_db_;
}

-(void)readCdrDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    if(path)
    {
        NSString *full_path = [[NSString alloc] initWithFormat:@"%@/%s",path,DEFAULT_USERDB_NAME];
        if(cdr_db_.open_db([full_path UTF8String]) == 0)
        {
            IVLog(@"Open Cdr DB: %@",full_path);
        }
    }
}

@end
