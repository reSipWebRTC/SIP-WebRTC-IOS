#import "ARDVideoCallView.h"
#import <AVFoundation/AVFoundation.h>
#import "DDPageControl.h"
#import "CommonTypes.h"
#import <WebRTC/RTCEAGLVideoView.h>
#import <WebRTC/RTCMTLVideoView.h>
#import "../Utils/CustomButton.h"
#import "../Utils/UIImage+ARDUtilities.h"

@interface ARDVideoCallView () <RTCVideoViewDelegate>
@end

@implementation ARDVideoCallView {
    UIButton *voiceAnswerButton;
    UIButton *videoAnswerButton;
    UIButton *hangupButton;
    
    UILabel *answerButtonLabel;
    UILabel *hangupButtonLabel;
    UIButton *muteMicButton;
    UIButton *cameraSwitchButton;
    UIButton *speakerButton; //扬声器
    UILabel *speakerButtonLabel;
    UIButton *turnOffCameraButton; //关闭本地显示
    UILabel *turnOffCameraLabel;
    UIButton *selectContactButton; //联系人查看
    UILabel *selectContactButtonLabel;
    
    UIImageView *contactHeadImage; //联系人头像
    UILabel *callingNumberLabel; //被叫号码 或 名称
    UILabel *callingTimeLabel; //呼叫时间或状态显示
    UIImageView  *callingNetowkrQuality;//网络质量
    
    CGSize localVideoSize;
    CGSize remoteVideoSize;
    UIScrollView *videoCallingScrollView ;
    DDPageControl *videoCallingPageControl ;
    
    /*调试信息*/
    UIView  *debugView;
    UILabel *debugVideoSizeLabel;
    UILabel *debugBitRateLabel;
    UILabel *debugLostAndDelayTxLabel;
    
    UIView *videoCallingViewPageOne;
    UIView *videoCallingViewPageTwo;
    
    UIView *videoCallingCameraPreView;
    UIView *callingKeyBoardView;
    
    UIButton *keyBoardHiddenButton;
    UIButton *keyBoardShowButton;
    UILabel *keyBoardLabel;
    UILabel *keyBoardNumLabel;
    BOOL showKeyBoard;
}

@synthesize statusLabel = _statusLabel;
@synthesize localVideoView = _localVideoView;
@synthesize remoteVideoView = _remoteVideoView;
@synthesize delegate = _delegate;
@synthesize inCalling;
@synthesize hidenToolWidgets;
@synthesize mode;
@synthesize session;
@synthesize preLayer;
@synthesize videoSizeLabel = debugVideoSizeLabel;
@synthesize bitRateInfoLabel = debugBitRateLabel;
@synthesize packetLostLabel = debugLostAndDelayTxLabel;

-(void)setARDVideoCallingMode:(enum ARDVideoCallingMode) new_mode
{
    self.mode = new_mode;
    /*切换呼叫模式*/
    [self layoutSubviews];
    
    if(mode == kVideoAnswered || mode == kAudioAnswered)
    {
        showKeyBoard = NO;
        [self setCallingTimeLabel:@"00:00"];
        [keyBoardNumLabel setText:@""];
    }

#if 0
    if(mode == kVideoRinging || mode == kVideoCalling)
    {
        [self startVideoPreViewing];
    }
    
    if(mode == kVideoAnswered)
    {
        [self stopVideoPreViewing];
    }
#endif
}

-(void)onRemoteVideoViewClicked:(id)sender
{
    NSLog(@"UIViewClick(sender = remote)");
    hidenToolWidgets = !hidenToolWidgets;
    [self setToolsHidden];
}

-(void)onLocalVideoViewClicked:(id)sender
{
    NSLog(@"UIViewClick(sender = local)");
    
    inCalling = YES;
    [self layoutIfNeeded];
    
    [videoCallingPageControl setHidden:NO];
    [videoCallingScrollView setHidden:NO];
    [hangupButton setHidden:NO];
    [muteMicButton setHidden:NO];
    [cameraSwitchButton setHidden:NO];
}

-(void)onPageUIViewClicked:(id)sender
{
    NSLog(@"onPageUIViewClicked(sender = page)");
    hidenToolWidgets = !hidenToolWidgets;
    [self setToolsHidden];
}

- (void) setToolsHidden
{
    NSLog(@"setToolsHidden(sender = page)");
    if(hidenToolWidgets)
    {
        [videoCallingPageControl setHidden:YES];
        [videoCallingScrollView setHidden:YES];
        [hangupButton setHidden:YES];
        [muteMicButton setHidden:YES];
        [cameraSwitchButton setHidden:YES];
        //NSLog(@"SetupToolsControl(hidden = YES)");
    }else{
        [videoCallingPageControl setHidden:NO];
        [videoCallingScrollView setHidden:NO];
        [hangupButton setHidden:NO];
        [muteMicButton setHidden:NO];
        [cameraSwitchButton setHidden:NO];
        //NSLog(@"SetupToolsControl(hidden = NO)");
    }
}

-(void)setCalledNumber:(NSString *)text
{
    [callingNumberLabel setText:text];
/*
    CGSize fontSize = [callingNumberLabel.text sizeWithFont:callingNumberLabel.font];
    CGPoint center = callingNumberLabel.bounds.origin;
    callingNumberLabel.frame = CGRectMake(center.x,center.y,fontSize.width,fontSize.height);
*/
}

-(void)setCallingTimeLabel:(NSString *)text
{
    [callingTimeLabel setText:text];
/*
    CGSize fontSize = [callingTimeLabel.text sizeWithFont:callingTimeLabel.font];
    CGPoint center = callingTimeLabel.bounds.origin;
    callingTimeLabel.frame = CGRectMake(center.x,center.y,fontSize.width,fontSize.height);
*/
}

- (void) onButtonTouchDown:(id) sender
{
    NSLog(@"onButtonTouchDown(sender = page)");
    UIButton *button = sender;
    if(button.tag == ACTION_MUTE
       || button.tag == ACTION_SWITCH_CAMERA_OFF
       || button.tag == ACTION_SWITCH_SPEAKER)
    {
        BOOL selected = !button.selected;
        [button setSelected:selected];
    }
    
    if(button.tag >= 0 && button.tag <= 12)
    {
        NSInteger num = button.tag;
        NSString* charater = [NSString stringWithFormat:@"%d", (int)num];
        if (num == 11) {
            charater = @"*";
        }
        else if (num == 12) {
            charater = @"#";
        }
        [keyBoardNumLabel setText:[keyBoardNumLabel.text stringByAppendingFormat:@"%@", charater]];
        
        [_delegate videoCallViewDidDtmfClicked:charater];
    }
}

-(void)stopCallingUI
{
    inCalling = NO;
    hidenToolWidgets = NO;
    if(mode == kAudioAnswered && showKeyBoard)
    {
        [speakerButton setHidden:NO];
        [hangupButton setHidden:NO];
        [muteMicButton setHidden:NO];
        
        [keyBoardLabel setHidden:NO];
        [keyBoardHiddenButton setHidden:NO];
        [contactHeadImage setHidden:NO];
        [callingNumberLabel setHidden:NO];
        [callingTimeLabel setHidden:NO];
        [callingKeyBoardView setHidden:YES];
        [keyBoardShowButton setHidden:YES];
        [keyBoardNumLabel setHidden:YES];
    }
    [muteMicButton setSelected:NO];
    [turnOffCameraButton setSelected:NO];
    [speakerButton setSelected:NO];
    [_localVideoView setHidden:YES];
    [_remoteVideoView setHidden:YES];
    [self disableAllWidgets];
}

