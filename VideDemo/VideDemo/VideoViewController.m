//
//  VideoViewController.m
//  UcpSDK
//
//  Created by mac on 2018/1/6.
//  Copyright © 2018年 longshine. All rights reserved.
//

#import "VideoViewController.h"
#import <WebRTC/RTCCameraPreviewView.h>
#import <WebRTC/RTCVideoRenderer.h>
#import <WebRTC/RTCEAGLVideoView.h>
#import <reSipWebRTCSDK/Call.h>
#import <reSipWebRTCSDK/ARDCaptureController.h>
#import <WebRTC/RTCVideoTrack.h>
#import <reSipWebRTCSDK/SipEngineManager.h>
#import "AppDelegate.h"

@interface VideoViewController () <ARDRtcCallDelegate, RTCVideoViewDelegate,SipEngineUICallDelegate,SipEngineUIRegistrationDelegate>
{
    ARDCaptureController *_captureController;
    RTCVideoTrack *_remoteVideoTrack;
    BOOL useFrontFaceingCamera;

    RTCCameraPreviewView *_localVideoView;
    RTCEAGLVideoView *_remoteVideoView;
    
    //当前呼叫上下文 注册返回
    //Account* _currentCount;
    //呼叫参数
    CallParams* _callParams;
    //呼叫上下文
    
    Call* _currentCall;
    
    UIButton * _makecallBtn;
    
    UIButton * _hangupBtn;
}
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     useFrontFaceingCamera = NO;
    _localVideoView = [[RTCCameraPreviewView alloc]initWithFrame:CGRectMake(20, 30, 180, 120)];
    _localVideoView.backgroundColor = [UIColor redColor];
    
    //_remoteVideoView = [[RTCEAGLVideoView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    _remoteVideoView =[[RTCEAGLVideoView alloc]initWithFrame:CGRectMake(20, 200, 360, 240)];
    _remoteVideoView.backgroundColor = [UIColor redColor];
    _remoteVideoView.delegate = self;
    
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(20, 500, 60, 30)];
    [btn setTitle:@"切换流" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(siwtichCamera) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    
     _makecallBtn= [[UIButton alloc]initWithFrame:CGRectMake(100, 500, 60, 30)];
    [_makecallBtn setTitle:@"呼叫" forState:UIControlStateNormal];
    [_makecallBtn addTarget:self action:@selector(makeCallClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _makecallBtn];
    
     _hangupBtn= [[UIButton alloc]initWithFrame:CGRectMake(180, 500, 60, 30)];
    [_hangupBtn setTitle:@"挂断" forState:UIControlStateNormal];
    [_hangupBtn addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _hangupBtn];
    
    [_hangupBtn setHidden:YES];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    //NSLog(@"video frame widht:%f height:%f",self.view.frame.size.width, self.view.frame.size.height);
    self.view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_localVideoView];
    [self.view addSubview:_remoteVideoView];
    
    [self initParams];
    
    [self registerTiantangCloudAccount];
    
    //调用转屏代码
    //[UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
    
}

-(void) viewWillAppear:(BOOL)animated {
    NSLog(@"=========viewWillAppear:(BOOL)animated========");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackgroundNotification:) name:@"enterBackground" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActiveNotification:) name:@"becomeActive" object:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"becomeActive" object:nil];
}

-(void)appWillEnterBackgroundNotification:(NSNotification *)notification
{
    NSLog(@"=======appWillEnterBackgroundNotification=====");
    //if(![[SipEngineManager instance] InCalling]) {
          //if(self->_currentCount)
          //{
             //[_currentCount unregister];
             //self->_currentCount = nil;
          //}
          
        //[[SipEngineManager instance] stopSipEngineCore];
    //}
}

