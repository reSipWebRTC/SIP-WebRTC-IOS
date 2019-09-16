//
//  Call.h
//  VideoChat
//

#import <Foundation/Foundation.h>
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import "CallConfig.h"

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
//- (instancetype)initWithCallConfig:(CallConfig *)callConfig;
- (BOOL)support_video;
- (NSInteger)getCallId;
- (void)makeCall:(NSString*)peerNumber callConfig:(CallConfig *)callConfig;
- (void)acceptCall:(CallConfig *)callConfig;
- (void)rejectCall;
- (void)hangupCall;
- (void)disconnect;
- (void)onCallOfferSDP:(NSString*)sdp;
- (void)onCallAnswerSDP:(NSString*)sdp;
- (void)sendDtmfDigits:(NSString*)digits rfc2833:(BOOL)rfc2833;
- (void)pauseSendAudio;
- (void)resumeSendAudio;
- (void)pauseSendVideo;
- (void)resumeSendVideo;
- (void)enableLoudsSpeaker:(BOOL)isSpeaker;
- (BOOL)getLoudsSpeakerStatus;
- (void)setMute:(BOOL)isMute;
- (BOOL)getMuteStatus;
- (void)switchCamera;

@property(nonatomic, assign) int callId;
@property(nonatomic, strong) CallConfig *callConfig;
@property(nonatomic, strong) NSString *remoteSdp;
@property(nonatomic, strong) NSString *peerNumber;
@property(nonatomic, strong) NSMutableArray *iceServers;
@property(nonatomic, assign) BOOL isIncomingCall;
@property(nonatomic, readonly) BOOL isAudioOnly;
@property(nonatomic, readonly) BOOL shouldUseLevelControl;
@property(nonatomic, assign) Direction direction;
@property(nonatomic, strong) RTCPeerConnection *peerConnection;
@property(nonatomic, strong) RTCPeerConnectionFactory *factory;
@property(nonatomic, strong) RTCMediaConstraints *defaultPeerConnectionConstraints;

@property(nonatomic, weak) id<ARDRtcCallDelegate> rtcDelegate;

@end

