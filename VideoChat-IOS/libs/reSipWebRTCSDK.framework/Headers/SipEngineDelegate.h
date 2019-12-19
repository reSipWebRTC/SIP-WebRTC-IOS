/*
 *  SipEngineUIDelegate.h
 *  MicroVoice
 *
 */

#import <UIKit/UIKit.h>

#include "Call.h"
#include "Account.h"

/*通话状态回调*/
@protocol SipEngineUICallDelegate

-(void)OnNewIncomingCall:(Call*)call
                caller:(NSString*)caller
               video_call:(BOOL)video_call;

-(void)OnNewOutgoingCall:(Call*)call
                caller:(NSString*)caller
              video_call:(BOOL)video_call;

/*外呼正在处理*/
- (void)OnCallProcessing:(Call*)call;

/*对方振铃*/
- (void)OnCallRinging:(Call*)call;

/*呼叫接通*/
- (void)OnCallConnected:(Call*)call
       withVideoChannel:(BOOL)video_enabled
        withDataChannel:(BOOL)data_enabled;

/*呼叫保持*/
- (void)OnCallPaused:(Call*)call;
/*通话恢复*/
- (void)OnCallResume:(Call*)call;
/*呼叫结束*/
- (void)OnCallEnded:(Call*)call;

/*接到视频通话邀请*/
- (void)UpdatedByRemote:(Call *)call
              has_video:(BOOL)video;
/*主动发起视频，返回结果*/
- (void)UpdatedByLocal:(Call *)call
             has_video:(BOOL)video;

- (void)OnCallFailed:(Call*)call
       withErrorCode:(int)error_code
       reason:(NSString*)reason;

-(void)OnDtmfEvent:(int)callId
              dtmf:(int)dtmf
          duration:(int)duration
                up:(int)up;

@end

/*视频状态回调*/
@protocol VideoFrameInfoDelegate <NSObject>
/*画面尺寸改变*/
- (void)IncomingFrameSizeChanged:(int)width withHeight:(int)height;
/*对方视频码率，帧率*/
- (void)IncomingRate:(int)fps withRate:(int)bitrate;
/*本端视频码率，帧率*/
- (void)OutgoingRate:(int)fps withRate:(int)bitrate;
@end

/*帐号注册状态回调*/
@protocol SipEngineUIRegistrationDelegate

- (void)OnRegistrationProgress:(Account *) account;

- (void)OnRegistrationSucess:(Account *) account;

- (void)OnRegistrationCleared:(Account *) account;

- (void)OnRegisterationFailed:(Account *) account
                withErrorCode:(int) code
              withErrorReason:(NSString *) reason;

@end
