#import <Foundation/Foundation.h>
#import "AccountConfig.h"

@interface Account : NSObject

//- (instancetype)initWithAccountConfig:(AccountConfig *)accountConfig;

- (void)register:(AccountConfig *)accountConfig;
- (void)unregister: (int)accId;
- (void)refreshRegistration: (int)accId;

@property(nonatomic) int accId;

@end
