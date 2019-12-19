#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "ARDStatsView.h"
#import <WebRTC/RTCCameraPreviewView.h>
#import <WebRTC/RTCVideoRenderer.h>

enum ARDVideoCallingMode
{
    kAudioCalling = 0,
    kVideoCalling,
    kAudioRinging,
    kVideoRinging,
    kAudioAnswered,
    kVideoAnswered
};

@class ARDVideoCallView;
@protocol ARDVideoCallViewDelegate <NSObject>

// Called when the hangup button is pressed.
- (void)videoCallViewDidAnswer;

- (void)videoCallViewDidHangup;

- (void)videoCallViewDidMute:(BOOL)muted;

- (void)videoCallViewDidSpeaker:(BOOL)isOn;

- (void)videoCallViewDidTurnCameraOff:(BOOL)isOn;

- (void)videoCallViewDidSwitchCamera;

- (void)videoCallViewDidSelectContacts:(BOOL)isOn;

- (void)videoCallViewDidDtmfClicked:(NSString *)tone;

@end

// Video call view that shows local and remote video, provides a label to
// display status, and also a hangup button.
@interface ARDVideoCallView : UIView <UIScrollViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, readonly) UILabel *statusLabel;

@property(nonatomic, readonly) RTCCameraPreviewView *localVideoView;
@property(nonatomic, readonly) __kindof UIView<RTCVideoRenderer> *remoteVideoView;

@property(nonatomic, weak) id<ARDVideoCallViewDelegate> delegate;
@property(nonatomic) BOOL inCalling;
@property(nonatomic) BOOL hidenToolWidgets;
@property(nonatomic) UILabel *systemStatsLabel;
@property(nonatomic) UILabel *connStatsLabel;
@property(nonatomic) UILabel *videoSendLabel;
@property(nonatomic) UILabel *videoReceiveLabel;
@property(nonatomic) UILabel *audioSendLabel;
@property(nonatomic) UILabel *audioReceiveLabel;
@property(nonatomic) enum ARDVideoCallingMode mode;
@property (retain, nonatomic) AVCaptureSession *session;
@property (retain, nonatomic) AVCaptureVideoPreviewLayer* preLayer;
//@property(nonatomic) ARDStatsView *statsView;

-(void)setARDVideoCallingMode:(enum ARDVideoCallingMode)mode;
-(void)setCalledNumber:(NSString *)text;
-(void)setCallingTimeLabel:(NSString *)text;
-(void)hiddenAllWidgets;
-(void)stopCallingUI;
@end
