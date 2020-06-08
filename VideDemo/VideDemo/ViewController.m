//
//  ViewController.m
//  VideDemo
//
//  Created by longshine on 2020/2/24.
//  Copyright © 2020 com.longshine. All rights reserved.
//

#import "ViewController.h"

#import "VideoViewController.h"

#import <reSipWebRTCSDK/SipEngineManager.h>

@interface ViewController ()<SipEngineUICallDelegate,SipEngineUIRegistrationDelegate>
{
    //会议界面
    VideoViewController * _videoView;
    //当前呼叫上下文 注册返回
    Account* _currentCount;
    //呼叫参数
    CallParams* _callParams;
    Call* _currentCall;
    
}
- (IBAction)testMakeCall:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //创建显示 视频画面的viewController
    CGRect screenRec = [UIScreen mainScreen].bounds;
    _videoView = [[VideoViewController alloc]init];
    //_videoView.modalPresentationStyle =UIModalPresentationFullScreen;
    
    NSLog(@"bunds width:%f, height:%f", screenRec.size.width, screenRec.size.height );
    self.view.backgroundColor = [UIColor greenColor];
    
    [self initParams];
    
    [self registerTiantangCloudAccount];

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

    if( _currentCount != nil)
    {
        [_currentCount unregister];
    }
    _currentCount = [[SipEngineManager instance] registerSipAccount:accountConfig];
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
    _currentCall.rtcDelegate = _videoView;
}

- (void)OnCallConnected:(Call *)call withVideoChannel:(BOOL)video_enabled withDataChannel:(BOOL)data_enabled
{
    NSLog(@"===%s===", __func__);
    
    //[self  presentViewController:_videoView animated:YES completion:nil];
    
}


//呼叫失败回调 或者挂断的回调
- (void)OnCallEnded:(Call *)call
{
     NSLog(@"===%s===", __func__);
    if (_videoView)
    {
        NSLog(@"close video view");
        [_videoView dismissViewControllerAnimated:NO completion:nil];
        _videoView = nil;
    }

}

-(void)OnCallFailed:(Call *)call withErrorCode:(int)error_code reason:(NSString *)reason{
     NSLog(@"===%s===", __func__);
    NSLog(@"error reason:%@", reason);
}


- (IBAction)testMakeCall:(id)sender {
    [self presentViewController:(UIViewController *)_videoView animated:YES completion:nil];
    [[SipEngineManager instance] makeCall:[_currentCount getAccId] calleeUri:@"89055" callParams:_callParams];
}
@end
