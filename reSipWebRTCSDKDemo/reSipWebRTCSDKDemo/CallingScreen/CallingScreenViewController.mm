//
//  CallingScreenViewController.mm
//  VideoChat
//

#import "CallingScreenViewController.h"
#import <reSipWebRTCSDK/SipEngine.h>
#import <reSipWebRTCSDK/Call.h>
#import <WebRTC/RTCAudioSession.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import <WebRTC/RTCDispatcher.h>
#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCMediaConstraints.h>
#import <reSipWebRTCSDK/ARDCaptureController.h>

@interface CallingScreenViewController () <ARDRtcCallDelegate,
              ARDVideoCallViewDelegate>
{
    NSTimer* countTimer;
    ARDCaptureController *_captureController;
}

@property(nonatomic, strong) RTCVideoTrack *localVideoTrack;
@property(nonatomic, strong) RTCVideoTrack *remoteVideoTrack;
@property(nonatomic, readonly) ARDVideoCallView *avCallingView;

@end

static CallingScreenViewController *the_instance = NULL;;

@implementation CallingScreenViewController
{
    RTCVideoTrack *_remoteVideoTrack;
    RTCVideoTrack *_localVideoTrack;
}

@synthesize avCallingView = _avCallingView;
@synthesize startDate;

+ (CallingScreenViewController*)instance
{
    return the_instance;
}

- (void)videoCallViewDidAnswer
{
    if(current_call_ != NULL) {
        CallConfig *callConfig = [[CallConfig alloc]init];
        [current_call_ acceptCall:callConfig];
    }
}

- (void)videoCallViewDidHangup
{
    [self hangup];
}

- (void)videoCallViewDidMute:(BOOL)muted
{
    if(current_call_)
    {
     
    }
}

- (void)videoCallViewDidSwitchCamera
{
    if(current_call_ && [current_call_ support_video])
    {
        useFrontFaceingCamera = !useFrontFaceingCamera;
        [_captureController switchCamera];
    
        [self changeRemoteVideoSize];
    }
}

- (void)videoCallViewDidSpeaker:(BOOL)isOn
{

}

- (void)videoCallViewDidTurnCameraOff:(BOOL)isOn
{
    
}

- (void)videoCallViewDidSelectContacts
{
    
}

- (void)videoCallViewDidDtmfClicked:(NSString *)tone
{
    if(current_call_)
    {
       // client::AudioStream *audio_stream = current_call_->media_stream()->audio_stream();
       // audio_stream->SendDtmf([tone UTF8String], YES, YES);
    }
}

-(void)setCallingMode:(enum ARDVideoCallingMode)mode
{
    mode_ = mode;
    if(_avCallingView) [_avCallingView setARDVideoCallingMode:mode];
    
    if(mode == kVideoAnswered || mode == kAudioAnswered)
    {
        self.startDate = [NSDate date];
        [self startTimer];
    }
    
    switch (mode)
    {
        case kAudioRinging:
        case kVideoRinging:
            break;
        case kAudioCalling:
        case kAudioAnswered:
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            break;
        case kVideoCalling:
        case kVideoAnswered:
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            break;
        default:
            break;
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"Create video screen .");
    useFrontFaceingCamera = NO;
    vid_img_timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateNetworkInfo) userInfo:nil repeats:YES];

    the_instance = self;
    
    _avCallingView = [[ARDVideoCallView alloc] initWithFrame:CGRectZero];
    _avCallingView.delegate = self;
    _avCallingView.statusLabel.text = @"";
    _avCallingView.inCalling = NO;
    
    self.view  = _avCallingView;
    
    [_avCallingView setARDVideoCallingMode:mode_];
    
    if(current_call_)
    {
        NSString *caller_id = [current_call_ peerNumber];
        [_avCallingView setCalledNumber:caller_id];
    }
    
    countTimer = nil;
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    _avCallingView.hidenToolWidgets = NO;
    [self.view layoutIfNeeded];
}

- (BOOL)isVideoCalling:(Call *) call
{
    return (current_call_ == call && [current_call_ support_video]);
}

- (void)setCurrentCall:(Call *) call
{
    current_call_ = call;
    current_call_.rtcDelegate = self;
    
    if(!current_call_)
    {
        [self stopVideo];
        return;
    }
    
    if(current_call_)
    {
        NSString *caller_id = [current_call_ peerNumber];
        
       // if(cc)
        //{
           // caller_id = [NSString stringWithUTF8String:cc->name().c_str()];
        //}
        
        [_avCallingView setCalledNumber:caller_id];
        
        if(current_call_.direction == kIncoming)
        {
            
            [_avCallingView setCallingTimeLabel:[current_call_ support_video]? NSLocalizedString(@"Video Call Incoming", @"") : NSLocalizedString(@"Voice Call Incoming", @"")];
        } else
        {
            [_avCallingView setCallingTimeLabel:[current_call_ support_video]? NSLocalizedString(@"Video Calling", @"") : NSLocalizedString(@"Voice Calling", @"")];
        }
    }
}

