//
//  Call.m
//  VideoChat
//

#import "Call.h"

#import <WebRTC/RTCAudioTrack.h>
#import <WebRTC/RTCConfiguration.h>
#import <WebRTC/RTCDefaultVideoDecoderFactory.h>
#import <WebRTC/RTCDefaultVideoEncoderFactory.h>
#import <WebRTC/RTCFileLogger.h>
#import <WebRTC/RTCFileVideoCapturer.h>
#import <WebRTC/RTCIceServer.h>
#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCMediaConstraints.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCRtpSender.h>
#import <WebRTC/RTCRtpTransceiver.h>
#import <WebRTC/RTCTracing.h>
#import <WebRTC/RTCVideoSource.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCSessionDescription.h>
#import <WebRTC/RTCPeerConnectionFactoryOptions.h>
#import <WebRTC/RTCDefaultVideoDecoderFactory.h>
#import <WebRTC/RTCDefaultVideoEncoderFactory.h>

#import "SipEngine.h"

//#ifdef DEBUG //调试

#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%zd\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);

//#else // 发布

//#define NSLog(FORMAT, ...) nil

//#endif

/*static NSString * const kARDDefaultSTUNServerUrl =
@"stun:123.57.209.70:19302";
static NSString * const kARDDefaultTURNServerUrl =
@"turn:123.57.209.70:19302";*/

/*static NSString * const kARDDefaultSTUNServerUrl =
@"stun:222.211.83.166:3678";
static NSString * const kARDDefaultTURNServerUrl =
@"turn:222.211.83.166:3678";*/

static NSString * const kARDDefaultSTUNServerUrl =
@"stun:39.108.167.93:19302";
static NSString * const kARDDefaultTURNServerUrl =
@"turn:39.108.167.93:19302";

static NSString * const kARDMediaStreamId = @"ARDAMS";
static NSString * const kARDAudioTrackId = @"ARDAMSa0";
static NSString * const kARDVideoTrackId = @"ARDAMSv0";
static NSString * const kARDVideoTrackKind = @"video";

static int const kKbpsMultiplier = 1000;

@implementation Call {
    RTCVideoTrack *_localVideoTrack;
    BOOL _usingFrontCamera;
    BOOL muted, videoMuted, speaker;
}

@synthesize callConfig = _callConfig;
@synthesize peerConnection = _peerConnection;
@synthesize factory = _factory;
@synthesize rtcDelegate = _rtcDelegate;
@synthesize peerNumber = _peerNumber;
@synthesize iceServers = _iceServers;
@synthesize isIncomingCall = _isIncomingCall;
@synthesize isAudioOnly = _isAudioOnly;
@synthesize callId = _callId;
@synthesize remoteSdp = _remoteSdp;
@synthesize shouldUseLevelControl = _shouldUseLevelControl;
@synthesize defaultPeerConnectionConstraints =
_defaultPeerConnectionConstraints;
@synthesize direction = _direction;

/*- (instancetype)initWithCallConfig:(CallConfig*)callConfig;
{
    if ((self = [super init])) {
        _callConfig = callConfig;
        [self configure];
    }
    return self;
}*/

- (id)init
{
    if ((self = [super init])) {
        [self configure];
    }
    return self;
}

- (void)configure {
    _iceServers = [NSMutableArray arrayWithObject:[self defaultSTUNServer]];
    //[_iceServers addObject:[self defaultTURNServer]];
    _factory = nil;
    _isAudioOnly = FALSE;
    _isIncomingCall = FALSE;
    _usingFrontCamera = YES;
}

- (void)makeCall:(NSString*)peerNumber callConfig:(CallConfig *)callConfig
{
    _peerNumber = peerNumber;
    _callConfig = callConfig;
    [self initializeAudioSession];
    [self createPeerConnectionFactory];
    [self createPeerConnection];
    [self createOffer];
}

