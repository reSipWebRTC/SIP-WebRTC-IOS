
#import <Foundation/Foundation.h>
#import "cdr_database.h"

@interface UserCallReportUtil : NSObject

+(UserCallReportUtil*) instance;

-(CdrDatabase *)getCdrDatabase;

-(void)readCdrDatabase;

@end