- (void) onButtonUpInSide:(id) sender
{
    NSLog(@"onButtonUpInSide(sender = page)");
    UIButton *button = sender;
    if(button.tag == ACTION_HANGUP)
    {
        [self stopCallingUI];
        [_delegate videoCallViewDidHangup];
        //[_localVideoView ResetDisplay];
        //[_remoteVideoView ResetDisplay];
    }
    
    if(button.tag == ACTION_MUTE){
        [_delegate videoCallViewDidMute:button.selected];
    }
    
    if(button.tag == ACTION_SWITCH_CAMERA){
        [_delegate videoCallViewDidSwitchCamera];
    }
    
    if(button.tag == ACTION_SELECT_CONTACTS)
    {
        [_delegate videoCallViewDidSelectContacts];
    }
    
    if(button.tag == ACTION_VOICE_ANSWER || button.tag == ACTION_VIDEO_ANSWER)
    {
        [_delegate videoCallViewDidAnswer];
    }
    
    if(button.tag == ACTION_SWITCH_CAMERA_OFF)
    {
        [_delegate videoCallViewDidTurnCameraOff:button.selected];
    }
    
    if(button.tag == ACTION_SWITCH_SPEAKER)
    {
        [_delegate videoCallViewDidSpeaker:button.selected];
    }
    
    if(button.tag == ACTION_KEYBOARD_HIDDEN || button.tag == ACTION_KEYBOARD_SHOW)
    {
        CATransition *animation = [CATransition animation];
       // animation.delegate = self;
        animation.duration = 0.2;  // 动画持续时间(秒)
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];;
        animation.type = kCATransitionFade;//淡入淡出效果
        
        showKeyBoard = !showKeyBoard;
        [self layoutSubviews];
        [[self layer] addAnimation:animation forKey:@"animation"];
    }
}

-(void)addButtonToView:(UIButton*)button
{
    [button addTarget:self
                             action:@selector(onButtonTouchDown:)
                   forControlEvents:UIControlEventTouchDown];
    
    [button addTarget:self
                             action:@selector(onButtonUpInSide:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
}

- (instancetype)initWithFrame:(CGRect)frame {
    NSLog(@"=======initWithFrame=111====");
    if (self = [super initWithFrame:frame])
    {
#if defined(RTC_SUPPORTS_METAL)
        _remoteVideoView = [[RTCMTLVideoView alloc] initWithFrame:CGRectZero];
#else
        NSLog(@"=======initWithFrame==222===");
        RTCEAGLVideoView *remoteView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectZero];
        remoteView.delegate = self;
        _remoteVideoView = remoteView;
#endif
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRemoteVideoViewClicked:)];
        [_remoteVideoView addGestureRecognizer:tapGesture];
        
        _localVideoView = [[RTCCameraPreviewView alloc] initWithFrame:CGRectZero];
        //_localVideoView.dragEnable = YES;
        //_localVideoView.transform = CGAffineTransformMakeScale(-1, 1); //左右翻转
        //_localVideoView.delegate = self;
        UITapGestureRecognizer*tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLocalVideoViewClicked:)];
        [_localVideoView addGestureRecognizer:tapGesture2];
        [_localVideoView.layer setBorderWidth:1.0f];
        [_localVideoView.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        hangupButton = [CustomButton addButton:@"call-decline.png"
                        backgroundColor:buttonRedColor
                              mainColor:[UIColor clearColor]
                         highlightedColor:[UIColor grayColor]
                              setBorder:NO
                                    tag:ACTION_HANGUP
                            button_size:kDefaultButtonSize];
        
        [self addButtonToView:hangupButton];
        
        voiceAnswerButton = [CustomButton addButton:@"call-voiceanswer.png"
                        backgroundColor:buttonGreenColor
                              mainColor:[UIColor clearColor]
                       highlightedColor:[UIColor grayColor]
                              setBorder:NO
                                    tag:ACTION_VOICE_ANSWER
                            button_size:kDefaultButtonSize];
        
        [self addButtonToView:voiceAnswerButton];
        
        videoAnswerButton = [CustomButton addButton:@"call-videoanswer.png"
                             backgroundColor:buttonGreenColor
                                   mainColor:[UIColor clearColor]
                            highlightedColor:[UIColor grayColor]
                                   setBorder:NO
                                         tag:ACTION_VOICE_ANSWER
                                 button_size:kDefaultButtonSize];
        
        [self addButtonToView:videoAnswerButton];
        
        muteMicButton = [CustomButton addButton:@"call-mute.png"
                      backgroundColor:[UIColor grayColor]
                            mainColor:[UIColor whiteColor]
                            highlightedColor:[UIColor blackColor]
                            setBorder:YES
                                  tag:ACTION_MUTE
                          button_size:kDefaultButtonSize];
        
        [self addButtonToView:muteMicButton];

        cameraSwitchButton = [CustomButton addButton:@"call-switch.png"
                        backgroundColor:[UIColor grayColor]
                              mainColor:[UIColor whiteColor]
                              highlightedColor:[UIColor blackColor]
                              setBorder:YES
                                    tag:ACTION_SWITCH_CAMERA
                            button_size:kDefaultButtonSize];
        
        [self addButtonToView:cameraSwitchButton];
        
        speakerButton = [CustomButton addButton:@"call-videospeaker.png"
                        backgroundColor:[UIColor grayColor]
                              mainColor:[UIColor whiteColor]
                       highlightedColor:[UIColor blackColor]
                              setBorder:YES
                                    tag:ACTION_SWITCH_SPEAKER
                            button_size:kDefaultButtonSize];
        
        [self addButtonToView:speakerButton];
        
        turnOffCameraButton = [CustomButton addButton:@"call-cameraoff.png"
                         backgroundColor:[UIColor grayColor]
                               mainColor:[UIColor whiteColor]
                        highlightedColor:[UIColor blackColor]
                               setBorder:YES
                                     tag:ACTION_SWITCH_CAMERA_OFF
                             button_size:kDefaultButtonSize];
        
        [self addButtonToView:turnOffCameraButton];
        
        selectContactButton = [CustomButton addButton:@"call-contacts.png"
                               backgroundColor:[UIColor grayColor]
                                     mainColor:[UIColor whiteColor]
                              highlightedColor:[UIColor blackColor]
                                     setBorder:YES
                                           tag:ACTION_SELECT_CONTACTS
                                   button_size:kDefaultButtonSize];
        
        selectContactButton.enabled = NO;
        
        [self addButtonToView:selectContactButton];
        
        //keyBoardHiddenButton = [CustomButton addCleanButton:@"tab-keypad-selected.png" backgroundColor:[UIColor whiteColor] mainColor:[UIColor whiteColor]  setBorder:YES tag:ACTION_KEYBOARD_SWITCH button_size:kDefaultButtonSize];
        
        keyBoardHiddenButton = [CustomButton addButton:@"tab-keypad-selected.png"
                backgroundColor:[UIColor grayColor]
                      mainColor:[UIColor whiteColor]
               highlightedColor:[UIColor blackColor]
                      setBorder:YES
                            tag:ACTION_KEYBOARD_HIDDEN
                    button_size:kDefaultButtonSize];
        
        [self addButtonToView:keyBoardHiddenButton];
        
        
        keyBoardShowButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [keyBoardShowButton setTitle:@"Back" forState:UIControlStateNormal];
        keyBoardShowButton.tag = ACTION_KEYBOARD_SHOW;
        [self addButtonToView:keyBoardShowButton];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.font = [UIFont systemFontOfSize:16];;
        _statusLabel.textColor = [UIColor whiteColor];
    
        callingNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [callingNumberLabel setText:@"+8618627935526"];
        callingNumberLabel.font = [UIFont systemFontOfSize:28];
        [callingNumberLabel setAlpha:0.9f];
        // set some label properties
        [callingNumberLabel setTextAlignment: NSTextAlignmentCenter] ;
        [callingNumberLabel setTextColor: [UIColor whiteColor]] ;
        [callingNumberLabel setBackgroundColor: [UIColor clearColor]] ;
        
        CGSize fontSize = [callingNumberLabel.text sizeWithFont:callingNumberLabel.font];
        callingNumberLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width,fontSize.height);
        
        callingTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [callingTimeLabel setTextAlignment:NSTextAlignmentCenter];
        callingTimeLabel.font = [UIFont systemFontOfSize:16];
        callingTimeLabel.textColor = [UIColor whiteColor];
        [callingTimeLabel setAlpha:0.9f];
        [callingTimeLabel setText:NSLocalizedString(@"Calling ...", @"")];
        fontSize = [callingTimeLabel.text sizeWithFont:callingNumberLabel.font];
        callingTimeLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width,fontSize.height);
        [callingTimeLabel setBackgroundColor: [UIColor clearColor]] ;
        
        
        keyBoardNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [keyBoardNumLabel setTextAlignment:NSTextAlignmentCenter];
        keyBoardNumLabel.font = [UIFont systemFontOfSize:32];
        keyBoardNumLabel.textColor = [UIColor whiteColor];
        [keyBoardNumLabel setAlpha:0.9f];
        [keyBoardNumLabel setText:NSLocalizedString(@"", @"")];
        NSString *num = @"12345678901234567890";
        fontSize = [num sizeWithFont:callingNumberLabel.font];
        keyBoardNumLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width,fontSize.height);
        [keyBoardNumLabel setBackgroundColor: [UIColor clearColor]] ;
        keyBoardNumLabel.adjustsFontSizeToFitWidth = YES;
        keyBoardNumLabel.minimumFontSize = 6;
        
        [self addSubview:keyBoardNumLabel];
        
        speakerButtonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [speakerButtonLabel setTextAlignment:NSTextAlignmentCenter];
        speakerButtonLabel.font = [UIFont systemFontOfSize:16];
        speakerButtonLabel.textColor = [UIColor whiteColor];
        speakerButtonLabel.text = NSLocalizedString(@"Speaker", @"");
        speakerButtonLabel.backgroundColor = [UIColor clearColor];
        
        turnOffCameraLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [turnOffCameraLabel setTextAlignment:NSTextAlignmentCenter];
        turnOffCameraLabel.textColor = [UIColor whiteColor];
        turnOffCameraLabel.font = [UIFont systemFontOfSize:16];
        turnOffCameraLabel.text = NSLocalizedString(@"Camera Off", @"");
        turnOffCameraLabel.backgroundColor = [UIColor clearColor];
        
        selectContactButtonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [selectContactButtonLabel setTextAlignment:NSTextAlignmentCenter];
        selectContactButtonLabel.font = [UIFont systemFontOfSize:16];
        selectContactButtonLabel.textColor = [UIColor whiteColor];
        selectContactButtonLabel.text = NSLocalizedString(@"Contacts", @"");
        selectContactButtonLabel.backgroundColor = [UIColor clearColor];
        
        answerButtonLabel =  [[UILabel alloc] initWithFrame:CGRectZero];
        [answerButtonLabel setTextAlignment:NSTextAlignmentCenter];
        answerButtonLabel.font = [UIFont systemFontOfSize:16];
        answerButtonLabel.textColor = [UIColor whiteColor];
        answerButtonLabel.text = NSLocalizedString(@"Answer", @"");
        answerButtonLabel.backgroundColor = [UIColor clearColor];
        
        hangupButtonLabel =  [[UILabel alloc] initWithFrame:CGRectZero];
        [hangupButtonLabel setTextAlignment:NSTextAlignmentCenter];
        hangupButtonLabel.font = [UIFont systemFontOfSize:16];
        hangupButtonLabel.textColor = [UIColor whiteColor];
        hangupButtonLabel.text = NSLocalizedString(@"Hangup", @"");
        hangupButtonLabel.backgroundColor = [UIColor clearColor];
        
        keyBoardLabel =  [[UILabel alloc] initWithFrame:CGRectZero];
        [keyBoardLabel setTextAlignment:NSTextAlignmentCenter];
        keyBoardLabel.font = [UIFont systemFontOfSize:16];
        keyBoardLabel.textColor = [UIColor whiteColor];
        keyBoardLabel.text = NSLocalizedString(@"KeyPad", @"");
        keyBoardLabel.backgroundColor = [UIColor clearColor];
        
        contactHeadImage = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"call-contact-head.png" color:[UIColor whiteColor]]];

        [contactHeadImage setBackgroundColor:contactHeadBlueColor];
        contactHeadImage.contentMode = UIViewContentModeCenter;
        contactHeadImage.layer.cornerRadius = kContactHeadButtonSize / 2;
        contactHeadImage.layer.masksToBounds = YES;
        
        [self addSubview:contactHeadImage];
        
        //contactHeadImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        callingNetowkrQuality = [[UIImageView alloc] initWithFrame:CGRectZero];
        
    }
    
    debugView = [[UIView alloc]initWithFrame:CGRectZero];
    debugVideoSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
    debugBitRateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    debugLostAndDelayTxLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    [debugVideoSizeLabel setText:@"Rx vSize: 0x0"];
    [debugBitRateLabel setText:@"Rx: 0kpbs/0fps, Tx: 0kpbs/0fps"];
    [debugLostAndDelayTxLabel setText:@"A: 0ms/0% lost, V: 0ms/0% lost"];
    
    callingKeyBoardView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:callingKeyBoardView];
    
    videoCallingScrollView = nil;
    videoCallingPageControl = nil;
    hidenToolWidgets = NO;
    videoCallingViewPageOne = nil;
    videoCallingViewPageTwo = nil;
    session = nil;
    videoCallingCameraPreView = nil;
    showKeyBoard = NO;
    return self;
}

