//
//  Call.h
//  VideoChat
//

#import <Foundation/Foundation.h>
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import "CallParams.h"

typedef enum
{
    kIncoming = 0,
    kOutgoing
} Direction;

typedef NS_ENUM(NSInteger, ARDCallState) {
    // Disconnected from servers.
    kARDCallStateDisconnected,
    // Connecting to servers.
    kARDCallStateConnecting,
    // Connected to servers.
    kARDCallStateConnected,
};

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

@class Call;

@protocol ARDRtcCallDelegate <NSObject>

- (void)call:(Call *)client
   didChangeState:(ARDCallState)state;

- (void)call:(Call *)client
didChangeConnectionState:(RTCIceConnectionState)state;

- (void)call:(Call *)client
didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;

- (void)call:(Call *)client
didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;

- (void)call:(Call *)client
didCreateLocalCapturer:(RTCCameraVideoCapturer *)localCapturer;

- (void)call:(Call *)client
         didError:(NSError *)error;

- (void)call:(Call *)client
      didGetStats:(NSArray *)stats;

@end

@interface Call : NSObject <RTCPeerConnectionDelegate>
- (BOOL)support_video;
- (BOOL)support_audio;
- (NSInteger)getCallId;
- (void)makeCall:(NSString*)calleeUri callParams:(CallParams *)callParams;
- (void)acceptCall:(CallParams *)callParams;
- (void)rejectCall;
- (void)hangupCall;
- (void)updateCallByInfo:(BOOL)isVideoCall;
- (void)updateCallByReInvite:(BOOL)isVideoCall;
- (void)holdCall;
- (void)unHoldCall;
- (void)ransferCall:(NSString *)dstNumber;
- (void)disconnect;
- (void)onCallOfferSDP:(NSString*)sdp;
- (void)onCallAnswerSDP:(NSString*)sdp;
- (void)sendDtmfDigits:(NSString*)digits rfc2833:(BOOL)rfc2833;
//- (void)changeMediaState:(BOOL)audio video:(BOOL)video;
- (void)enableLoudsSpeaker:(BOOL)isSpeaker;
- (BOOL)getLoudsSpeakerStatus;
//- (void)setMute:(BOOL)isMute;
- (BOOL)getMuteStatus;
- (void)switchCamera;
- (void)muteAudio;
- (void)unmuteAudio;
- (void)muteVideo;
- (void)unmuteVideo;
- (void)setCallState:(int)callState;
- (int)getCallState;

@property(nonatomic, assign) int callId;
@property(nonatomic, strong) CallParams *callParams;
@property(nonatomic, strong) NSString *remoteSdp;
@property(nonatomic, strong) NSString *calleeUri;
@property(nonatomic, strong) NSString *peerDisplayName;
@property(nonatomic, strong) NSString *peerUri;
@property(nonatomic, strong) NSMutableArray *iceServers;
@property(nonatomic, assign) BOOL isIncomingCall;
@property(nonatomic, assign) BOOL isOutingCall;
@property(nonatomic, assign) BOOL audioCall;
@property(nonatomic, assign) BOOL videoCall;
@property(nonatomic, readonly) BOOL shouldUseLevelControl;
@property(nonatomic, assign) Direction direction;
@property(nonatomic, assign) BOOL shouldGetStats;
@property(nonatomic, strong) RTCPeerConnection *peerConnection;
@property(nonatomic, strong) RTCPeerConnectionFactory *factory;
@property(nonatomic, strong) RTCMediaConstraints *defaultPeerConnectionConstraints;
@property(nonatomic, strong) NSMutableArray *iceCandidates;
@property BOOL candidatesGathered;

@property(nonatomic, weak) id<ARDRtcCallDelegate> rtcDelegate;

@end