-(void)appBecomeActiveNotification:(NSNotification *)notification
{
    NSLog(@"=======appBecomeActiveNotification=====");
    //[[SipEngineManager instance] startSipEngineCore];
    [[SipEngineManager instance] setSipEngineRegistrationDelegate:self];
    [[SipEngineManager instance] setSipEngineCallDelegate:self];
    
    /*if(!self->_currentCount) {
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             AccountConfig *accountConfig = [[AccountConfig alloc] init];
             accountConfig.username = @"1120";
             accountConfig.password = @"4321";
             accountConfig.server = @"222.211.83.186:15380";
             accountConfig.proxy = @"222.211.83.186:15380";
             accountConfig.trans_type = kTCP;
             accountConfig.display_name = @"david.xu";
             self->_currentCount = [[SipEngineManager instance] registerSipAccount:accountConfig];
      // });
    }*/
}

-(void)initParams
{
    _callParams = [[CallParams alloc]init];

    /*NSString* video_size = @"vga";
    if([video_size isEqualToString:@"qvga"])
    {
        [_callParams storeVideoResolutionConfig:@"320x240"];
        [_callParams storeMaxBitrateConfig:[NSNumber numberWithInt:256]];
        [_callParams storeVideoFpsConfig:[NSNumber numberWithInt:15]];
    }else if([video_size isEqualToString:@"cif"])
    {
        [_callParams storeVideoResolutionConfig:@"352x288"];
        [_callParams storeMaxBitrateConfig:[NSNumber numberWithInt:384]];
        [_callParams storeVideoFpsConfig:[NSNumber numberWithInt:15]];
    }else if([video_size isEqualToString:@"vga"])
    {
        [_callParams storeVideoResolutionConfig:@"640x480"];
        [_callParams storeMaxBitrateConfig:[NSNumber numberWithInt:512]];
        [_callParams storeVideoFpsConfig:[NSNumber numberWithInt:15]];
    }else if([video_size isEqualToString:@"hd"]){
        [_callParams storeVideoResolutionConfig:@"1280x720"];
        [_callParams storeMaxBitrateConfig:[NSNumber numberWithInt:1024]];
        [_callParams storeVideoFpsConfig:[NSNumber numberWithInt:20]];
    }*/

    //NSString* videoCodecInfo=@"VP8";
      RTCVideoCodecInfo *videoCodecInfo = [[RTCVideoCodecInfo alloc] initWithName:@"H264 (Baseline)"];
      // RTCVideoCodecInfo *rtcVideoCodecInfo = [[RTCVideoCodecInfo alloc] initWithName:videoCodecInfo];
       [_callParams storeVideoCodecConfig:videoCodecInfo];


    NSString* stun_server = @"stun:222.211.83.186:3678";
    NSString* turn_server = @"turn:222.211.83.186:3678";
    NSString* username = @"user";
    NSString* credential = @"paradise";
    _callParams.isVideoCall = TRUE;
    
    //[_callParams addIceServer:stun_server username:@"" credential:@""];
    [_callParams addIceServer:turn_server username:username credential:credential];
}

-(void)registerTiantangCloudAccount
{
    //初始化
    [[SipEngineManager instance] Initialize];

    //SipEngineUICallDelegate
    [[SipEngineManager instance] setSipEngineCallDelegate:self];
    //设置注册代理
    [[SipEngineManager instance] setSipEngineRegistrationDelegate :self];

    AccountConfig *accountConfig = [[AccountConfig alloc]init];
    accountConfig.username = @"1120";
    accountConfig.password = @"4321";
    accountConfig.display_name = @"zhaojinhua";
    accountConfig.server = @"222.211.83.186:15380";
    accountConfig.proxy = @"222.211.83.186:15380";
    accountConfig.trans_type = kTCP;

    //if( _currentCount != nil)
    //{
        //[_currentCount unregister];
    //}
    //_currentCount = [[SipEngineManager instance] registerSipAccount:accountConfig];
}

-(void)siwtichCamera
{
        static BOOL muteVideo = NO;
    if( _currentCall )
    {
        /*if( muteVideo )
        {
            [_currentCall muteVideo];
            NSLog(@"muteVideo");
        }
        else
        {
            [_currentCall unmuteVideo];
            NSLog(@"unmuteVideo");
        }
        
        muteVideo = !muteVideo;*/
        useFrontFaceingCamera = !useFrontFaceingCamera;
        [_captureController switchCamera];
    }
}


-(void)makeCallClick
{
     AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
    
    [[SipEngineManager instance] makeCall:[appDelegate.currentCount getAccId] calleeUri:@"89055" callParams:_callParams];
}