-(void) disableAllWidgets
{
    [hangupButton setEnabled:NO];
    [muteMicButton setEnabled:NO];
    [speakerButton setEnabled:NO];
    [cameraSwitchButton setEnabled:NO];
    [voiceAnswerButton setEnabled:NO];
    [videoAnswerButton setEnabled:NO];
}

-(void) hiddenAllWidgets
{
    NSLog(@"==========hiddenAllWidgets=======");
    [_localVideoView setHidden:YES];
    [_remoteVideoView setHidden:YES];
    [videoCallingPageControl setHidden:YES];
    [videoCallingScrollView setHidden:YES];
    [answerButtonLabel setHidden:YES];
    [hangupButtonLabel setHidden:YES];
    [hangupButton setHidden:YES];
    [muteMicButton setHidden:YES];
    [speakerButton setHidden:YES];
    [cameraSwitchButton setHidden:YES];
    [callingNumberLabel setHidden:YES];
    [callingTimeLabel setHidden:YES];
    [callingKeyBoardView setHidden:YES];
    [keyBoardLabel setHidden:YES];
    [keyBoardHiddenButton setHidden:YES];
    [keyBoardShowButton setHidden:YES];
    [keyBoardNumLabel setHidden:YES];
}

/*主叫呼叫布局*/
- (void)layoutToCalling:(BOOL)video_enabled
{
    CGRect bounds = self.bounds;
    float MaxX = CGRectGetMaxX(bounds);
    float MaxY = CGRectGetMaxY(bounds);
    
    float LineStartY = LineStartY = ((MaxY / 2) - (MaxX / 4));
    
    float RowStartXLeft = ((MaxX / 3) - (kDefaultButtonSize / 2));
    float RowStartXCenter = (MaxX / 2);
    float RowStartXRight = (MaxX - (MaxX / 3) + (kDefaultButtonSize / 2));

    /*音频去电
     
     +                      +
     
     头像
     号码或名称
     正在振铃...
     
     
     
     
     静音       挂断       免提
     
     +                       +
     */
    
    /*视频去电
     
     +                         +
     号码或名称
     正在振铃...
     
     
     
     
     本端摄像头背景
     
     
     
     
     静音       挂断       切画
     +                         +
     */
    self.backgroundColor = voiceCallBackGroundBlueColor;

    [muteMicButton setEnabled:YES];
    [speakerButton setEnabled:YES];
    [hangupButton setEnabled:YES];
    [cameraSwitchButton setEnabled:YES];
    
    [voiceAnswerButton setHidden:YES];
    [videoAnswerButton setHidden:YES];
    
    [muteMicButton setHidden:NO];
    [hangupButton setHidden:NO];
    [callingNumberLabel setHidden:NO];
    [callingTimeLabel setHidden:NO];
    
    float ButtonY = MaxY - (MaxY / 8);
    muteMicButton.frame = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
    muteMicButton.center = CGPointMake(RowStartXLeft, ButtonY);
    
    hangupButton.frame = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
    hangupButton.center = CGPointMake(RowStartXCenter, ButtonY);
    
    
    if(video_enabled)
    {
        [contactHeadImage setHidden:YES];
        [cameraSwitchButton setHidden:NO];
        cameraSwitchButton.hidden = NO;
        cameraSwitchButton.frame  = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
        cameraSwitchButton.center = CGPointMake(RowStartXRight, ButtonY);
        
        [speakerButton removeFromSuperview];
        [self addSubview:speakerButton];

        
        float LabelY = (MaxY / 8) + (kContactHeadButtonSize / 2);
        CGSize fontSize = [callingNumberLabel.text sizeWithFont:callingNumberLabel.font];
        callingNumberLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width * 1.5,fontSize.height);
        callingNumberLabel.center = CGPointMake(RowStartXCenter,LabelY);
        //callingNumberLabel.text = @"+8618627935526";
        
        [callingNumberLabel removeFromSuperview];
        [self addSubview:callingNumberLabel];
        
        LabelY += 24;
        fontSize = [callingTimeLabel.text sizeWithFont:callingNumberLabel.font];
        callingTimeLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width * 1.5,fontSize.height);
        callingTimeLabel.center = CGPointMake(RowStartXCenter,LabelY);
        //callingTimeLabel.text = @"正在振铃...";
        
        
        [callingTimeLabel removeFromSuperview];
        [self addSubview:callingTimeLabel];
