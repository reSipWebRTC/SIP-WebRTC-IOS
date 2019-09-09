//
//  ViewController.m
//  reSipWebRTCSDKDemo
//
//  Created by david  on 2019/7/31.
//  Copyright © 2019 reSipWebRTC. All rights reserved.
//

#import "ViewController.h"
#import "reSipWebRTCSDK/SipEngineManager.h"
#import "reSipWebRTCSDK/CallConfig.h"

@interface ViewController ()

@end

@implementation ViewController {
    Account *current_account;
    Call *current_call;
}

@synthesize calling_screen_view;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    current_account = nil;
    [[SipEngineManager instance] setSipEngineRegistrationDelegate:self];
    [[SipEngineManager instance] setSipEngineCallDelegate:self];
    
    calling_screen_view = [self.storyboard instantiateViewControllerWithIdentifier:@"CallingScreenViewController"];
    //[calling_screen_view setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
}


- (void)OnCallConnected:(Call *)call withVideoChannel:(BOOL)video_enabled withDataChannel:(BOOL)data_enabled {
    [calling_screen_view setCallingMode:video_enabled? kVideoAnswered : kAudioAnswered];
}

- (void)OnCallEnded:(Call *)call {
    [calling_screen_view setCallingStatusLabel:NSLocalizedString(@"Hangup", @"")];
    [calling_screen_view setCurrentCall:nil];
    [calling_screen_view stopCallingUI];
}

- (void)OnCallFailed:(Call *)call withErrorCode:(int)error_code reason:(NSString *)reason {
    [calling_screen_view setCallingStatusLabel:[NSString stringWithFormat:NSLocalizedString(@"Call failed, [%d]",@""),error_code]];
    if(calling_screen_view && [calling_screen_view isVideoCalling:call])
    {
        [calling_screen_view stopVideo];
    }
    
    [calling_screen_view setCurrentCall:nil];
    [calling_screen_view stopCallingUI];
}

- (void)OnCallPaused:(Call *)call {
    
}

/*外呼正在处理*/
- (void)OnCallProcessing:(Call *)call {
    [calling_screen_view setCallingStatusLabel:NSLocalizedString(@"Calling ...", @"")];
}

- (void)OnCallReceivedUpdateRequest:(BOOL)has_video {
    
}

- (void)OnCallResume:(Call *)call {
    
}

/*对方振铃*/
- (void)OnCallRinging:(Call *)call {
    [calling_screen_view setCallingStatusLabel:NSLocalizedString(@"Ringing", @"")];
}

- (void)OnCallUpdated:(BOOL)has_video {
    
}

- (void)OnNewIncomingCall:(Call *)call caller:(NSString *)caller video_call:(BOOL)video_call {
    [calling_screen_view setCurrentCall:call];
    [calling_screen_view setCallingMode:video_call? kVideoRinging : kAudioRinging];
    [self showCallingViewController:video_call playRinging:NO];
}

- (void)OnNewOutgoingCall:(Call *)call caller:(NSString *)caller video_call:(BOOL)video_call {
    [calling_screen_view setCurrentCall:call];
    [calling_screen_view setCallingMode:video_call? kVideoCalling : kAudioCalling];
    [self showCallingViewController:video_call playRinging:NO];
}

- (void)OnDtmfEvent:(int)callId dtmf:(int)dtmf duration:(int)duration up:(int)up
{
    
}


-(void)showCallingViewController:(BOOL)video_call
                     playRinging:(BOOL)play_ringing
{
    [self presentViewController:(UIViewController *)calling_screen_view animated:YES completion:nil];

    if(play_ringing)
    {
        //[[UserSoundsPlayerUtil instance] playRinging];
        //[[UserSoundsPlayerUtil instance] playVibrate:YES];
        [calling_screen_view setCallingMode:video_call? kVideoRinging : kAudioRinging];
    }
}

- (void)OnRegisterationFailed:(Account *)account withErrorCode:(int)code withErrorReason:(NSString *)reason {
    
}

- (void)OnRegistrationCleared:(Account *)account {
    
}

- (void)OnRegistrationProgress:(Account *)account {
    
}

- (void)OnRegistrationSucess:(Account *)account {
    NSLog(@"OnRegistrationSucess");
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    CGSize cGSize = {0, 0};
    return cGSize;
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
    return true;
}

- (void)updateFocusIfNeeded {
    
}

- (IBAction)RegisterButter:(id)sender {
    
    AccountConfig *accountConfig = [[AccountConfig alloc] init];
    accountConfig.username = @"1103";
    accountConfig.password = @"4123";
    accountConfig.server = @"39.108.167.93:5769";
    accountConfig.proxy = @"39.108.167.93:5769";
    accountConfig.trans_type = kTCP;
    accountConfig.display_name = @"1103";
    
    current_account = [[SipEngineManager instance] createAccount];
    [current_account register:accountConfig];
}

- (IBAction)CallButter:(id)sender {
    CallConfig *callConfig = [[CallConfig alloc]init];
    Call* current_call = [[SipEngineManager instance] createCall:current_account.accId];
    [current_call makeCall:@"1105" callConfig:callConfig];
   // [self OnNewOutgoingCall:current_call caller:[current_call peerNumber] video_call:YES];
}

- (IBAction)SettingsButton:(id)sender {
    ARDSettingsViewController *settingsController =
    [[ARDSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped
                                       settingsModel:[[CallConfig alloc] init]
                                       accountConfig:[[AccountConfig alloc] init]
    ];
    
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:settingsController];
    [self presentViewControllerAsModal:navigationController];
}

- (void)presentViewControllerAsModal:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