-(void)setCallingStatusLabel:(NSString *)text
{
    [_avCallingView setCallingTimeLabel:text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)stopCallingUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopTimer];
        [self hangup];
        
        [self->_avCallingView stopCallingUI];
        [self performSelector:@selector(dismissCallingUIAnimated) withObject:nil afterDelay:1.0f];
        self->current_call_ = nil;
    });
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

- (void) dismissCallingUIAnimated
{
    if (![self isBeingDismissed]) {
       [self.presentingViewController dismissViewControllerAnimated:YES
            completion:nil];
    }
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval) duration
{
    [self changeRemoteVideoSize];
}

- (void)pauseVideoCall
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    if(current_call_)
    {
        _avCallingView.inCalling = NO;
        
    }
}

- (void)resumeVideoCall
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    if(current_call_ )
    {
        _avCallingView.inCalling = YES;
        [self changeRemoteVideoSize];
    }
}

-(void)startVideo {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    if(current_call_ && [current_call_ support_video])
    {
        _avCallingView.inCalling = YES;
        //add by david.xu
        //current_call_.shouldGetStats = YES;
        //_avCallingView.statsView.hidden = NO;
        /*VideoSize_t *video_size = [[SipEngineManager instance] getVideoSize];
        float bitrate = [[SipEngineManager instance] getBitrate];
        float fps = [[SipEngineManager instance] getFrameRate];
        useFrontFaceingCamera = true;
        client::MediaStream *media_stream = current_call_->media_stream();
        client::VideoStream *video_stream = media_stream->video_stream();

        [_avCallingView.localVideoView ResetDisplay];
        [_avCallingView.remoteVideoView ResetDisplay];
        
        client::RTCVideoEngine *video_engine = [[SipEngineManager instance] getRTCVideoEngine];
        int camera_orientation = video_engine->GetCameraOrientation(useFrontFaceingCamera? 1:0);
        video_stream->SetupVideoStream(useFrontFaceingCamera? 1:0, NULL,NULL,local_adapter.nativeVideoRenderer,remote_adapter.nativeVideoRenderer,(int)[self getCameraOrientation:camera_orientation],video_size->width,video_size->height,bitrate,fps);*/
        [self changeRemoteVideoSize];
    }
}

- (void)stopVideo
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    if(current_call_ && [current_call_ support_video])
    {
        _avCallingView.inCalling = NO;
        useFrontFaceingCamera = YES;
    }
}

-(NSInteger)getCameraOrientation:(NSInteger) cameraOrientation
{
    UIInterfaceOrientation displatyRotation = [[UIApplication sharedApplication] statusBarOrientation];
    NSInteger degrees = 0;
    switch (displatyRotation)
    {
        case UIInterfaceOrientationPortrait: degrees = 0; break;
        case UIInterfaceOrientationLandscapeLeft: degrees = 90; break;
        case UIInterfaceOrientationPortraitUpsideDown: degrees = 180; break;
        case UIInterfaceOrientationLandscapeRight: degrees = 270; break;
        case UIInterfaceOrientationUnknown: break;
    }
    
    NSInteger result = 0;
    if (cameraOrientation > 180) {
        result = (cameraOrientation + degrees) % 360;
    } else {
        result = (cameraOrientation - degrees + 360) % 360;
    }
    
    if(!useFrontFaceingCamera)
    {
        if(result == 0)
        {
            result = 180;
        }else if(result == 180){
            result = 0;
        }
    }
    
    return result;
}

-(void)changeRemoteVideoSize
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.1];
    
    UIInterfaceOrientation displatyRotation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (displatyRotation) {
        case UIInterfaceOrientationPortrait:
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return;
            break;
        case UIInterfaceOrientationUnknown:
            break;
    }
    
    if(current_call_ && [current_call_ support_video])
    {
    }
    [CATransaction commit];
}

static int local_fps = 0;
static int remote_fps = 0;

static int local_bitrate = 0;
static int remote_bitrate = 0;

-(void)updateNetworkInfo
{
    if(current_call_ && [current_call_ support_video])
    {
    }
}

- (void)startTimer
{
    if (!countTimer) {
        countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
    }
    if (![countTimer isValid]) {
        [countTimer fire];
    }
}
- (void)stopTimer
{
    [countTimer invalidate];
    countTimer = nil;
}