#if 0
        [_localVideoView setHidden:NO];
        
        [_localVideoView removeFromSuperview];
        [self addSubview:_localVideoView];
#endif
    }else{
        [contactHeadImage setHidden:NO];
        [callingTimeLabel setHidden:NO];
        [callingNumberLabel setHidden:NO];
        [speakerButton setHidden:NO];
        [hangupButton setHidden:NO];
        [muteMicButton setHidden:NO];
        
        speakerButton.frame  = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
        speakerButton.center = CGPointMake(RowStartXRight, ButtonY);
        
        [speakerButton removeFromSuperview];
        [self addSubview:speakerButton];

        
        float LabelY = (MaxY / 8) + (kContactHeadButtonSize / 2);
        
        contactHeadImage.frame = CGRectMake(0.0f,0.0f,kContactHeadButtonSize,kContactHeadButtonSize);
        contactHeadImage.center = CGPointMake(RowStartXCenter,LabelY);
        [contactHeadImage removeFromSuperview];
        [self addSubview:contactHeadImage];
        
        LabelY +=  (kContactHeadButtonSize / 2);
        LabelY += 20;
        
        CGSize fontSize = [callingNumberLabel.text sizeWithFont:callingNumberLabel.font];
        callingNumberLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width * 1.5,fontSize.height);
        callingNumberLabel.center = CGPointMake(RowStartXCenter,LabelY);
        //callingNumberLabel.text = @"+8618627935526";
        
        [callingNumberLabel removeFromSuperview];
        [self addSubview:callingNumberLabel];
        
        LabelY += 24;
        fontSize = [callingTimeLabel.text sizeWithFont:callingNumberLabel.font];
        callingTimeLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width * 1.5,fontSize.height);
        callingTimeLabel.center = CGPointMake(RowStartXCenter,LabelY);
        //callingTimeLabel.text = @"正在振铃...";
        
        
        [callingTimeLabel removeFromSuperview];
        [self addSubview:callingTimeLabel];
    
    }
}

