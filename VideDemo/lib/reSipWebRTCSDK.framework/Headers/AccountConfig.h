#import <Foundation/Foundation.h>

typedef enum {
    kUDP = 0,
    kTCP,
    kTLS
} SipTransportType;

@interface AccountConfig : NSObject

@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *display_name;
@property(nonatomic, strong) NSString *auth_name;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, strong) NSString *domain;
@property(nonatomic, strong) NSString *server;
@property(nonatomic, strong) NSString *proxy;
@property(nonatomic, strong) NSString *realm;
@property(nonatomic) SipTransportType trans_type;

@end
