#import <Foundation/Foundation.h>
#import <reSIProcate/CallStateDelegate.h>
#import "Call.h"
#import "SipEngineDelegate.h"
#import <WebRTC/RTCPeerConnectionFactory.h>

@interface CallManager : NSObject<CallStateDelegate>

@property(nonatomic, strong) RTCPeerConnectionFactory *factory;

@property(nonatomic, weak) id<SipEngineUICallDelegate> callDelegate;
    
+(CallManager *)instance;

- (Call*)createCall:(int)accId;
- (void)makeCall:(int)accId callId:(int)callId
      calleeUri:(NSString *)calleeUri  offersdp:(NSString*)sdp;
- (void)accept:(int)callId answersdp:(NSString* )sdp;
- (void)update:(int)callId localsdp:(NSString* )sdp;
- (void)hangup:(int)callId;
- (void)reject:(int)callId;
- (void)registerCall:(Call *)call;
- (void)unregisterCall:(Call *)call;
- (void)sendDtmfDigits:(int)callId digits:(NSString*)digits;
- (void)changeMediaState:(int)callId audio:(BOOL)audio video:(BOOL)video;
- (void)registerUICallStateDelegate: (id<SipEngineUICallDelegate>)delegate;

@end