/*通话中布局*/
- (void)layoutToAnswered:(BOOL)video_enabled
{
    /*
     
     2，音频模式
     
     +                      +
     
     联系人头像
     联系人标签
     时间+状态+网络质量
     
     
            。。
     静音   挂断    免提
     
     +                      +
     
     
     
     4， 视频模式
     
     +                         +
     
     +   +    联系人头像
     本地     联系人标签
     视频     时间+状态+质量
     +   +
     
     
     远端视频
     
     
     
     免提     关画     联系人
             。。
     静音     挂断     切画
     
     +                        +
     */
    
    CGRect bounds = self.bounds;
    float MaxX = CGRectGetMaxX(bounds);
    float MaxY = CGRectGetMaxY(bounds);
    float MidX = CGRectGetMidX(bounds);
    float MidY = CGRectGetMidY(bounds);
    
    float LineStartY = LineStartY = ((MaxY / 2) - (MaxX / 4));
    
    float RowStartXLeft = ((MaxX / 3) - (kDefaultButtonSize / 2));
    float RowStartXCenter = (MaxX / 2);
    float RowStartXRight = (MaxX - (MaxX / 3) + (kDefaultButtonSize / 2));
    
    
    [cameraSwitchButton setEnabled:YES];
    [muteMicButton setEnabled:YES];
    [speakerButton setEnabled:YES];
    [hangupButton setEnabled:YES];
    
    [callingNumberLabel setHidden:NO];
    [callingTimeLabel setHidden:NO];
    
    [voiceAnswerButton setHidden:YES];
    [videoAnswerButton setHidden:YES];
    
    self.backgroundColor = voiceCallBackGroundBlueColor;

    if(video_enabled)
    {
        [speakerButton setSelected:YES];
        [contactHeadImage setHidden:YES];
        [hangupButton setHidden:NO];
        [muteMicButton setHidden:NO];
        [cameraSwitchButton setHidden:NO];
        [speakerButton setHidden:NO];

        [_remoteVideoView removeFromSuperview];
        [self addSubview:_remoteVideoView];
        [self sendSubviewToBack:_remoteVideoView];
    
        [_localVideoView setHidden:NO];
        [_remoteVideoView setHidden:NO];

        
        if (remoteVideoSize.width > 0 && remoteVideoSize.height > 0)
        {
            // Aspect fill remote video into bounds.
            CGRect remoteVideoFrame =
            AVMakeRectWithAspectRatioInsideRect(remoteVideoSize, bounds);
            CGFloat scale = 1;
            if (remoteVideoFrame.size.width > remoteVideoFrame.size.height) {
                // Scale by height.
                scale = (bounds.size.width > bounds.size.height)?
                (bounds.size.height / remoteVideoFrame.size.height) : (bounds.size.width / remoteVideoFrame.size.width);
            } else {
                // Scale by width.
                scale = (bounds.size.width > bounds.size.height)?
                (bounds.size.height / remoteVideoFrame.size.height) : (bounds.size.width / remoteVideoFrame.size.width);
            }
            remoteVideoFrame.size.height *= scale;
            remoteVideoFrame.size.width *= scale;
            _remoteVideoView.frame = remoteVideoFrame;
            _remoteVideoView.center = CGPointMake(MidX, MidY);
            
            self.backgroundColor = [UIColor blackColor];
        }
        else {
            _remoteVideoView.frame = bounds;
        }
        
        CGRect localVideoFrame = CGRectZero;
        if(localVideoSize.width > localVideoSize.height)
        {
            localVideoFrame.origin.x = kLocalVideoViewPadding;
            localVideoFrame.origin.y = kLocalVideoViewPadding + kLocalVideoViewPadding;
            localVideoFrame.size.width = (kLocalVideoViewWidth / localVideoSize.height) * localVideoSize.width;
            localVideoFrame.size.height = kLocalVideoViewWidth;
        }
        else
        {
            localVideoFrame.origin.x = kLocalVideoViewPadding;
            localVideoFrame.origin.y = kLocalVideoViewPadding + kLocalVideoViewPadding;
            localVideoFrame.size.width = kLocalVideoViewWidth;
            localVideoFrame.size.height = (localVideoSize.width == 0)? kLocalVideoViewHeight : (kLocalVideoViewWidth / localVideoSize.width) * localVideoSize.height;
        }
        
        _localVideoView.frame = localVideoFrame;
        
        float ButtonY = MaxY - (MaxY / 8);
        muteMicButton.frame = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
        muteMicButton.center = CGPointMake(RowStartXLeft, ButtonY);
        
        hangupButton.frame = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
        hangupButton.center = CGPointMake(RowStartXCenter, ButtonY);
        
        cameraSwitchButton.frame  = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
        cameraSwitchButton.center = CGPointMake(RowStartXRight, ButtonY);
        
        float ButtonLabelY = ButtonY - (kDefaultButtonSize / 2) - kDefaultButtonPadding - 20;
        ButtonY -= (kDefaultButtonSize + (kDefaultButtonPadding * 2) + 20);

        [_statusLabel sizeToFit];
        _statusLabel.center = CGPointMake(MidX, MidY);
        
        
        CGRect scroll_bounds = bounds;
        scroll_bounds.size.height = ButtonLabelY + 20;
        {    
            if(!videoCallingScrollView)
            {
                /*添加PageContorl*/
                videoCallingScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
                videoCallingScrollView.delegate = self;
                [videoCallingScrollView setBackgroundColor:[UIColor clearColor]];
                
                {
                    // define the scroll view content size and enable paging
                    [videoCallingScrollView setPagingEnabled: YES] ;
                    [videoCallingScrollView setBounces:NO];
                    [videoCallingScrollView setShowsHorizontalScrollIndicator:NO];
                    [videoCallingScrollView setShowsVerticalScrollIndicator:NO];
                    
                    // programmatically add the page control
                    videoCallingPageControl = [[DDPageControl alloc] initWithFrame:CGRectZero];
                    [videoCallingPageControl addTarget: self action: @selector(pageControlClicked:) forControlEvents: UIControlEventValueChanged] ;
                    [videoCallingPageControl setDefersCurrentPageDisplay: YES] ;
                    [videoCallingPageControl setType: DDPageControlTypeOnFullOffFull] ;
                    
                    [self addSubview:videoCallingPageControl];
                    [self addSubview:videoCallingScrollView];
                    
                    [videoCallingPageControl setNumberOfPages:2];
                    [videoCallingPageControl setCurrentPage:0];
                    
                    //[self.window insertSubview:videoCallingScrollView aboveSubview:_remoteVideoView];
                    //[self insertSubview:videoCallingPageControl aboveSubview:_remoteVideoView];
                    //[self insertSubview:videoCallingScrollView aboveSubview:videoCallingPageControl];
                    
                    //[self.window sendSubviewToBack:videoCallingScrollView];
                    //[self.window sendSubviewToBack:videoCallingPageControl];
                    //[self.window sendSubviewToBack:_remoteVideoView];
                }
        
            }
            
            for(UIView *subview in [videoCallingScrollView subviews]) {
                [subview removeFromSuperview];
            }
            
            UIFont *font = [UIFont systemFontOfSize:28];
            
            for (int i = 0 ; i < kNumberOfPages ; i++)
            {
                if(i == 0)
                {
                    //号码信息
                    
                    float LabelY = CGRectGetMidY(scroll_bounds) / 4;
                    //float LabelY = (CGRectGetMaxY(scroll_bounds) / 8) + (kContactHeadButtonSize / 2);
                    CGSize fontSize = [callingNumberLabel.text sizeWithFont:callingNumberLabel.font];
                    callingNumberLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width * 1.5,fontSize.height);
                    callingNumberLabel.center = CGPointMake(RowStartXCenter,LabelY);
                    //callingNumberLabel.text = @"+8618627935526";
                    
                    [callingNumberLabel removeFromSuperview];
                    
                    LabelY += 24;
                    fontSize = [callingTimeLabel.text sizeWithFont:callingNumberLabel.font];
                    callingTimeLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width * 1.5,fontSize.height);
                    callingTimeLabel.center = CGPointMake(RowStartXCenter,LabelY);
                    //callingTimeLabel.text = @"正在振铃...";
                    
                    
                    [callingTimeLabel removeFromSuperview];
                    
                    
                    if(videoCallingViewPageOne == nil)
                    {
                        videoCallingViewPageOne = [[UIView alloc] initWithFrame:CGRectZero];
                        
                        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPageUIViewClicked:)];
                        
                        [videoCallingViewPageOne addGestureRecognizer:tapGesture];
                    }
                    
                    
                    [videoCallingViewPageOne addSubview:callingNumberLabel];
                    [videoCallingViewPageOne addSubview:contactHeadImage];
                    [videoCallingViewPageOne addSubview:callingTimeLabel];
                    [videoCallingScrollView addSubview: videoCallingViewPageOne];
                    videoCallingViewPageOne.frame = CGRectMake(i * scroll_bounds.size.width, 0.0f,scroll_bounds.size.width, scroll_bounds.size.height);
                    
                    
                }else if(i == 1)
                {
                    //调试信息
                    /*
                     0) 下行 码率kbs 帧率 fps
                     1) 上行 码率kbs 帧率 fps
                     3) 分辨率 640 x 480
                     4) 语音延迟 X ms, 丢包率 0.00%
                     5) 视频延迟 X ms, 丢包率 0.00%
                     */
                    
                    if(debugView)
                    {
                        int debug_height = 0;
                        
                        [debugView removeFromSuperview];
                        
                        for(UIView *subview in [debugView subviews]) {
                            [subview removeFromSuperview];
                        }
                        
                        [debugVideoSizeLabel setBackgroundColor: [UIColor clearColor]] ;
                        debugVideoSizeLabel.font = [UIFont systemFontOfSize:12];
                        [debugVideoSizeLabel setAlpha:0.9f];
                        // set some label properties
                        [debugVideoSizeLabel setTextAlignment: NSTextAlignmentCenter] ;
                        [debugVideoSizeLabel setTextColor: [UIColor whiteColor]] ;
                        CGSize fontSize = [debugVideoSizeLabel.text sizeWithFont:font];
                        debugVideoSizeLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width,fontSize.height);
                        
                        debug_height += fontSize.height/2;
                    
                        debugVideoSizeLabel.center = CGPointMake(0, debug_height);
                        
                        [debugView addSubview:debugVideoSizeLabel];
                        
                        
                        
                        [debugBitRateLabel setBackgroundColor: [UIColor clearColor]] ;
                        debugBitRateLabel.font = [UIFont systemFontOfSize:12];
                        [debugBitRateLabel setAlpha:0.9f];
                        // set some label properties
                        [debugBitRateLabel setTextAlignment: NSTextAlignmentCenter] ;
                        [debugBitRateLabel setTextColor: [UIColor whiteColor]] ;
                        fontSize = [debugBitRateLabel.text sizeWithFont:font];
                        debugBitRateLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width,fontSize.height);
                        
                        debug_height += fontSize.height/2;
                        
                        debugBitRateLabel.center = CGPointMake(0, debug_height);
                        [debugView addSubview:debugBitRateLabel];
                        
                        
                        
                        [debugLostAndDelayTxLabel setBackgroundColor: [UIColor clearColor]] ;
                        debugLostAndDelayTxLabel.font = [UIFont systemFontOfSize:12];
                        [debugLostAndDelayTxLabel setAlpha:0.9f];
                        // set some label properties
                        [debugLostAndDelayTxLabel setTextAlignment: NSTextAlignmentCenter] ;
                        [debugLostAndDelayTxLabel setTextColor: [UIColor whiteColor]] ;
                        fontSize = [debugLostAndDelayTxLabel.text sizeWithFont:font];
                        debugLostAndDelayTxLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width,fontSize.height);
                        
                        debug_height += fontSize.height/2;
                        
                        debugLostAndDelayTxLabel.center = CGPointMake(0, debug_height);
                        [debugView addSubview:debugLostAndDelayTxLabel];
                        
                        debugView.center = CGPointMake(CGRectGetMidX(scroll_bounds), CGRectGetMidY(scroll_bounds) / 8);
                        
                        [videoCallingViewPageTwo addSubview:debugView];
                    }
                
                    if(videoCallingViewPageTwo == nil)
                    {
                        videoCallingViewPageTwo = [[UIView alloc] initWithFrame:CGRectZero];
                        
                        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPageUIViewClicked:)];
                        
                        [videoCallingViewPageTwo addGestureRecognizer:tapGesture];
                    }
                    
                    [videoCallingScrollView addSubview: videoCallingViewPageTwo];
                    videoCallingViewPageTwo.frame = CGRectMake(i * scroll_bounds.size.width, 0.0f,scroll_bounds.size.width, scroll_bounds.size.height);
                    
                    [speakerButton removeFromSuperview];
                    [turnOffCameraButton removeFromSuperview];
                    [selectContactButton removeFromSuperview];
                    
                    [videoCallingViewPageTwo addSubview:speakerButton];
                    [videoCallingViewPageTwo addSubview:turnOffCameraButton];
                    [videoCallingViewPageTwo addSubview:selectContactButton];
                    
                    [videoCallingViewPageTwo addSubview:speakerButtonLabel];
                    [videoCallingViewPageTwo addSubview:turnOffCameraLabel];
                    [videoCallingViewPageTwo addSubview:selectContactButtonLabel];
                    [videoCallingViewPageTwo addSubview:callingNetowkrQuality];
                    [videoCallingViewPageTwo addSubview:_statusLabel];
                    
                    speakerButton.frame = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
                    speakerButton.center = CGPointMake(RowStartXLeft, ButtonY);
                    
                    turnOffCameraButton.frame = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
                    turnOffCameraButton.center = CGPointMake(RowStartXCenter, ButtonY);
                    
                    selectContactButton.frame  = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
                    selectContactButton.center = CGPointMake(RowStartXRight, ButtonY);
                    
                    UIFont *font = [UIFont systemFontOfSize:16];
                    CGSize fontSize = [speakerButtonLabel.text sizeWithFont:font];
                    speakerButtonLabel.frame = CGRectMake(0,0,fontSize.width,fontSize.height);
                    speakerButtonLabel.center = CGPointMake(RowStartXLeft, ButtonLabelY);
                    
                    
                    fontSize = [turnOffCameraLabel.text sizeWithFont:font];
                    turnOffCameraLabel.frame = CGRectMake(0,0,fontSize.width,fontSize.height);
                    turnOffCameraLabel.center = CGPointMake(RowStartXCenter, ButtonLabelY);
                    
                    fontSize = [selectContactButtonLabel.text sizeWithFont:font];
                    selectContactButtonLabel.frame = CGRectMake(0,0,fontSize.width,fontSize.height);
                    selectContactButtonLabel.center = CGPointMake(RowStartXRight, ButtonLabelY);
                }
            }
        }
        
        
        videoCallingScrollView.frame = scroll_bounds;
        videoCallingScrollView.center = CGPointMake(CGRectGetMidX(scroll_bounds),CGRectGetMidY(scroll_bounds));
        [videoCallingScrollView setContentSize: CGSizeMake(scroll_bounds.size.width * kNumberOfPages, 0)] ;
        
        videoCallingPageControl.frame = scroll_bounds;
        videoCallingPageControl.center = CGPointMake(CGRectGetMidX(bounds),ButtonLabelY + 20);
        
        [_localVideoView removeFromSuperview];
        [self insertSubview:_localVideoView belowSubview:videoCallingScrollView];
        
        [videoCallingPageControl setHidden:NO];
        [videoCallingScrollView setHidden:NO];
        
    } else
    {
        [self layoutToCalling:NO];
        
        [speakerButton setHidden:NO];
        [hangupButton setHidden:NO];
        [muteMicButton setHidden:NO];
        [contactHeadImage setHidden:NO];
        [keyBoardHiddenButton setHidden:NO];
        [keyBoardLabel setHidden:NO];
        
        [speakerButton removeFromSuperview];
        [self addSubview:speakerButton];
        float ButtonY = MaxY - (MaxY / 8);
        
        speakerButton.frame = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
        speakerButton.center = CGPointMake(RowStartXRight, ButtonY);
        
        keyBoardShowButton.frame = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
        keyBoardShowButton.center = CGPointMake(RowStartXRight, ButtonY);
        
        
        [keyBoardHiddenButton removeFromSuperview];
        [self addSubview:keyBoardHiddenButton];
        
        
        ButtonY -= kDefaultButtonSize;
        ButtonY -= kDefaultButtonPadding;
        ButtonY -= 20;
        
        keyBoardHiddenButton.frame = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
        keyBoardHiddenButton.center = CGPointMake(RowStartXCenter, ButtonY);
        
        
        ButtonY += (kDefaultButtonSize / 2);
        ButtonY += 15;
        
        CGSize fontSize = [keyBoardLabel.text sizeWithFont:keyBoardLabel.font];
        keyBoardLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width,fontSize.height);
        keyBoardLabel.center = CGPointMake(RowStartXCenter,ButtonY);
        
        [keyBoardLabel removeFromSuperview];
        [self addSubview:keyBoardLabel];
        
        /*
        selectContactButton.frame = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
        selectContactButton.center = CGPointMake(RowStartXRight, ButtonY);
        */
        if(showKeyBoard)
        {
            [keyBoardLabel setHidden:YES];
            [keyBoardHiddenButton setHidden:YES];
            [speakerButton setHidden:YES];
            [hangupButton setHidden:YES];
            [muteMicButton setHidden:YES];
            [keyBoardShowButton setHidden:NO];
            
            for(UIView *subview in [callingKeyBoardView subviews])
            {
                [subview removeFromSuperview];
            }
            
            UIColor *button_color = [UIColor whiteColor];
            UIColor *highlighted_color = [UIColor grayColor];
            UIButton *buttons[12];

            LineStartY -= kDefaultButtonSize;
            LineStartY -= kDefaultButtonPadding;
            
            
            float keyBoardViweStartY = 0;
            
            float keyBoardViewHeight = 0;

            {
                /*添加数字按键*/
                buttons[0] = [CustomButton addButton:@"keypad-1.png" backgroundColor:[UIColor whiteColor] mainColor:button_color  highlightedColor:highlighted_color setBorder:YES tag:1 button_size:kDefaultButtonSize];
                buttons[1] = [CustomButton addButton:@"keypad-2.png" backgroundColor:[UIColor whiteColor] mainColor:button_color highlightedColor:highlighted_color  setBorder:YES tag:2 button_size:kDefaultButtonSize];
                buttons[2] = [CustomButton addButton:@"keypad-3.png" backgroundColor:[UIColor whiteColor] mainColor:button_color highlightedColor:highlighted_color setBorder:YES tag:3 button_size:kDefaultButtonSize];
                buttons[3] = [CustomButton addButton:@"keypad-4.png" backgroundColor:[UIColor whiteColor] mainColor:button_color highlightedColor:highlighted_color setBorder:YES tag:4 button_size:kDefaultButtonSize];
                buttons[4] = [CustomButton addButton:@"keypad-5.png" backgroundColor:[UIColor whiteColor] mainColor:button_color highlightedColor:highlighted_color setBorder:YES tag:5 button_size:kDefaultButtonSize];
                buttons[5] = [CustomButton addButton:@"keypad-6.png" backgroundColor:[UIColor whiteColor] mainColor:button_color highlightedColor:highlighted_color setBorder:YES tag:6 button_size:kDefaultButtonSize];
                buttons[6] = [CustomButton addButton:@"keypad-7.png" backgroundColor:[UIColor whiteColor] mainColor:button_color highlightedColor:highlighted_color setBorder:YES tag:7 button_size:kDefaultButtonSize];
                buttons[7] = [CustomButton addButton:@"keypad-8.png" backgroundColor:[UIColor whiteColor] mainColor:button_color highlightedColor:highlighted_color setBorder:YES tag:8 button_size:kDefaultButtonSize];
                buttons[8] = [CustomButton addButton:@"keypad-9.png" backgroundColor:[UIColor whiteColor] mainColor:button_color highlightedColor:highlighted_color setBorder:YES tag:9 button_size:kDefaultButtonSize];
                buttons[9] = [CustomButton addButton:@"keypad-star.png" backgroundColor:[UIColor whiteColor] mainColor:button_color highlightedColor:highlighted_color setBorder:YES tag:11 button_size:kDefaultButtonSize];
                buttons[10] = [CustomButton addButton:@"keypad-0.png" backgroundColor:[UIColor whiteColor] mainColor:button_color highlightedColor:highlighted_color setBorder:YES tag:0 button_size:kDefaultButtonSize];
                buttons[11] = [CustomButton addButton:@"keypad-hashkey.png" backgroundColor:[UIColor whiteColor] mainColor:button_color highlightedColor:highlighted_color setBorder:YES tag:12 button_size:kDefaultButtonSize];
                
                for(int i = 0; i < 12; i++)
                {
                    [callingKeyBoardView addSubview:buttons[i]];
                    [buttons[i] addTarget:self
                                   action:@selector(onButtonUpInSide:)
                         forControlEvents:UIControlEventTouchUpInside];
                    
                    [buttons[i] addTarget:self
                                   action:@selector(onButtonTouchDown:)
                         forControlEvents:UIControlEventTouchDown];
                }
    
                float RowPadding[3] =  {RowStartXLeft,RowStartXCenter,RowStartXRight};
                int button_padding = kDefaultButtonPadding;
                keyBoardViweStartY = (kDefaultButtonSize / 2);
                
                if(iPhone4 || iPhone5)
                {
                    button_padding -= 6;
                }

                float LinePadding = kDefaultButtonSize + button_padding;
                
                
                int btn_cnt = 0;
                for(int i = 0; i < 4; i++) //绘制4行数字按钮
                {
                    for(int j = 0; j < 3; j++){ //绘制每排3个数字按钮
                        buttons[btn_cnt].frame = CGRectMake(0, 0, kDefaultButtonSize, kDefaultButtonSize);
                        buttons[btn_cnt].center = CGPointMake(RowPadding[j], keyBoardViweStartY);
                        btn_cnt++;
                    }
                    
                    keyBoardViweStartY += LinePadding;
                    keyBoardViewHeight += LinePadding;
                }
                
                
                callingKeyBoardView.frame = CGRectMake(0, 0, MaxX, keyBoardViewHeight);
            }
            
            float keyBoardStartY =  MidY - (kDefaultButtonSize / 2) - (kDefaultButtonPadding /2 );
            
            if(iPhone6)
            {
               keyBoardStartY -= kDefaultButtonPadding * 2;
            }
            
            keyBoardStartY += kDefaultButtonSize + kDefaultButtonPadding;
            
            callingKeyBoardView.center = CGPointMake(MidX,keyBoardStartY);

            keyBoardStartY -= (keyBoardViewHeight / 2);
            keyBoardStartY -= 34;
        
            keyBoardNumLabel.center = CGPointMake(MidX,keyBoardStartY);

            [contactHeadImage setHidden:YES];
            [callingNumberLabel setHidden:YES];
            [callingTimeLabel setHidden:YES];
            
            [keyBoardNumLabel setHidden:NO];
            [callingKeyBoardView setHidden:NO];
            
            [self bringSubviewToFront:callingKeyBoardView];
        }else
        {
            [speakerButton setHidden:NO];
            [hangupButton setHidden:NO];
            [muteMicButton setHidden:NO];
            
            [keyBoardLabel setHidden:NO];
            [keyBoardHiddenButton setHidden:NO];
            [contactHeadImage setHidden:NO];
            [callingNumberLabel setHidden:NO];
            [callingTimeLabel setHidden:NO];
            [callingKeyBoardView setHidden:YES];
            [keyBoardShowButton setHidden:YES];
            [keyBoardNumLabel setHidden:YES];
        }
    }
}