- (void)acceptCall:(CallConfig *)callConfig
{
    _callConfig = callConfig;
    [self initializeAudioSession];
    [self createPeerConnectionFactory];
    [self createPeerConnection];
    [self setRemoteDescription:RTCSdpTypeOffer remoteSdp:_remoteSdp];
    [self createAnswer];
}

- (void)rejectCall
{
    [self disconnect];
    [[CallManager instance] reject:_callId];
}

- (void)hangupCall
{
    [self finalizeAudioSession];
    [self disconnect];
    [[CallManager instance] hangup:_callId];
}

- (void)disconnect
{
    _isIncomingCall = NO;
    _peerConnection = nil;
    [_peerConnection close];
    _peerConnection = nil;
}

- (void)onCallOfferSDP:(NSString*)sdp{
    _remoteSdp = sdp;
}

- (void)onCallAnswerSDP:(NSString*)sdp{
    _remoteSdp = sdp;
    [self setRemoteDescription:RTCSdpTypeAnswer remoteSdp:sdp];
}

- (void)setRemoteDescription:(RTCSdpType)type remoteSdp:(NSString *)Sdp
{
    RTCSessionDescription *description =
    [[RTCSessionDescription alloc]initWithType:type sdp:Sdp];
    __weak Call *weakSelf = self;
    NSLog(@"===remoteSdp===:%@", Sdp);
    [_peerConnection setRemoteDescription:description
                        completionHandler:^(NSError *error) {
                            Call *strongSelf = weakSelf;
                            [strongSelf peerConnection:strongSelf.peerConnection
                     didSetSessionDescriptionWithError:error];
                        }];
}

- (void)createPeerConnectionFactory
{
     RTCPeerConnectionFactoryOptions* options = [[RTCPeerConnectionFactoryOptions alloc] init];
     options.disableNetworkMonitor = TRUE;
     options.ignoreLoopbackNetworkAdapter = TRUE;
     RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
     RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
     encoderFactory.preferredCodec = [_callConfig currentVideoCodecConfigFromStore];
     _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory
     decoderFactory:decoderFactory];
     
     [_factory setOptions:options];
}

- (void)createPeerConnection
{
    // Create peer connection.
    
    RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
    RTCConfiguration *config = [[RTCConfiguration alloc] init];
    /*config.iceServers = _iceServers;
    config.tcpCandidatePolicy = RTCTcpCandidatePolicyDisabled;
    config.bundlePolicy = RTCBundlePolicyMaxCompat;
    config.rtcpMuxPolicy = RTCRtcpMuxPolicyNegotiate;
    config.disableIPV6OnWiFi = TRUE;
    config.sdpSemantics = RTCSdpSemanticsUnifiedPlan;*/
    
    RTCCertificate *pcert = [RTCCertificate generateCertificateWithParams:@{
                                        @"expires" : @100000,
                                        @"name" : @"RSASSA-PKCS1-v1_5"}];
    config.iceServers = _iceServers;
    config.tcpCandidatePolicy = RTCTcpCandidatePolicyDisabled;
    config.sdpSemantics = RTCSdpSemanticsUnifiedPlan;
    config.certificate = pcert;

    _peerConnection = [_factory peerConnectionWithConfiguration:config
                                                    constraints:constraints
                                                       delegate:self];
    [self createMediaSenders];
}

- (NSInteger)getCallId
{
    return _callId;
}

- (void)createOffer
{
    _isIncomingCall = FALSE;
    __weak Call *weakSelf = self;
    [_peerConnection offerForConstraints:[self defaultOfferConstraints]
                       completionHandler:^(RTCSessionDescription *sdp,
                                           NSError *error) {
                           Call *strongSelf = weakSelf;
                           [strongSelf peerConnection:strongSelf.peerConnection
                          didCreateSessionDescription:sdp
                                                error:error];
                       }];
}

