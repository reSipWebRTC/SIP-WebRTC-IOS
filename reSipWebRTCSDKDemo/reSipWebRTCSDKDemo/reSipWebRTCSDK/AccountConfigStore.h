#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Light-weight persistent store for user settings.
 *
 * It will persist between application launches and application updates.
 */
@interface AccountConfigStore : NSObject

/**
 * Set fallback values in case the setting has not been written by the user.
 */
+ (void)setDefaultsForAccountConfig:(NSString *)username
                             authname:(NSString *)authname
                             password:(NSString *)password
                               server:(NSString *)server
                                proxy:(NSString *)proxy
                         displayname:(NSString *)displayname;

@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *displayname;
@property(nonatomic, strong) NSString *authname;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, strong) NSString *domain;
@property(nonatomic, strong) NSString *server;
@property(nonatomic, strong) NSString *proxy;
@property(nonatomic, strong) NSString *realm;
//@property(nonatomic) SipTransportType trans_type;

@end
NS_ASSUME_NONNULL_END