/*被叫来电布局*/
- (void)layoutToInCallRinging:(BOOL)video_enabled
{
    CGRect bounds = self.bounds;
    float MaxX = CGRectGetMaxX(bounds);
    float MaxY = CGRectGetMaxY(bounds);
    float LineStartY = LineStartY = ((MaxY / 2) - (MaxX / 4));
    float RowStartXLeft = ((MaxX / 3) - (kDefaultButtonSize / 2));
    float RowStartXCenter = (MaxX / 2);
    float RowStartXRight = (MaxX - (MaxX / 3) + (kDefaultButtonSize / 2));
    
    self.backgroundColor = voiceCallBackGroundBlueColor;
    NSLog(@"=============layoutToInCallRinging=========");
    
    [muteMicButton setEnabled:YES];
    [speakerButton setEnabled:YES];
    [hangupButton setEnabled:YES];

    [hangupButton setHidden:NO];
    [callingNumberLabel setHidden:NO];
    [callingTimeLabel setHidden:NO];
    [answerButtonLabel setHidden:NO];
    [hangupButtonLabel setHidden:NO];
    
    float ButtonY = MaxY - (MaxY / 8) - 20;
    hangupButton.frame = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
    hangupButton.center = CGPointMake(RowStartXLeft, ButtonY);
    
    
    /*
     1，音频来电
     
     +                      +
     
     头像
     号码或名称
     
     
     
     短信回复
     
     
     
     拒绝           接听
     
     +                       +
     
     */
    
    /*
     视频来电
     
     +                         +
     号码或名称
     
     
     摄像头背景
     
     
     短信回复       关画接听
     
     
     拒绝            接听
     +                         +
     */
    
    muteMicButton.hidden = YES;
    if(video_enabled)
    {
        [voiceAnswerButton setHidden:YES];
        [contactHeadImage setHidden:YES];
        
        [videoAnswerButton setEnabled:YES];
        [videoAnswerButton setHidden:NO];

        videoAnswerButton.frame  = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
        videoAnswerButton.center = CGPointMake(RowStartXRight, ButtonY);
        
        float LabelY = (MaxY / 8) + (kContactHeadButtonSize / 2);
        
        CGSize fontSize = [callingNumberLabel.text sizeWithFont:callingNumberLabel.font];
        callingNumberLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width,fontSize.height);
        callingNumberLabel.center = CGPointMake(RowStartXCenter,LabelY);
        //callingNumberLabel.text = @"+8618627935526";
        
        [callingNumberLabel removeFromSuperview];
        [self addSubview:callingNumberLabel];
        
        LabelY += 24;
        fontSize = [callingTimeLabel.text sizeWithFont:callingNumberLabel.font];
        callingTimeLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width * 1.5,fontSize.height);
        callingTimeLabel.center = CGPointMake(RowStartXCenter,LabelY);
        //callingTimeLabel.text = @"正在振铃...";
        
        
        [callingTimeLabel removeFromSuperview];
        [self addSubview:callingTimeLabel];