- (void)timerCount
{
    if (current_call_) {
        NSDate* curDate = [NSDate date];
        int times = 0;
        if (startDate) {
            times = (int)[curDate timeIntervalSinceDate:startDate];
        }
        else {
            startDate = [NSDate date];
        }
        
        int time_s =times %60;
        int time_m =times/60%60;
        int time_h =times/3600;
        if (time_h != 0) {
            NSString *text = [NSString stringWithFormat:@"%@%d:%@%d:%@%d",time_h<10?@"0":@"", time_h, time_m<10?@"0":@"", time_m,time_s<10?@"0":@"",time_s];
            [_avCallingView setCallingTimeLabel:text];
        }else{
            NSString *text = [NSString stringWithFormat:@"%@%d:%@%d",time_m<10?@"0":@"", time_m,time_s<10?@"0":@"",time_s];
            [_avCallingView setCallingTimeLabel:text];
        }
        if (times % 3 != 0) {
            return;
        }
        
#if 0
        CallStatistics net_stats;
        memset(&net_stats,0,sizeof(CallStatistics));
        if([SipEngineManager getSipEngine]->GetCallStatistics(net_stats)==0){
            if(net_stats.fractionLost<=10){
                [networkStateLabel setText:NSLocalizedString(@"Your network is smooth.", @"")];
                IVLog(@"Network quality: good");
                if (networkstate != 0) {
                    popoverView.hidden = NO;
                    [self performSelector:@selector(hideNetwotkState) withObject:nil afterDelay:3.0f];
                    [stateButton setImage:[UIImage imageNamed:@"btn_call.png"] forState:UIControlStateNormal];
                }
                networkstate = 0;
            } else if(net_stats.fractionLost > 10 && net_stats.fractionLost<=20){
                popoverView.hidden = NO;
                networkstate = 1;
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNetwotkState) object:nil];
                [networkStateLabel setText:NSLocalizedString(@"Your network is normal.", @"")];
                [stateButton setImage:[UIImage imageNamed:@"network_normal.png"] forState:UIControlStateNormal];
                IVLog(@"Network quality: normal");
            } else if(net_stats.fractionLost > 20){
                popoverView.hidden = NO;
                networkstate = 2;
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNetwotkState) object:nil];
                IVLog(@"Network quality: bad");
                [stateButton setImage:[UIImage imageNamed:@"network_bad.png"] forState:UIControlStateNormal];
                [networkStateLabel setText:NSLocalizedString(@"Your network is bad.", @"")];
            }
        }
#endif
    }
}

#pragma mark - ARDAppClientDelegate

- (void)call:(Call *)client
   didChangeState:(ARDCallState)state {
    switch (state) {
        case kARDCallStateConnected:
            RTCLog(@"Client connected.");
            break;
        case kARDCallStateConnecting:
            RTCLog(@"Client connecting.");
            break;
        case kARDCallStateDisconnected:
            RTCLog(@"Client disconnected.");
            //[self hangup];
            break;
    }
}

- (void)call:(Call *)client
   didChangeConnectionState:(RTCIceConnectionState)state {
    RTCLog(@"ICE state changed: %ld", (long)state);
    __weak CallingScreenViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        CallingScreenViewController *strongSelf = weakSelf;
       // strongSelf.videoCallView.statusLabel.text =
        //[strongSelf statusTextForState:state];
    });
}

- (void)call:(Call *)client
  didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
    self.localVideoTrack = localVideoTrack;
}

- (void)call:(Call *)client
  didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
    self.remoteVideoTrack = remoteVideoTrack;
}

- (void)call:(Call *)client
      didGetStats:(NSArray *)stats {
    //_avCallingView.statsView.stats = stats;
    [_avCallingView setNeedsLayout];
}

- (void)call:(Call *)client
   didCreateLocalCapturer:(RTCCameraVideoCapturer *)localCapturer {
     _avCallingView.localVideoView.captureSession = localCapturer.captureSession;
     _captureController =
     [[ARDCaptureController alloc] initWithCapturer:localCapturer callConfig:current_call_.callConfig];
     [_captureController startCapture];
}


- (void)call:(Call *)client
    didError:(NSError *)error {
    // NSString *message =
    //[NSString stringWithFormat:@"%@", error.localizedDescription];
    // [self showAlertWithMessage:message];
    [self hangup];
}


#pragma mark - Private

- (void)setLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
    if (_localVideoTrack == localVideoTrack) {
        return;
    }
    if(_localVideoTrack != nil)
        _localVideoTrack = nil;
    _localVideoTrack = localVideoTrack;
}

- (void)setRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
    if (_remoteVideoTrack == remoteVideoTrack) {
        return;
    }
    [_remoteVideoTrack removeRenderer:_avCallingView.remoteVideoView];
    _remoteVideoTrack = nil;
    [_avCallingView.remoteVideoView renderFrame:nil];
    _remoteVideoTrack = remoteVideoTrack;
    [_remoteVideoTrack addRenderer:_avCallingView.remoteVideoView];
}

- (void)switchCamera {
    [current_call_ switchCamera];
}

- (void)hangup {
    self.remoteVideoTrack = nil;
    self.localVideoTrack = nil;
    if(current_call_ != nil) {
        //[current_call_ disconnect];
        [current_call_ hangupCall];
    }
    
    if(mode_ != kVideoAnswered)
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    
    //if (![self isBeingDismissed]) {
    //  [self.presentingViewController dismissViewControllerAnimated:YES
    //                                                    completion:nil];
    //}
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {

}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {

}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {

}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    CGSize cgsize;
    return cgsize;
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {

}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {

}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {

}

- (void)setNeedsFocusUpdate {

}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    return TRUE;
}

- (void)updateFocusIfNeeded {
    
}

@end
