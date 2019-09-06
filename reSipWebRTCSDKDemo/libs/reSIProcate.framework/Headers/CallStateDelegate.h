//
//  RTCCallStateDelegate.h
//  VideoChat
//

#ifndef CallStateDelegate_h
#define CallStateDelegate_h

#import <Foundation/Foundation.h>

@protocol CallStateDelegate<NSObject>

-(void)OnIncomingCall:(int)accId callId:(int)callId caller:(NSString*)caller;

-(void)OnCallOffer:(int)callId remoteSdp:(NSString*)sdp;

-(void)OnCallAnswer:(int)callId remoteSdp:(NSString*)sdp;

-(void)OnCallStateChange:(int)callId
                     state_code:(int)code reason:(NSString*)reason;

-(void)OnDtmfEvent:(int)callId dtmf:(int)dtmf duration:(int)duration up:(int)up;

@end
#endif /* CallStateDelegate_h */
