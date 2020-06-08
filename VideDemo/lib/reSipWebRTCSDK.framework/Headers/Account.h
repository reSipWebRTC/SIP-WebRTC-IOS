#import <Foundation/Foundation.h>
#import "AccountConfig.h"

@interface Account : NSObject

- (void)register:(AccountConfig *)accountConfig;
- (void)unregister;
- (int)getAccId;
- (void)refreshRegister;

@property(nonatomic) int accId;

@end