- (void)createAnswer
{
    _isIncomingCall = TRUE;
        RTCMediaConstraints *constraints = [self defaultAnswerConstraints];
        __weak Call *weakSelf = self;
        [_peerConnection answerForConstraints:constraints
                            completionHandler:^(RTCSessionDescription *sdp,
                                                NSError *error) {
                                Call *strongSelf = weakSelf;
                                [strongSelf peerConnection:strongSelf.peerConnection
                               didCreateSessionDescription:sdp
                                                     error:error];
                            }];
    
}

- (void)callOrAnswer: (RTCSessionDescription *)localsdp{
    NSLog(@"===callOrAnswer===:%@", localsdp.sdp);
    if(_isIncomingCall)
       [[CallManager instance] accept:_callId answersdp:localsdp.sdp];
    else {
        [[CallManager instance] makeCall:0 callId:_callId peerNumber:_peerNumber offersdp:localsdp.sdp];
    }
}

- (void)pauseSendAudio
{
    if (_peerConnection.senders) {
        for (int i = 0; i < [_peerConnection.senders count]; i++) {
            RTCMediaStreamTrack * track = [[_peerConnection.senders objectAtIndex:i] track];
            if ([track.kind isEqualToString:@"audio"]) {
                [track setIsEnabled:NO];
            }
        }
    }
}

- (void)resumeSendAudio
{
    if (_peerConnection.senders) {
        for (int i = 0; i < [_peerConnection.senders count]; i++) {
            RTCMediaStreamTrack * track = [[_peerConnection.senders objectAtIndex:i] track];
            if ([track.kind isEqualToString:@"audio"]) {
                [track setIsEnabled:YES];
            }
        }
    }
}

- (void)pauseSendVideo
{
    if (_peerConnection.senders) {
        for (int i = 0; i < [_peerConnection.senders count]; i++) {
            RTCMediaStreamTrack * track = [[_peerConnection.senders objectAtIndex:i] track];
            if ([track.kind isEqualToString:@"video"]) {
                [track setIsEnabled:NO];
            }
        }
    }
}

- (void)resumeSendVideo
{
    if (_peerConnection.senders) {
        for (int i = 0; i < [_peerConnection.senders count]; i++) {
            RTCMediaStreamTrack * track = [[_peerConnection.senders objectAtIndex:i] track];
            if ([track.kind isEqualToString:@"video"]) {
                [track setIsEnabled:YES];
            }
        }
    }
}

// enable or disable speaker (effectively disabling or enabling earpiece)
- (void)enableLoudsSpeaker:(BOOL)isSpeaker {
    speaker = isSpeaker;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    if (speaker == YES) {
        if (![session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                        error:&error]) {
            //RCLogError("Error overriding output to speaker");
        }
    }
    else {
        if (![session overrideOutputAudioPort:AVAudioSessionPortOverrideNone
                                        error:&error]) {
            //RCLogError("Error overriding none");
        }
    }
    
    return;
}

- (BOOL)getLoudsSpeakerStatus
{
    return speaker;
}

- (void)setMute:(BOOL)isMute
{
    muted = isMute;
    if (_peerConnection.receivers) {
        for (int i = 0; i < [_peerConnection.receivers count]; i++) {
            RTCMediaStreamTrack * track = [[_peerConnection.receivers objectAtIndex:i] track];
            if ([track.kind isEqualToString:@"audio"]) {
                [track setIsEnabled:isMute];
            }
        }
    }
}

- (BOOL)getMuteStatus
{
    return muted;
}

- (void)switchCamera
{
    _usingFrontCamera = !_usingFrontCamera;
}

- (void)sendDtmfDigits:(NSString*)digits rfc2833:(BOOL)rfc2833
{
    if(rfc2833) {
       if(_peerConnection) {
          if (_peerConnection.senders) {
            for (int i = 0; i < [_peerConnection.senders count]; i++) {
                RTCMediaStreamTrack * track = [[_peerConnection.senders objectAtIndex:i] track];
                if ([track.kind isEqualToString:@"audio"]) {
                    id<RTCDtmfSender> dtmfSender = [[_peerConnection.senders objectAtIndex:i] dtmfSender];
                    if([dtmfSender canInsertDtmf])
                        [dtmfSender insertDtmf:digits duration:400 interToneGap:50];
                }
            }
         }
       }
    } else {
        [[CallManager instance] sendDtmfDigits:_callId digits:digits];
    }
}

