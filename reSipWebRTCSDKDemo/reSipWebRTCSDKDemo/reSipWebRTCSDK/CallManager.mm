
#import "CallManager.h"
#import "SipEngineManager.h"
#import <reSIProcate/RTCCallManager.h>
#import <WebRTC/RTCPeerConnectionFactoryOptions.h>
#import <WebRTC/RTCDefaultVideoDecoderFactory.h>
#import <WebRTC/RTCDefaultVideoEncoderFactory.h>
#import "CallConfig.h"

typedef enum
{
    kNewCall = 0,
    kCancel,
    kFailed,
    kRejected,
    kEarlyMedia,
    kRinging,
    kAnswered,
    kHangup,
    kPausing,
    kPaused,
    kResuming,
    kResumed,
    kUpdating,
    kUpdated
} CallState;

static CallManager *the_callManager_ = NULL;

@implementation CallManager {
    RTCCallManager* rtcCallManager;
    Call* current_call_;
    CallConfig *_callConfig;
    NSMutableDictionary<NSNumber *, id> * CallMap;
}

@synthesize callDelegate = _callDelegate;
@synthesize factory = _factory;

+(CallManager *)instance
{
    if(the_callManager_ == NULL)
    {
        the_callManager_ = [[CallManager alloc] init];
    }
        
    return the_callManager_;
}

- (id)init
{
    if ((self = [super init])) {
        rtcCallManager = [[[SipEngineManager instance] getSipEngine].rtcSipEngine GetCallManager];
        [rtcCallManager RegisterCallStateDelegate:self];
        CallMap = [[NSMutableDictionary alloc] initWithCapacity:5];
        /*RTCPeerConnectionFactoryOptions* options = [[RTCPeerConnectionFactoryOptions alloc] init];
        //options.disableEncryption = TRUE;
        options.disableNetworkMonitor = TRUE;
        options.ignoreLoopbackNetworkAdapter = TRUE;
        RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
        RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
        encoderFactory.preferredCodec = [_callConfig currentVideoCodecConfigFromStore];
        _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory
                                                             decoderFactory:decoderFactory];

        [_factory setOptions:options];*/
    }
    
    return self;
}
    
- (Call*)createCall: (int)accId
{
    int callId = [rtcCallManager CreateCall:accId];
    current_call_ = [[Call alloc] init];
    [current_call_ setCallId:callId];
    //self->_callConfig = callConfig;
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        if(self->_callDelegate != nullptr)
            [self->_callDelegate OnNewOutgoingCall:self->current_call_ caller:@"" video_call:true];
    //});
    
    return current_call_;
}
    
- (void)makeCall: (int)accId callId:(int)callId peerNumber:(NSString *)peerNumber  offersdp:(NSString*)sdp
{
    if(rtcCallManager != nil)
        [rtcCallManager MakeCall:callId callId:callId peerNumber:peerNumber offersdp:sdp];
}
    
- (void)accept: (int)callId answersdp:(NSString* )sdp
{
    [rtcCallManager Accept:callId answersdp:sdp];
}
    
- (void)hangup: (int)callId
{
    [rtcCallManager Hangup:callId];
}
    
- (void)reject: (int)callId
{
    [rtcCallManager Reject:callId];
}

- (void)registerCall: (Call *)call
{
    if(CallMap != nil)
        [CallMap setObject:call forKey:[NSNumber numberWithInteger:call.getCallId]];
}

- (void)unregisterCall: (Call *)call
{
    if(CallMap != nil)
        [CallMap removeObjectForKey:[NSNumber numberWithInteger:call.getCallId]];
}

- (void)sendDtmfDigits: (int)callId digits:(NSString*)digits
{
    [rtcCallManager SendDtmfDigits:callId digits:digits];
}

- (void)registerUICallStateDelegate: (id<SipEngineUICallDelegate>)delegate{
    _callDelegate = delegate;
}
    
- (void)OnCallAnswer:(int)callId remoteSdp:(NSString *)sdp
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->current_call_ != nil)
            [self->current_call_ onCallAnswerSDP:sdp];
    });
}

- (void)OnCallOffer:(int)callId remoteSdp:(NSString *)sdp
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->current_call_ != nil)
            [self->current_call_ onCallOfferSDP:sdp];
    });
}

