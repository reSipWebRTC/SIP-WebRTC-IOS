//
//  RTCCallStateDelegate.h
//  VideoChat
//

#ifndef CallStateDelegate_h
#define CallStateDelegate_h

#import <Foundation/Foundation.h>

@protocol CallStateDelegate<NSObject>

-(void)OnIncomingCall:(int)accId callId:(int)callId
               callerDisplayName:(NSString*)callerDisplayName
            callerUri:(NSString*)callerUri;

-(void)OnCallOffer:(int)callId remoteSdp:(NSString*)sdp
         audioCall:(BOOL)audioCall videoCall:(BOOL)videoCall;

-(void)OnCallAnswer:(int)callId remoteSdp:(NSString*)sdp;

-(void)OnCallStateChange:(int)callId
                     state_code:(int)code reason:(NSString*)reason;

-(void)OnDtmfEvent:(int)callId dtmf:(int)dtmf duration:(int)duration up:(int)up;

-(void)OnInfoEvent:(int)callId remoteInfo:(NSString*)info;

-(void)OnMediaStateChange:(int)callId audio:(bool)audio video:(bool)video;

@end
#endif /* CallStateDelegate_h */