// Audio Session helpers
- (BOOL)initializeAudioSession
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    if (![session.category isEqualToString:@"AVAudioSessionCategoryPlayAndRecord"]){
        if (![session setCategory:AVAudioSessionCategoryPlayAndRecord
              //withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker /*AVAudioSessionCategoryOptionMixWithOthers*/
                            error:&error]) {
            // handle error
            //RCLogError("Error setting AVAudioSession category");
            return NO;
        }
    }
    
    if (![session setActive:YES error:&error]) {
        //RCLogError("Error activating audio session");
        return NO;
    }
    return YES;
}

- (BOOL)finalizeAudioSession
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    if (![session overrideOutputAudioPort:AVAudioSessionPortOverrideNone
                                    error:&error]) {
        //RCLogError("Error overriding output to none");
        return NO;
    }
    
    if (![session setActive:NO error:&error]) {
        //RCLogError("Error activating audio session");
        return NO;
    }
    
    return YES;
}

#pragma mark - RTCPeerConnectionDelegate
// Callbacks for this delegate occur on non-main thread and need to be
// dispatched back to main queue as needed.

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeSignalingState:(RTCSignalingState)stateChanged {
    //RTCLog(@"Signaling state changed: %ld", (long)stateChanged);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
          didAddStream:(RTCMediaStream *)stream {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Received %lu video tracks and %lu audio tracks",
               (unsigned long)stream.videoTracks.count,
               (unsigned long)stream.audioTracks.count);
        if (stream.videoTracks.count) {
            RTCVideoTrack *videoTrack = stream.videoTracks[0];
            [self->_rtcDelegate call:self didReceiveRemoteVideoTrack:videoTrack];
        }
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
       didRemoveStream:(RTCMediaStream *)stream {
    RTCLog(@"Stream was removed.");
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection {
    RTCLog(@"WARNING: Renegotiation needed but unimplemented.");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceConnectionState:(RTCIceConnectionState)newState {
    RTCLog(@"ICE state changed: %ld", (long)newState);
    dispatch_async(dispatch_get_main_queue(), ^{
       // [_delegate appClient:self didChangeConnectionState:newState];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceGatheringState:(RTCIceGatheringState)newState {
    NSLog(@"ICE gathering state changed: %ld", (long)newState);
    if(newState == RTCIceGatheringStateComplete) {
        [self callOrAnswer:_peerConnection.localDescription];
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    dispatch_async(dispatch_get_main_queue(), ^{
        //ARDICECandidateMessage *message =
        //[[ARDICECandidateMessage alloc] initWithCandidate:candidate];
        //[self sendSignalingMessage:message];
        //[_peerConnection addSdpICECandidate:candidate];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates {
    dispatch_async(dispatch_get_main_queue(), ^{
       // ARDICECandidateRemovalMessage *message =
        //[[ARDICECandidateRemovalMessage alloc]
         //initWithRemovedCandidates:candidates];
        //[self sendSignalingMessage:message];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didOpenDataChannel:(RTCDataChannel *)dataChannel {
}

#pragma mark - RTCSessionDescriptionDelegate
// Callbacks for this delegate occur on non-main thread and need to be
// dispatched back to main queue as needed.

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didCreateSessionDescription:(RTCSessionDescription *)sdp
                 error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            RTCLogError(@"Failed to create session description. Error: %@", error);
            [self disconnect];
            //NSDictionary *userInfo = @{
                                      // NSLocalizedDescriptionKey: @"Failed to create session description.",
                                      // };
            //NSError *sdpError =
            //[[NSError alloc] initWithDomain:kARDAppClientErrorDomain
              //                         code:kARDAppClientErrorCreateSDP
                //                   userInfo:userInfo];
          //  [_delegate appClient:self didError:sdpError];
            return;
        }
        NSLog(@"didCreateSessionDescription");
        // Prefer H264 if available.
        //RTCSessionDescription *sdpPreferringH264 =
       // [ARDSDPUtils descriptionForDescription:sdp
                          // preferredVideoCodec:@"H264"];
        __weak Call *weakSelf = self;

        [self->_peerConnection setLocalDescription:sdp
                           completionHandler:^(NSError *error) {
                               Call *strongSelf = weakSelf;
                               [strongSelf peerConnection:strongSelf.peerConnection
                        didSetSessionDescriptionWithError:error];
                }];
        [self setMaxBitrate];
        });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didSetSessionDescriptionWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSLog(@"Failed to set session description. Error: %@", error);
            [self disconnect];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: @"Failed to set session description.",
                                       };
           /* NSError *sdpError =
            [[NSError alloc] initWithDomain:kARDAppClientErrorDomain
                                       code:kARDAppClientErrorSetSDP
                                   userInfo:userInfo];
            [_delegate appClient:self didError:sdpError];*/
            return;
        }
        // If we're answering and we've just set the remote offer we need to create
        // an answer and set the local description.
       /* if (!_isInitiator && !_peerConnection.localDescription) {
            RTCMediaConstraints *constraints = [self defaultAnswerConstraints];
            __weak Call *weakSelf = self;
            [_peerConnection answerForConstraints:constraints
                                completionHandler:^(RTCSessionDescription *sdp,
                                                    NSError *error) {
                                    Call *strongSelf = weakSelf;
                                    [strongSelf peerConnection:strongSelf.peerConnection
                                   didCreateSessionDescription:sdp
                                                         error:error];
                                }];
        }*/
    });
}

#pragma mark - Defaults

- (RTCMediaConstraints *)defaultMediaStreamConstraints {
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:nil
     optionalConstraints:nil];
    return constraints;
}

- (RTCMediaConstraints *)defaultAnswerConstraints {
    return [self defaultOfferConstraints];
}

- (RTCMediaConstraints *)defaultOfferConstraints {
    NSDictionary *mandatoryConstraints = @{
                                           @"OfferToReceiveAudio" : @"true",
                                           @"OfferToReceiveVideo" : @"true"
                                           };
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:mandatoryConstraints
     optionalConstraints:nil];
    return constraints;
}