- (void)OnCallStateChange:(int)callId state_code:(int)state_code reason:(NSString *)reason
{
    
    //IVLog(@"OnCallStateChange( call = %s, state = %s)",call->toString(),call->CallStateName(statecode));
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(state_code == kAnswered) {
            //[self->_callDelegate OnCallConnected:self->current_call_ withVideoChannel:TRUE withDataChannel:FALSE];
        }
        if(state_code == kHangup) {
            //[self->_callDelegate OnCallEnded:self->current_call_];
        }
        if(state_code == kFailed || state_code == kRejected) {
            
        }
        
        switch (state_code) {
            case kNewCall:
            {
               /* NSString *peer_caller  = [NSString  stringWithFormat:NSLocalizedString(@"%s",nil),call->caller_id()];
                
                if(call->direction() == client::kIncoming)
                {
                    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]
                        && [UIApplication sharedApplication].applicationState !=  UIApplicationStateActive) {
                        
                        // TODO: 添加 peer_id
                        [SipEngineManager doScheduleNotification:[NSString  stringWithFormat:NSLocalizedString(@"%s",nil),[peer_caller UTF8String]] types:call->support_video()? kNotifyVideoCall : kNotifyAudioCall content:nil];
                        
                    }
                }
                
                if(call->support_video())
                {
                    client::VideoStream *video_stream = call->media_stream()->video_stream();
                    video_stream->RegisterVideoStreamObserver(this);
                }
                
                if (ui_ptr_ && ((__bridge SipEngineManager*)ui_ptr_).callDelegate != nil)
                {
                    [((__bridge SipEngineManager*)ui_ptr_).callDelegate OnNewCall:call withDirection:call->direction() withPeerCallerID:peer_caller withVideo:call->support_video()];
                }*/
            }
                break;
            case kEarlyMedia:
            {
                /*if (ui_ptr_ && ((__bridge SipEngineManager*)ui_ptr_).callDelegate != nil){
                    [((__bridge SipEngineManager*)ui_ptr_).callDelegate OnCallRinging:call];
                }*/
            }
                break;
            case kRinging:
            {
                /*if (ui_ptr_ && ((__bridge SipEngineManager*)ui_ptr_).callDelegate != nil){
                    [((__bridge SipEngineManager*)ui_ptr_).callDelegate OnCallRinging:call];
                }*/
            }
                break;
            case kAnswered:
            {
                [self->_callDelegate OnCallConnected:self->current_call_ withVideoChannel:TRUE withDataChannel:FALSE];
            }
                break;
                
            case kFailed:
            case kRejected:
            {
                /*NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Call failed，Error code %d",@""),call->GetErrorCode()];
                IVLog(@"%@",msg);
                
                if (ui_ptr_ && ((__bridge SipEngineManager*)ui_ptr_).callDelegate != nil){
                    [((__bridge SipEngineManager*)ui_ptr_).callDelegate OnCallFailed:call withErrorCode:call->GetErrorCode()];
                }
                if ([UIApplication sharedApplication].applicationState !=  UIApplicationStateActive) {
                    [[UIApplication sharedApplication] cancelAllLocalNotifications];
                }*/
            }
                break;
            case kHangup:
            case kCancel:
            {
                [self->_callDelegate OnCallEnded:self->current_call_];
                
                /*if (ui_ptr_ && ((__bridge SipEngineManager*)ui_ptr_).callDelegate != nil){
                    [((__bridge SipEngineManager*)ui_ptr_).callDelegate OnCallEnded:call];
                }
                
                if ([UIApplication sharedApplication].applicationState !=  UIApplicationStateActive) {
                    [[UIApplication sharedApplication] cancelAllLocalNotifications];
                }*/
            }
                break;
            case kPausing:
                break;
            case kPaused:
            {
                /*if (ui_ptr_ && ((__bridge SipEngineManager*)ui_ptr_).callDelegate != nil){
                    [((__bridge SipEngineManager*)ui_ptr_).callDelegate OnCallPaused:call];
                }*/
            }
                break;
            case kResuming:
            {
                /*if (ui_ptr_ && ((__bridge SipEngineManager*)ui_ptr_).callDelegate != nil){
                    [((__bridge SipEngineManager*)ui_ptr_).callDelegate OnCallResume:call];
                }*/
            }
                break;
            case kResumed:
                break;
            case kUpdating:
                break;
            case kUpdated:
                break;
            default:
                break;
        }
    });
}

- (void)OnIncomingCall:(int)accId callId:(int)callId caller:(NSString *)caller {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->current_call_ = [[Call alloc]init];
        [self->current_call_ setCallId:callId];
        self->current_call_.direction = kIncoming;
        if(self->_callDelegate != nullptr)
            [self->_callDelegate OnNewIncomingCall:self->current_call_ caller:caller video_call:true];
    });
}

-(void)OnDtmfEvent:(int)callId dtmf:(int)dtmf duration:(int)duration up:(int)up
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_callDelegate OnDtmfEvent:callId dtmf:dtmf duration:duration up:up];
    });
}

@end
