#import <Foundation/Foundation.h>
//#import "RTCMacros.h"

#import "CallStateDelegate.h"

@class RTCSipEngine;

//RTC_OBJC_EXPORT

@interface RTCCallManager : NSObject
    
@property(nonatomic, weak) id<CallStateDelegate> delegate;
    
- (int)CreateCall:(int)accId;
- (void)MakeCall:(int)accId callId:(int)callId peerNumber:(NSString *)peerNumber  offersdp:(NSString*)sdp;
- (void)Accept:(int)callId answersdp:(NSString* )sdp;
- (void)Hangup:(int)callId;
- (void)Reject:(int)callId;
- (void)SendDtmfDigits:(int)callId digits:(NSString*)digits;
- (void)RegisterCallStateDelegate:(id<CallStateDelegate>)delegate;

@end