#if 0
        [_localVideoView setHidden:NO];
#endif
    }else
    {
        [videoAnswerButton setHidden:YES];
        [contactHeadImage setHidden:NO];
        [voiceAnswerButton setEnabled:YES];
        [voiceAnswerButton setHidden:NO];
        
        voiceAnswerButton.frame  = CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize);
        voiceAnswerButton.center = CGPointMake(RowStartXRight, ButtonY);

        float LabelY = (MaxY / 8) + (kContactHeadButtonSize / 2) - (10 /2)/*statusbar*/;
        
        [contactHeadImage removeFromSuperview];
        [self addSubview:contactHeadImage];
        
        contactHeadImage.frame = CGRectMake(0.0f,0.0f,kContactHeadButtonSize,kContactHeadButtonSize);
        contactHeadImage.center = CGPointMake(RowStartXCenter,LabelY);
        
        LabelY +=  (kContactHeadButtonSize / 2);
        LabelY += 20;
        
        CGSize fontSize = [callingNumberLabel.text sizeWithFont:callingNumberLabel.font];
        callingNumberLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width,fontSize.height);
        callingNumberLabel.center = CGPointMake(RowStartXCenter,LabelY);
        //callingNumberLabel.text = @"+8618627935526";
        
        [callingNumberLabel removeFromSuperview];
        [self addSubview:callingNumberLabel];
        
        LabelY += 24;
        fontSize = [callingTimeLabel.text sizeWithFont:callingNumberLabel.font];
        callingTimeLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width * 1.5,fontSize.height);
        callingTimeLabel.center = CGPointMake(RowStartXCenter,LabelY);
        //callingTimeLabel.text = @"正在振铃...";
        
        
        [callingTimeLabel removeFromSuperview];
        [self addSubview:callingTimeLabel];
    }
    
    ButtonY += (kDefaultButtonSize/2);
    ButtonY += 20;
    
    CGSize fontSize = [hangupButtonLabel.text sizeWithFont:hangupButtonLabel.font];
    hangupButtonLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width,fontSize.height);
    hangupButtonLabel.center = CGPointMake(RowStartXLeft,ButtonY);
    
    [hangupButtonLabel removeFromSuperview];
    [self addSubview:hangupButtonLabel];
    
    fontSize = [answerButtonLabel.text sizeWithFont:answerButtonLabel.font];
    answerButtonLabel.frame = CGRectMake(0.0f,0.0f,fontSize.width,fontSize.height);
    answerButtonLabel.center = CGPointMake(RowStartXRight,ButtonY);
    
    [answerButtonLabel removeFromSuperview];
    [self addSubview:answerButtonLabel];
}