-(void)hangupClick
{
    if( _currentCall )
    {
        [_currentCall hangupCall];
        _currentCall = nil;
    }

}


#pragma mark  SipEngineUIRegistrationDelegate "注册回调""
-(void) OnRegistrationProgress:(Account *) account;
{
    NSLog(@"===%s===",__func__);
}

-(void) OnRegistrationSucess:(Account *) account;
{
    NSLog(@"===%s, accout:%@===",__func__,account);
}

-(void) OnRegistrationCleared:(Account *) account;
{
    NSLog(@"===%s===",__func__);
}

-(void) OnRegisterationFailed:(Account *) account
                withErrorCode:(int) code
              withErrorReason:(NSString *) reason
{
    NSLog(@"===%s===",__func__);
    NSLog(@"注册失败:%@", reason);

}

#pragma mark SipEngineUICallDelegate 呼叫回调

- (void)OnNewOutgoingCall:(Call *)call caller:(NSString *)caller video_call:(BOOL)video_call
{
    NSLog(@"===%s===", __func__);
    //保存当前呼叫上下文
    _currentCall = call;
    // 设置ARDRtcCallDelegate
    _currentCall.rtcDelegate = self;
}

- (void)OnCallConnected:(Call *)call withVideoChannel:(BOOL)video_enabled withDataChannel:(BOOL)data_enabled
{
    NSLog(@"===%s===", __func__);
    
    //这个回调认为入会成功
    [_hangupBtn setHidden:NO];
    [_makecallBtn setHidden:YES];
    //[_makecallBtn setEnabled:NO];
    
    //[self  presentViewController:_videoView animated:YES completion:nil];
    
}


//呼叫失败回调 或者挂断的回调
- (void)OnCallEnded:(Call *)call
{
     NSLog(@"===%s===", __func__);
    [[SipEngineManager instance] setVideoFrameInfoDelegate:nil];
    [_makecallBtn setHidden:NO];
    [_hangupBtn setHidden:YES];
    
}

-(void)OnCallFailed:(Call *)call withErrorCode:(int)error_code reason:(NSString *)reason{
     NSLog(@"===%s===", __func__);
    NSLog(@"error reason:%@", reason);
    [[SipEngineManager instance] setVideoFrameInfoDelegate:nil];
    [_makecallBtn setHidden:NO];
    [_hangupBtn setHidden:YES];

}


#pragma  mark -- ARDRtcCallDelegate

- (void)call:(Call *)client didChangeConnectionState:(RTCIceConnectionState)state {
    
}

- (void)call:(Call *)client didChangeState:(ARDCallState)state {
    
}

- (void)call:(Call *)client didCreateLocalCapturer:(RTCCameraVideoCapturer *)localCapturer {
    NSLog(@"===%s===", __func__);
    _localVideoView.captureSession = localCapturer.captureSession;
    _captureController = [[ARDCaptureController alloc]initWithCapturer:localCapturer callParams:client.callParams];
    [_captureController startCapture];
    
}

- (void)call:(Call *)client didError:(NSError *)error {
    NSLog(@"===%s===", __func__);
}

- (void)call:(Call *)client didGetStats:(NSArray *)stats {
    //NSLog(@"===%s===", __func__);
}

- (void)call:(Call *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
    NSLog(@"===%s===", __func__);
}

- (void)call:(Call *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
    NSLog(@"===%s===", __func__);
    //[remoteVideoTrack addRenderer:_remoteVideoView];
    if(_remoteVideoTrack == remoteVideoTrack)
        return;
    [_remoteVideoTrack removeRenderer:_remoteVideoView];
    _remoteVideoTrack = nil;
    [_remoteVideoView renderFrame:nil];
    _remoteVideoTrack = remoteVideoTrack;
    [_remoteVideoTrack addRenderer:_remoteVideoView];
}

- (void)viewWillLayoutSubviews{
    self.view.frame = CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width , [[UIScreen mainScreen] bounds].size.height);
}

#pragma mark - RTCEAGLVideoViewDelegate
- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size {
}



@end