- (RTCMediaConstraints *)defaultPeerConnectionConstraints {
    if (_defaultPeerConnectionConstraints) {
        return _defaultPeerConnectionConstraints;
    }
    NSString *value = @"true";
    NSDictionary *optionalConstraints = @{ @"DtlsSrtpKeyAgreement" : value };
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:nil
     optionalConstraints:optionalConstraints];
    return constraints;
}

- (RTCIceServer *)defaultSTUNServer {
    return [[RTCIceServer alloc] initWithURLStrings:@[kARDDefaultSTUNServerUrl]
                                           username:@""
                                         credential:@""];
}
/*- (RTCIceServer *)defaultSTUNServer {
    NSURL *defaultSTUNServerURL = [NSURL URLWithString:kARDDefaultSTUNServerUrl];
    return [[RTCIceServer alloc] initWithURI:defaultSTUNServerURL
                                    username:@""
                                    password:@""];
}*/

- (RTCIceServer *)defaultTURNServer {
    //return [[RTCIceServer alloc] initWithURLStrings:@[kARDDefaultTURNServerUrl]
                                    //username:@"jiangbo"
                                   // credential:@"jiangbo"];
    return [[RTCIceServer alloc] initWithURLStrings:@[kARDDefaultTURNServerUrl]
                                           username:@"websip"
                                         credential:@"websip"];
}


