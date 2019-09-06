//
//  SipEngineManager.h
//  MicroVoice
// Copyright 2011 webrtctel.com All rights reserved.
//
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>

#include "CommonTypes.h"

#import "SipEngineDelegate.h"
#import "SipEngine.h"
#import "Call.h"
#import <reSIProcate/RegistrationStateDelegate.h>
#import <reSIProcate/CallStateDelegate.h>

typedef enum _Connectivity {
	wifi,
	wwan
	,none
} Connectivity;

#define kCallDir_Initialize 0
#define kCallDir_Calling 1
#define kCallDir_Incoming 2
#define kCallDir_OfflineCall 3

typedef enum _CallErrorCode{
    None = 0,
    CouldNotCall,
    
    /*SIP ∫ÙΩ–¥ÌŒÛ¥˙¬Î*/
    Unauthorized = 401,
    BadRequest = 400,
    PaymentRequired = 402,
    Forbidden = 403,
    MethodNotAllowed = 405,
    ProxyAuthenticationRequired = 407,
    RequestTimeout = 408,
    NotFound = 404,
    UnsupportedMediaType  = 415,
    RequestSendFailed = 477,
    BusyHere = 486,
    TemporarilyUnavailable = 480,
    RequestTerminated = 487,
    ServerInternalError = 500,
    DoNotDisturb = 600,
    Declined = 603,
    
    /*Media Error code*/
    MediaStreamTimeout = 1001,
} CallErrorCode;

typedef struct VideoSize_
{
    int width;
    int height;
} VideoSize_t;

typedef enum ScheduleNotificationType{
    kNotifyAudioCall = 0,
    kNotifyVideoCall,
    kNotifyTextMessage,
    kNotifyFriendJoin,
} ScheduleNotificationType;

@interface SipEngineManager : NSObject
{
@private
	SCNetworkReachabilityContext proxyReachabilityContext;
	SCNetworkReachabilityRef proxyReachability;
	NSTimer *mIterateTimer;
	__unsafe_unretained id<SipEngineUICallDelegate> callDelegate;
	__unsafe_unretained id<SipEngineUIRegistrationDelegate> registrationDelegate;
	//SipEventObserver *event_observer_;
    SipEngine *sip_engine_;
    Call *current_call_;
    Account *current_account_;
    RegistrationManager* registrationManager_;
    CallManager* callManager_;
    BOOL isInitialized;
@public
	Connectivity connectivity;
}

/*静态接口*/
+(SipEngineManager*) instance;

+(void)doScheduleNotification:(NSString*)from types:(ScheduleNotificationType)type content:(NSString*)content;

-(SipEngine*)getSipEngine;

-(CallManager*)getCallManager;

-(RegistrationManager*)getRegistrationManager;

//-(client::SipProfileManager*) getSipProfileManager;

//-(client::RTCVoiceEngine*) getRTCVoiceEngine;

//-(client::RTCVideoEngine*) getRTCVideoEngine;

-(void)Initialize;

/* - (Account *)createAccount:(NSString *)username
                 password:(NSString *)password
                   server:(NSString *)server
                    proxy:(NSString *)proxy
                transport:(NSString *)transport
              display_name:(NSString *)displayname;*/

- (Account *)createAccount;
- (Call *)createCall:(int)accId;

//- (Call *)createCall:(NSString*)number withVideoCall:(bool)video_enabled displayName:(NSString *)display_name;

- (Call *)getIncomingCall;

- (void)setSipEngineRegistrationDelegate:(id<SipEngineUIRegistrationDelegate>)delegate;

- (void)setSipEngineCallDelegate:(id<SipEngineUICallDelegate>)delegate;

- (void)TerminateCall;

- (void)runNetworkConnection;

- (void)kickOffNetworkConnection;

- (BOOL)NetworkIsReachable;

- (BOOL)InCalling;

- (BOOL)HaveIncomingCall;

- (void)AnswerIncomingCall;

- (void)Terminate;

- (void)enterBackgroundMode;

- (void)becomeActive;

- (void)RefreshSipRegister;

- (VideoSize_t *)getVideoSize;

- (float)getBitrate;

- (float)getFrameRate;

@property (nonatomic, assign) id<SipEngineUICallDelegate> callDelegate;
@property (nonatomic, assign) id<SipEngineUIRegistrationDelegate> registrationDelegate;
@property (nonatomic, assign) id<VideoFrameInfoDelegate> videoFrameInfoDelegate;

@end