- (void)layoutSubviews
{
    [self hiddenAllWidgets];
    
    switch (self.mode) {
        case kAudioCalling:
            [self layoutToCalling:NO];
            break;
        case kVideoCalling:
            [self layoutToCalling:YES];
            break;
        case kAudioRinging:
            NSLog(@"=====kAudioRinging=====");
            [self layoutToInCallRinging:NO];
            break;
        case kVideoRinging:
            NSLog(@"=====kVideoRinging=====");
            [self layoutToInCallRinging:YES];
            break;
        case kAudioAnswered:
            [self layoutToAnswered:NO];
            break;
        case kVideoAnswered:
            [self layoutToAnswered:YES];
            break;
        default:
            break;
    }

    if(self.mode == kVideoAnswered)
        [self setToolsHidden];
}

#pragma mark - RTCEAGLVideoViewDelegate

- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size {
  if (videoView == _localVideoView) {
    localVideoSize = size;
  } else if (videoView == _remoteVideoView) {
    remoteVideoSize = size;
  }
  [self setNeedsLayout];
}

#pragma mark - Private

#pragma mark -
#pragma mark DDPageControl triggered actions

- (void)pageControlClicked:(id)sender
{
    DDPageControl *thePageControl = (DDPageControl *)sender ;
    
    // we need to scroll to the new index
    [videoCallingScrollView setContentOffset: CGPointMake(videoCallingScrollView.bounds.size.width * thePageControl.currentPage, videoCallingScrollView.contentOffset.y) animated: YES] ;
}


#pragma mark -
#pragma mark UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGFloat pageWidth = videoCallingScrollView.bounds.size.width ;
    float fractionalPage = videoCallingScrollView.contentOffset.x / pageWidth ;
    NSInteger nearestNumber = lround(fractionalPage) ;
    
    if (videoCallingPageControl.currentPage != nearestNumber)
    {
        videoCallingPageControl.currentPage = nearestNumber ;
        
        // if we are dragging, we want to update the page control directly during the drag
        if (videoCallingScrollView.dragging)
            [videoCallingPageControl updateCurrentPageDisplay] ;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
    // if we are animating (triggered by clicking on the page control), we update the page control
    [videoCallingPageControl updateCurrentPageDisplay] ;
}

-(AVCaptureDevice *)frontFacingCameraIfAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}

- (void)setupCaptureSession
{
    NSError *error = nil;
    
    // Create the session
    self.session = [[AVCaptureSession alloc] init] ;
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    AVCaptureDevice *device = [self frontFacingCameraIfAvailable];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input) {
        
    }
    [session addInput:input];
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init] ;
    [session addOutput:output];
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    //dispatch_release(queue);

#if 0
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    
    NSNumber* val = [NSNumber
                     numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
    NSDictionary* videoSettings =
    [NSDictionary dictionaryWithObject:val forKey:key];
    output.videoSettings = videoSettings;
#else
    // Specify the pixel format
    output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                            [NSNumber numberWithInt: 320], (__bridge id)kCVPixelBufferWidthKey,
                            [NSNumber numberWithInt: 240], (__bridge id)kCVPixelBufferHeightKey,
                            nil];
#endif
    CGRect bounds = _localVideoView.bounds;
    
    self.preLayer = [AVCaptureVideoPreviewLayer layerWithSession: session];
    preLayer.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
}

- (void)startVideoPreViewing
{
    localVideoSize.width = 240;
    localVideoSize.height = 320;
    _localVideoView.frame = self.bounds;
    [self sendSubviewToBack:_localVideoView];
    
    if(!session)
    {
        [self setupCaptureSession];
    }
    if (![session isRunning]) {
        [session startRunning];
    }
    
    [_localVideoView.layer addSublayer:self.preLayer];
}

- (void) stopVideoPreViewing
{
    CGRect localVideoFrame = CGRectZero;
    if(localVideoSize.width > localVideoSize.height)
    {
        localVideoFrame.origin.x = kLocalVideoViewPadding;
        localVideoFrame.origin.y = kLocalVideoViewPadding + kLocalVideoViewPadding;
        localVideoFrame.size.width = kLocalVideoViewHeight;
        localVideoFrame.size.height = kLocalVideoViewWidth;
    }
    else
    {
        localVideoFrame.origin.x = kLocalVideoViewPadding;
        localVideoFrame.origin.y = kLocalVideoViewPadding + kLocalVideoViewPadding;
        localVideoFrame.size.width = kLocalVideoViewWidth;
        localVideoFrame.size.height = kLocalVideoViewHeight;
    }
    
    _localVideoView.frame = localVideoFrame;
    
    CGPoint center = _localVideoView.center;
    CGFloat alpha = _localVideoView.alpha;
    CGAffineTransform transform = _localVideoView.transform;
    
    transform.a = kLocalVideoViewWidth/self.bounds.size.width;
    transform.d = kLocalVideoViewHeight/self.bounds.size.height;
    
    center.x = kLocalVideoViewPadding;
    center.y = kLocalVideoViewPadding + kLocalVideoViewPadding;
    
    [UIView animateWithDuration:1.0f
                     animations:^(){
                         _localVideoView.center    = center;
                         _localVideoView.alpha     = alpha;
                         _localVideoView.transform = transform;
                     } completion:^(BOOL finished)
     {
         NSLog(@"animation finish");
         if (session && [session isRunning]) {
             [session stopRunning];
             session = nil;
         }
         if(self.preLayer)
         {
             [self.preLayer removeFromSuperlayer];
             self.preLayer = nil;
         }
     }];
}

@end