/*- (RTCICEServer *)defaultTURNServer {
    NSURL *defaultTURNServerURL = [NSURL URLWithString:kARDDefaultTURNServerUrl];
    return [[RTCIceServer alloc] initWithURI:defaultTURNServerURL
                                    username:@"700"
                                    password:@"700"];
}*/

- (RTCRtpSender *)createVideoSender {
    RTCRtpSender *sender =
    [_peerConnection senderWithKind:kRTCMediaStreamTrackKindVideo
                           streamId:kARDMediaStreamId];
    RTCVideoTrack *track = [self createLocalVideoTrack];
    if (track) {
        sender.track = track;
    }
    return sender;
}

- (RTCRtpSender *)createAudioSender {
    RTCRtpSender *sender =
    [_peerConnection senderWithKind:kRTCMediaStreamTrackKindAudio
                           streamId:kARDMediaStreamId];
    RTCAudioTrack *track = [_factory audioTrackWithTrackId:kARDAudioTrackId];
    sender.track = track;
    return sender;
}

- (RTCVideoTrack *)createLocalVideoTrack {
    RTCVideoSource *source = [_factory videoSource];
    RTCCameraVideoCapturer *capturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:source];
    [_rtcDelegate call:self didCreateLocalCapturer:capturer];
    return [_factory videoTrackWithSource:source trackId:kARDVideoTrackId];
}

- (RTCMediaConstraints *)defaultMediaAudioConstraints {
    NSDictionary *mandatoryConstraints = @{};
    RTCMediaConstraints *constraints =
    [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                          optionalConstraints:nil];
    return constraints;
}

- (void)setMaxBitrate {
    for (RTCRtpSender *sender in _peerConnection.senders) {
        if (sender.track != nil) {
            if ([sender.track.kind isEqualToString:kARDVideoTrackKind]) {
                [self setMaxBitrateForPeerConnectionVideoSender:[_callConfig currentMaxBitrateConfigFromStore] forVideoSender:sender];
            }
        }
    }
}

- (void)setMaxBitrateForPeerConnectionVideoSender:(NSNumber *)maxBitrate forVideoSender:(RTCRtpSender *)sender {
    if (maxBitrate.intValue <= 0) {
        return;
    }
    
    RTCRtpParameters *parametersToModify = sender.parameters;
    for (RTCRtpEncodingParameters *encoding in parametersToModify.encodings) {
        encoding.maxBitrateBps = @(maxBitrate.intValue * kKbpsMultiplier);
    }
    [sender setParameters:parametersToModify];
}


- (RTCRtpTransceiver *)videoTransceiver {
    for (RTCRtpTransceiver *transceiver in _peerConnection.transceivers) {
        if (transceiver.mediaType == RTCRtpMediaTypeVideo) {
            return transceiver;
        }
    }
    return nil;
}

- (void)createMediaSenders {
    RTCMediaConstraints *constraints = [self defaultMediaAudioConstraints];
    RTCAudioSource *source = [_factory audioSourceWithConstraints:constraints];
    RTCAudioTrack *track = [_factory audioTrackWithSource:source
                                                  trackId:kARDAudioTrackId];
    [_peerConnection addTrack:track streamIds:@[ kARDMediaStreamId ]];
    _localVideoTrack = [self createLocalVideoTrack];
    if (_localVideoTrack) {
        [_peerConnection addTrack:_localVideoTrack streamIds:@[ kARDMediaStreamId ]];
       // [_delegate appClient:self didReceiveLocalVideoTrack:_localVideoTrack];
        // We can set up rendering for the remote track right away since the transceiver already has an
        // RTCRtpReceiver with a track. The track will automatically get unmuted and produce frames
        // once RTP is received.
        RTCVideoTrack *track = (RTCVideoTrack *)([self videoTransceiver].receiver.track);
        [_rtcDelegate call:self didReceiveRemoteVideoTrack:track];
    }
}

-(BOOL)support_video
{
    return TRUE;
}

@end
