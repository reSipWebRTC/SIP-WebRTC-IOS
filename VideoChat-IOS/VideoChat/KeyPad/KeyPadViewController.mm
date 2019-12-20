
#import "KeyPadViewController.h"
#import "KxMenu.h"

#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioToolbox.h>

#import "CommonTypes.h"
#import <reSipWebRTCSDK/SipEngineManager.h>
#import "CallingScreenViewController.h"
#import "ContactsTableViewController.h"
#import "CustomButton.h"
#import "UserContactUtil.h"
#import "UserCallReportUtil.h"
#import "UserSoundsPlayerUtil.h"
#import "AppDelegate.h"

static NSString * const kARDDefaultSTUNServerUrl =
@"stun:39.108.167.93:19302";
static NSString * const kARDDefaultTURNServerUrl =
@"turn:39.108.167.93:19302";

KeyPadViewController *the_instance_ = nil;

@interface KeyPadViewController ()
{
    UIButton *buttons[12];
    UITextField* dialNumberLabel;
    UILabel* contactNameLabel;
    UIButton* addContactButton;
    UIButton* makeVoiceCallButton;
    UIButton* makeVideoCallButton;
    UIButton* deleteButton;
    BOOL matchedContact;
}
@end

bool is_initialize = false;

@implementation KeyPadViewController

@synthesize calling_screen_view;

+(KeyPadViewController *)instance
{
    return the_instance_;
}

- (void) initSubviews
{
    UIColor *button_color = buttonBlueColor;
    
    addContactButton = [CustomButton addCleanButton:@"keypad-addcontact.png" backgroundColor:buttonBlueColor mainColor:button_color  setBorder:YES tag:ACTION_ADD_CONTACT button_size:kCleanActionButtonSize];
    
    [addContactButton addTarget:self
               action:@selector(onButtonUpInSide:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [addContactButton addTarget:self
               action:@selector(onButtonTouchDown:)
     forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:addContactButton];
    
    deleteButton = [CustomButton addCleanButton:@"keypad-delete.png" backgroundColor:buttonBlueColor mainColor:button_color setBorder:YES tag:ACTION_DEL_NUNMBER button_size:kCleanActionButtonSize];
    
    [deleteButton addTarget:self
                         action:@selector(onButtonUpInSide:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [deleteButton addTarget:self
                         action:@selector(onButtonTouchDown:)
               forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:deleteButton];
    
    dialNumberLabel = [[UITextField alloc] initWithFrame:CGRectZero];
    [dialNumberLabel setTextAlignment:NSTextAlignmentCenter];
    dialNumberLabel.font = [UIFont systemFontOfSize:38];
    dialNumberLabel.textColor = [UIColor blackColor];
    dialNumberLabel.alpha = 0.75f;
    dialNumberLabel.adjustsFontSizeToFitWidth = YES;
    dialNumberLabel.minimumFontSize = 6;
    dialNumberLabel.text = @"+8618627935526";
    dialNumberLabel.returnKeyType = UIReturnKeyDone;
    dialNumberLabel.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    dialNumberLabel.delegate = self;
    dialNumberLabel.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:dialNumberLabel];
    
    contactNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [contactNameLabel setTextAlignment:NSTextAlignmentCenter];
    contactNameLabel.font = [UIFont systemFontOfSize:16];
    contactNameLabel.textColor = [UIColor grayColor];
    contactNameLabel.text = @"名称";
    contactNameLabel.backgroundColor = [UIColor clearColor];
    contactNameLabel.hidden = YES;
    [self.view addSubview:contactNameLabel];

    float default_button_size = kDefaultButtonSize;
    
    if(isPad)
    {
        default_button_size = 84;
    }
    
    /*添加数字按键*/
    buttons[0] = [CustomButton addButton:@"keypad-1.png" backgroundColor:[UIColor blueColor] mainColor:button_color highlightedColor:[UIColor whiteColor] setBorder:YES tag:1 button_size:default_button_size];
    buttons[1] = [CustomButton addButton:@"keypad-2.png" backgroundColor:[UIColor blueColor] mainColor:button_color highlightedColor:[UIColor whiteColor]  setBorder:YES tag:2 button_size:default_button_size];
    buttons[2] = [CustomButton addButton:@"keypad-3.png" backgroundColor:[UIColor blueColor] mainColor:button_color highlightedColor:[UIColor whiteColor] setBorder:YES tag:3 button_size:default_button_size];
    buttons[3] = [CustomButton addButton:@"keypad-4.png" backgroundColor:[UIColor blueColor] mainColor:button_color highlightedColor:[UIColor whiteColor] setBorder:YES tag:4 button_size:default_button_size];
    buttons[4] = [CustomButton addButton:@"keypad-5.png" backgroundColor:[UIColor blueColor] mainColor:button_color highlightedColor:[UIColor whiteColor] setBorder:YES tag:5 button_size:default_button_size];
    buttons[5] = [CustomButton addButton:@"keypad-6.png" backgroundColor:[UIColor blueColor] mainColor:button_color highlightedColor:[UIColor whiteColor] setBorder:YES tag:6 button_size:default_button_size];
    buttons[6] = [CustomButton addButton:@"keypad-7.png" backgroundColor:[UIColor blueColor] mainColor:button_color highlightedColor:[UIColor whiteColor] setBorder:YES tag:7 button_size:default_button_size];
    buttons[7] = [CustomButton addButton:@"keypad-8.png" backgroundColor:[UIColor blueColor] mainColor:button_color highlightedColor:[UIColor whiteColor] setBorder:YES tag:8 button_size:default_button_size];
    buttons[8] = [CustomButton addButton:@"keypad-9.png" backgroundColor:[UIColor blueColor] mainColor:button_color highlightedColor:[UIColor whiteColor] setBorder:YES tag:9 button_size:default_button_size];
    buttons[9] = [CustomButton addButton:@"keypad-star.png" backgroundColor:[UIColor blueColor] mainColor:button_color highlightedColor:[UIColor whiteColor] setBorder:YES tag:11 button_size:default_button_size];
    buttons[10] = [CustomButton addButton:@"keypad-0.png" backgroundColor:[UIColor blueColor] mainColor:button_color highlightedColor:[UIColor whiteColor] setBorder:YES tag:0 button_size:default_button_size];
    buttons[11] = [CustomButton addButton:@"keypad-hashkey.png" backgroundColor:[UIColor blueColor] mainColor:button_color highlightedColor:[UIColor whiteColor] setBorder:YES tag:12 button_size:default_button_size];
    
    for(int i = 0; i < 12; i++)
    {
        [self.view addSubview:buttons[i]];
        [buttons[i] addTarget:self
                         action:@selector(onButtonUpInSide:)
               forControlEvents:UIControlEventTouchUpInside];
        
        [buttons[i] addTarget:self
                         action:@selector(onButtonTouchDown:)
               forControlEvents:UIControlEventTouchDown];
    }
    
    float action_button_size = kActionButtonSize;
    float scale = 2.75;
    if(iPhone5)
    {
        scale = 2.5;
    }
    
    if(isPad)
    {
        action_button_size = 54;
    }
    
    makeVoiceCallButton = [CustomButton addButton:@"action-voicecall.png" backgroundColor:button_color mainColor:[UIColor clearColor] highlightedColor:[UIColor whiteColor] setBorder:NO tag:ACTION_MAKE_AUDIO_CALL button_size:action_button_size];
    
    makeVoiceCallButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
    [makeVoiceCallButton setTitle:NSLocalizedString(@"  Voice", @"") forState:UIControlStateNormal];
    [makeVoiceCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [makeVoiceCallButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    makeVoiceCallButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [makeVoiceCallButton addTarget:self
                     action:@selector(onButtonUpInSide:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [makeVoiceCallButton addTarget:self
                     action:@selector(onButtonTouchDown:)
           forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:makeVoiceCallButton];
    
    makeVideoCallButton = [CustomButton addButton:@"action-videocall.png" backgroundColor:button_color mainColor:[UIColor clearColor] highlightedColor:[UIColor whiteColor] setBorder:NO tag:ACTION_MAKE_VIDEO_CALL button_size:action_button_size];
    
    makeVideoCallButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
    [makeVideoCallButton setTitle:NSLocalizedString(@"  Video", @"") forState:UIControlStateNormal];
    [makeVideoCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [makeVideoCallButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    makeVideoCallButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [makeVideoCallButton addTarget:self
                            action:@selector(onButtonUpInSide:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [makeVideoCallButton addTarget:self
                            action:@selector(onButtonTouchDown:)
                  forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:makeVideoCallButton];
    
    calling_screen_view = [self.storyboard instantiateViewControllerWithIdentifier:@"CallingScreenViewController"];
    [calling_screen_view setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initSubviews];
    [self layoutSubviews];
    
    dialNumberLabel.text = @"";

    addContactButton.hidden = YES;
    deleteButton.hidden = YES;
    
    matchedContact = NO;
    
    the_instance_ = self;
    
    [[SipEngineManager instance] setSipEngineCallDelegate:self];
    [[SipEngineManager instance] setSipEngineRegistrationDelegate :self];
    
    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
    [appDelegate loadConfig];
}


- (void)viewDidAppear:(BOOL)animated
{
    [self.view layoutIfNeeded];
    [self layoutSubviews];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval) duration
{
    [self.view layoutIfNeeded];
    [self layoutSubviews];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self textFieldTextChanged:textField.text];
    [self setupAddContactAndDeleteButton];
    return YES;
}

- (void) setupAddContactAndDeleteButton
{
    CATransition *animation = [CATransition animation];
    //animation.delegate = self;
    animation.duration = 0.1 ;  // 动画持续时间(秒)
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];;
    animation.type = kCATransitionFade;//淡入淡出效果
    
    if (dialNumberLabel.text && dialNumberLabel.text.length > 0)
    {
        addContactButton.hidden = matchedContact;
        contactNameLabel.hidden = !matchedContact;
        deleteButton.hidden = NO;
    }else{
        addContactButton.hidden = YES;
        deleteButton.hidden = YES;
        contactNameLabel.hidden = YES;
    }
    
    [[self.view layer] addAnimation:animation forKey:@"animation"];
}

-(void) onButtonTouchDown:(id)sender
{
    UIButton *button = sender;
    if(button.tag >= 0 && button.tag <= 12)
    {
        NSInteger num = button.tag;
        NSString* charater = [NSString stringWithFormat:@"%d", (int)num];
        NSString* dtmf_tone  = [NSString stringWithFormat:@"dtmf-%d", (int)num];
        if (num == 11) {
            charater = @"*";
            dtmf_tone  = @"dtmf-star";
        }
        else if (num == 12) {
            charater = @"#";
            dtmf_tone  = @"dtmf-hash";
        }
        
        bool need_display_add_delete = (dialNumberLabel.text && dialNumberLabel.text.length == 0);
        [dialNumberLabel setText:[dialNumberLabel.text stringByAppendingFormat:@"%@", charater]];
        if(button.tag == 0)
        {
            [self performSelector:@selector(doKeyZeroLongPress) withObject:nil afterDelay:0.5f];
        }
        
        if(need_display_add_delete)
            [self setupAddContactAndDeleteButton];
    
        [[UserSoundsPlayerUtil instance] playSound:dtmf_tone];
        [self textFieldTextChanged:dialNumberLabel.text];
    }else if(button.tag == ACTION_DEL_NUNMBER)
    {
        if (dialNumberLabel.text && dialNumberLabel.text.length > 0) {
            dialNumberLabel.text = [dialNumberLabel.text substringToIndex:dialNumberLabel.text.length - 1];
            [self textFieldTextChanged:dialNumberLabel.text];
            [self performSelector:@selector(doKeyDelLongPress) withObject:nil afterDelay:0.5f];
        }
    
        if((dialNumberLabel.text && dialNumberLabel.text.length == 0))
            [self setupAddContactAndDeleteButton];
    }
}

-(void)textFieldTextChanged:(NSString*)num
{
    std::string phone = [num UTF8String];
    Contact *cc = [[ContactManagerUtil instance] getContactManager].do_search(phone);
   
    BOOL changeAddCCButton = NO;
    if(cc)
    {
        changeAddCCButton = YES;
        contactNameLabel.text = [NSString stringWithUTF8String:cc->name().c_str()];
        
        CGSize fontSize = [contactNameLabel.text sizeWithFont:contactNameLabel.font];
        contactNameLabel.frame = CGRectMake(CGRectGetMidX(self.view.bounds)  - (fontSize.width / 2),contactNameLabel.frame.origin.y, fontSize.width,fontSize.height);
        contactNameLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), contactNameLabel.frame.origin.y + (fontSize.height / 2));
        
    }else{
        changeAddCCButton = NO;
        contactNameLabel.text = @"";
    }
    
    if(changeAddCCButton != matchedContact)
    {
        CATransition *animation = [CATransition animation];
        //animation.delegate = self;
        animation.duration = 0.1 ;  // 动画持续时间(秒)
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];;
        animation.type = kCATransitionFade;//淡入淡出效果
        
        addContactButton.hidden = changeAddCCButton;
        contactNameLabel.hidden = !changeAddCCButton;
        
        [[self.view layer] addAnimation:animation forKey:@"animation"];
    }

    matchedContact = changeAddCCButton;
}

-(void) onButtonUpInSide:(id)sender
{
    UIButton *button = sender;
    if(button.tag == ACTION_MAKE_VIDEO_CALL) // 视频呼叫
    {
        if (dialNumberLabel.text && dialNumberLabel.text.length > 0)
        {
            [self makeCall:dialNumberLabel.text];
        }
        if (dialNumberLabel.text && dialNumberLabel.text.length == 0)
        {
            call_report *cdr = [[UserCallReportUtil instance] getCdrDatabase]->last_cdr();
            if(cdr)
            {
                dialNumberLabel.text = [NSString stringWithUTF8String:cdr->number];
                [self setupAddContactAndDeleteButton];
                [self textFieldTextChanged:dialNumberLabel.text];
            }
        }
    }else if(button.tag == ACTION_MAKE_AUDIO_CALL) //音频呼叫
    {
        if (dialNumberLabel.text && dialNumberLabel.text.length > 0)
        {
#if OEM_VERSION
            [self showMenu:button];
#else
             //[self makeCall:dialNumberLabel.text];
#endif
        }
        
        if (dialNumberLabel.text && dialNumberLabel.text.length == 0)
        {
            call_report *cdr = [[UserCallReportUtil instance] getCdrDatabase]->last_cdr();
            
            if(cdr)
            {
                dialNumberLabel.text = [NSString stringWithUTF8String:cdr->number];
                [self setupAddContactAndDeleteButton];
                [self textFieldTextChanged:dialNumberLabel.text];
            }
        }
        
    }else if(button.tag == ACTION_ADD_CONTACT)
    {
        NSString *number = dialNumberLabel.text;
        //添加联系人
        [self addContactWithPhonenum:number];
    }
    
    if (button.tag == 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doKeyZeroLongPress) object:nil];
    }
    else if (button.tag == ACTION_DEL_NUNMBER) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doKeyDelLongPress) object:nil];
    }
}

-(void)makeCall:(NSString*)peerNumber {
    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
    CallParams *callParams = appDelegate.callParams;
    callParams.isVideoCall = TRUE;
    [[SipEngineManager instance] makeCall:[[appDelegate current_account] getAccId] calleeUri:peerNumber callParams:callParams];
}

- (void)addContactWithPhonenum:(NSString*)phoneNum
{
    ABNewPersonViewController *npvc = [[ABNewPersonViewController alloc] init] ;
    CFErrorRef error = NULL;
    ABRecordRef people = ABPersonCreate();
    ABMutableMultiValueRef mutiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueIdentifier outIdentifier = 0;
    ABMultiValueAddValueAndLabel(mutiPhone,(__bridge CFTypeRef)phoneNum,kABPersonPhoneMainLabel, &outIdentifier);
    
    ABRecordSetValue(people, kABPersonPhoneProperty, mutiPhone, &error);
    CFRelease(mutiPhone);
    if (!error) {
        npvc.displayedPerson = people;
    }
    CFRelease(people);
    
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:npvc];
    npvc.newPersonViewDelegate = self;
    [self presentModalViewController:controller animated:YES];
}


#pragma mark NEW PERSON DELEGATE METHODS
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
    if (person)
    {
        [self dismissModalViewControllerAnimated:YES];
        [[ContactManagerUtil instance] readAllPeoples];
        if([ContactsTableViewController instance])
        {
            [[ContactsTableViewController instance] reloadAllContacts];
        }
    }else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)doKeyDelLongPress
{
    if (dialNumberLabel.text.length > 0) {
        dialNumberLabel.text = @"";
        [self textFieldTextChanged:dialNumberLabel.text];
    }

    if((dialNumberLabel.text && dialNumberLabel.text.length == 0))
        [self setupAddContactAndDeleteButton];}

- (void)doKeyZeroLongPress
{
    if (dialNumberLabel.text.length > 0) {
        dialNumberLabel.text = [dialNumberLabel.text substringToIndex:dialNumberLabel.text.length - 1];
        dialNumberLabel.text = [NSString stringWithFormat:@"%@+", dialNumberLabel.text];
        [self textFieldTextChanged:dialNumberLabel.text];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutSubviews
{
    CGRect bounds = self.view.bounds;
    float MaxX = CGRectGetMaxX(bounds);
    float MaxY = CGRectGetMaxY(bounds);
    float MinX = CGRectGetMinX(bounds);
    float MidX = CGRectGetMidX(bounds);
    
    float LineStartY = 0;
    int button_padding = kDefaultButtonPadding;
    int label_padding = 48;
    int label_height = 50;
    if(iPhone4)
    {
        button_padding -= 6;
        LineStartY = (MaxY - ((kDefaultButtonSize + kDefaultButtonPadding) * 4) - (button_padding / 2));
        label_padding = 24;
    }else if(iPhone5)
    {
        button_padding -= 6;
        LineStartY = (MaxY - ((kDefaultButtonSize + kDefaultButtonPadding) * 4) - button_padding);
        label_padding = 24;
    }else if(iPhone6)
    {
        LineStartY = ((MaxY / 2) - (MaxX / 4) - button_padding * 2);
    }else if(iPhone6plus)
    {
        LineStartY = ((MaxY / 2) - (MaxX / 4));
    }else if(isPad)
    {
        LineStartY = ((MaxY / 2) - (MaxX / 4));
        LineStartY += 50;
    }
    
    float LinePadding = kDefaultButtonSize + button_padding;
    float RowStartXLeft = ((MaxX / 3) - (kDefaultButtonSize / 2));
    float RowStartXCenter = (MaxX / 2);
    float RowStartXRight = (MaxX - (MaxX / 3) + (kDefaultButtonSize / 2));
    float RowPadding[3] =  {RowStartXLeft,RowStartXCenter,RowStartXRight};
    
    /*添加第一行显示*/
    float NumLabelStartY = (LineStartY / 2);
    
    if(iPhone4)
    {
        NumLabelStartY -= (label_height / 2);
    }
    
    if(isPad)
    {
        LinePadding += 32;
    }
    
    int top_button_size = 50;
    
    addContactButton.frame = CGRectMake(0,0,top_button_size, top_button_size);
    addContactButton.center = CGPointMake(MinX + label_padding, NumLabelStartY);
    
    
    deleteButton.frame = CGRectMake(0,0,top_button_size, top_button_size);
    deleteButton.center = CGPointMake(MaxX - label_padding, NumLabelStartY);
    
    
    dialNumberLabel.frame = CGRectMake(0,0,MaxX - (label_padding * 3.5), label_height);
    dialNumberLabel.center = CGPointMake(MidX, NumLabelStartY);
    
    NumLabelStartY += 20;
    
    CGSize fontSize = [contactNameLabel.text sizeWithFont:contactNameLabel.font];
    contactNameLabel.frame = CGRectMake(RowStartXCenter,NumLabelStartY,fontSize.width,fontSize.height);
    contactNameLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), contactNameLabel.frame.origin.y + (fontSize.height / 2));
    
    int btn_cnt = 0;
    float default_button_size = kDefaultButtonSize;
    
    if(isPad)
    {
        default_button_size = 82;
    }
    
    for(int i = 0; i < 4; i++) //绘制4行数字按钮
    {
        for(int j = 0; j < 3; j++){ //绘制每排3个数字按钮
            buttons[btn_cnt].frame = CGRectMake(0, 0, default_button_size, default_button_size);
            buttons[btn_cnt].center = CGPointMake(RowPadding[j], LineStartY);
            btn_cnt++;
        }
        
        LineStartY += LinePadding;
    }
    
    
    /*添加底部呼叫按钮*/
    float action_button_size = kActionButtonSize;
    float scale = 2.75;
    if(iPhone5)
    {
        LineStartY -= button_padding;
        scale = 2.5;
    }else if(iPhone4)
    {
        LineStartY -= button_padding;
        scale = 2.5;
    }else if(isPad)
    {
        action_button_size = 54;
    }
    
    makeVoiceCallButton.frame = CGRectMake(0,0,action_button_size * scale, action_button_size);
    makeVoiceCallButton.center = CGPointMake(RowStartXLeft + (kDefaultButtonPadding * 1.5), LineStartY);
    
    makeVideoCallButton.frame = CGRectMake(0,0,action_button_size * scale, action_button_size);
    makeVideoCallButton.center = CGPointMake(RowStartXRight - (kDefaultButtonPadding * 1.5), LineStartY);}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(void) OnRegistrationProgress:(Account *) account;
{
    [mStatusLabel setText:NSLocalizedString(@"Registering ...", @"")];
}

-(void) OnRegistrationSucess:(Account *) account;
{
    NSLog(@"=======OnRegistrationSucess=======");
    [mStatusLabel setText:NSLocalizedString(@"Online", @"Online")];
}

-(void) OnRegistrationCleared:(Account *) account;
{
    [mStatusLabel setText:NSLocalizedString(@"Offline", @"")];
}

-(void) OnRegisterationFailed:(Account *) account
                withErrorCode:(int) code
              withErrorReason:(NSString *) reason
{
    [mStatusLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Register failed, code [%d].", @""),(int)code]];
}

/*新呼叫*/
-(void)OnNewIncomingCall:(Call*)call
                  caller:(NSString*)caller
              video_call:(BOOL)video_call;
{
    
    [calling_screen_view setCurrentCall:call];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                return;
    }
    //[mStatusLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Incoming [%@] %@", @""),(video_enabled? @"Video Call" : @"Audio Call"), cid]];
        
    //[[UserSoundsPlayerUtil instance] playRinging];
    //[[UserSoundsPlayerUtil instance] playVibrate:YES];
        
    //[calling_screen_view setCallingMode:video_call? kVideoRinging : kAudioRinging];
    [self showCallingViewController:video_call playRinging:YES];
}

-(void)OnNewOutgoingCall:(Call*)call
                  caller:(NSString*)caller
              video_call:(BOOL)video_call;
{
    //[mStatusLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Outgoing [%@] %@", @""),(video_enabled? @"Video Call" : @"Audio Call"), cid]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationOutgoingCall object:nil];
    
    [calling_screen_view setCurrentCall:call];
    
    //[[UserSoundsPlayerUtil instance] playCalling];
    
    //[calling_screen_view setCallingMode:video_call? kVideoCalling : kAudioCalling];
    [self showCallingViewController:video_call playRinging:NO];
}

-(void)newOutgoingCall:(Call *)call video_call:(BOOL)video_call
{
    [calling_screen_view setCurrentCall:call];
    [self showCallingViewController:video_call playRinging:NO];
}

-(void)showCallingViewController:(BOOL)video_call
                     playRinging:(BOOL)play_ringing
{
    if(play_ringing)
    {
        [[UserSoundsPlayerUtil instance] playRinging];
        [[UserSoundsPlayerUtil instance] playVibrate:YES];
        [calling_screen_view setCallingMode:video_call? kVideoRinging : kAudioRinging];
    } else {
        [[UserSoundsPlayerUtil instance] playCalling];
        [calling_screen_view setCallingMode:video_call? kVideoCalling : kAudioCalling];
    }
    
    [self presentViewController:(UIViewController *)calling_screen_view animated:YES completion:nil];
}

-(void)setCallingNumber:(NSString *)number
{
    if(number)
    {
        dialNumberLabel.text = number;
        [self textFieldTextChanged:number];
        [self setupAddContactAndDeleteButton];
    }
}

/*外呼正在处理*/
-(void) OnCallProcessing:(Call *)call
{
    //[mStatusLabel setText:NSLocalizedString(@"Calling ...", @"")];
    [calling_screen_view setCallingStatusLabel:NSLocalizedString(@"Calling ...", @"")];
}

/*对方振铃*/
-(void) OnCallRinging:(Call *)call
{
    //[mStatusLabel setText:NSLocalizedString(@"Ringing", @"")];
    [calling_screen_view setCallingStatusLabel:NSLocalizedString(@"Ringing", @"")];
    //[[UserSoundsPlayerUtil instance] stopSoundPlay];
}

/*呼叫接通知识*/
-(void)OnCallConnected:(Call *)call
      withVideoChannel:(BOOL) video_enabled
       withDataChannel:(BOOL) data_enabled;
{
   
    //[mStatusLabel setText:[NSString stringWithFormat:NSLocalizedString(@"[%@] Answered", @""),(video_enabled? @"Video Call" : @"Audio Call")]];

    [calling_screen_view setCallingMode:video_enabled? kVideoAnswered : kAudioAnswered];
    //client::RTCVoiceEngine *voice_engine = [[SipEngineManager instance] getRTCVoiceEngine];
    //voice_engine->SetLoudspeakerStatus(video_enabled);
    [[UserSoundsPlayerUtil instance] stopSoundPlay];
}

/*呼叫保持*/
-(void) OnCallPaused:(Call *)call
{
    
}

-(void) OnCallResume:(Call *)call
{
    
}

/*呼叫结束*/
-(void) OnCallEnded:(Call *)call
{
    //[mStatusLabel setText:NSLocalizedString(@"Hangup", @"")];
    [calling_screen_view setCallingStatusLabel:NSLocalizedString(@"Hangup", @"")];
    if(calling_screen_view && [calling_screen_view isVideoCalling:call])
    {
        [[SipEngineManager instance] setVideoFrameInfoDelegate:nil];
    }
    
    [calling_screen_view setCurrentCall:nil];
    [calling_screen_view stopCallingUI];
    [[UserSoundsPlayerUtil instance] stopSoundPlay];
    
    //[self OncallReport:call->GetCallReport()];
    
    dialNumberLabel.text = @"";
    [self setupAddContactAndDeleteButton];
}

-(NSString *)dateInFormat:(time_t)dateTime format:(NSString*) stringFormat
{
    char buffer[80];
    const char *format = [stringFormat UTF8String];
    struct tm * timeinfo;
    timeinfo = localtime(&dateTime);
    strftime(buffer, 80, format, timeinfo);
    return [NSString  stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

/*-(void) OncallReport:(const client::CallReport *)cdr
{
    NSString *peer_num = [NSString stringWithUTF8String:cdr->dir == client::CallReport::kIncoming? cdr->from.c_str() : cdr->to.c_str()];
    
    NSString *start_date = [self dateInFormat:cdr->start_time format:@"%Y-%m-%d %H:%M:%S"];
    
    Contact *cc = [[ContactManagerUtil instance] getContactManager].do_search([peer_num UTF8String]);
    NSString *peer_name = @"";
    if(cc)
    {
        peer_name = [NSString stringWithUTF8String:cc->name().c_str()];
    }
    
    IVLog(@"CallReport: \nname=%@,\nfrom = %s,\nto=%s,\ndir=%s,\nduration=%d,\nstatus=%d,\nvideo_call=%s,\nstart_time=%s",
          peer_name,
          cdr->from.c_str(),cdr->to.c_str(),
          cdr->dir == client::CallReport::kIncoming? "Incoming" : "Outgoing",
          cdr->duration,
          cdr->status,
          cdr->video_call? "True" : "False",
          [start_date UTF8String]);
    

    
    int status = 0;
    
    if(cdr->dir == client::CallReport::kIncoming)
    {
        status = (cdr->status == client::CallReport::kCallAnswered)? kIncomingCall : kIncomingMissed;
    }else
    {
        status = (cdr->status == client::CallReport::kCallAnswered)? kOutgoingCall : kOutgoingFailed;
    }

    [[UserCallReportUtil instance] getCdrDatabase]->cdr_insert(0, status, cdr->duration, cdr->video_call, [peer_name UTF8String], [peer_num UTF8String], [start_date UTF8String], "");
}*/

/*接到视频通话邀请*/
- (void)UpdatedByRemote:(Call *)call has_video:(BOOL)video {
    printf("========UpdatedByRemote=====:\n");
}

/*主动发起视频，返回结果*/
- (void)UpdatingByLocal:(Call *)call has_video:(BOOL)video {
     printf("========UpdatingByLocal=====:\n");
}

- (void)OnDtmfEvent:(int)callId dtmf:(int)dtmf duration:(int)duration up:(int)up
{
    
}

const NSString *GetCallFailedString(int code)
{
    switch(code)
    {
        case Unauthorized:
            return NSLocalizedString(@"Unauthorized", @"");//@"账户认证失败";
            break;
        case BadRequest:
            return NSLocalizedString(@"BadRequest", @"");//@"无效的请求";
            break;
        case PaymentRequired:
            return NSLocalizedString(@"PaymentRequired", @"");//@"需要支付费用";
            break;
        case  Forbidden:
            return NSLocalizedString(@"Forbidden", @"");//@"禁止呼叫";
            break;
        case  MethodNotAllowed:
            return NSLocalizedString(@"MethodNotAllowed", @"");//@"请求不被允许";
            break;
        case  ProxyAuthenticationRequired:
            return NSLocalizedString(@"ProxyAuthenticationRequired", @"");//@"代理要求验证";
            break;
        case RequestTimeout:
            return NSLocalizedString(@"RequestTimeout", @"");//@"请求超时";
            break;
        case  NotFound:
            return NSLocalizedString(@"NotFound", @"");//@"对方不在线";
            break;
        case UnsupportedMediaType:
            return NSLocalizedString(@"UnsupportedMediaType", @"");//@"媒体不被支持";
            break;
        case  BusyHere:
            return NSLocalizedString(@"BusyHere", @"");//@"对方正忙";
            break;
        case TemporarilyUnavailable:
            return NSLocalizedString(@"TemporarilyUnavailable", @"");//@"请求暂时无效";
            break;
        case  RequestTerminated:
            return NSLocalizedString(@"RequestTerminated", @"");//@"请求被终止";
            break;
        case ServerInternalError:
            return NSLocalizedString(@"ServerInternalError", @"");//@"内部服务器错误";
            break;
        case  DoNotDisturb:
            return NSLocalizedString(@"DoNotDisturb", @"");//@"请勿打扰";
            break;
        case  Declined:
            return NSLocalizedString(@"Declined", @"");//@"谢绝呼叫,对方挂机";
            break;
        case RequestSendFailed:
            return NSLocalizedString(@"RequestSendFailed", @"");//@"被叫连接失效";
            break;
        case MediaStreamTimeout:
            return NSLocalizedString(@"MediaStreamTimeout", @"");//@"媒体流传输超时";
            break;
            case CouldNotCall:
            return NSLocalizedString(@"CouldNotCall", @"");//@"无法建立呼叫";
            break;
        case None:
            return NSLocalizedString(@"None", @"");//@"未知状态";
            break;

    }
    
    return @"未知状态";
}

/*呼叫失败，并返回错误代码，代码对应的含义，请参考common_types.h*/
- (void)OnCallFailed:(Call *)call withErrorCode:(int)error_code reason:(NSString *)reason
{
    //NSString  *text = [NSString stringWithFormat:NSLocalizedString(@"CallFailed, [%d] %@!", @""),error_code,GetCallFailedString(error_code)];
    //[mStatusLabel setText:text];
    
    [calling_screen_view setCallingStatusLabel:[NSString stringWithFormat:NSLocalizedString(@"Call failed, [%d]",@""),error_code]];
    if(calling_screen_view && [calling_screen_view isVideoCalling:call])
    {
        [calling_screen_view stopVideo];
        [[SipEngineManager instance] setVideoFrameInfoDelegate:nil];
    }
    
    [calling_screen_view setCurrentCall:nil];
    [calling_screen_view stopCallingUI];
    [[UserSoundsPlayerUtil instance] stopSoundPlay];
    //[self OncallReport:call->GetCallReport()];
    
    dialNumberLabel.text = @"";
    [self setupAddContactAndDeleteButton];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)showMenu:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Select A Line"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"LINE 1"
                     image:[UIImage imageNamed:@"action-voicecall"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"LINE 2"
                     image:[UIImage imageNamed:@"action-voicecall"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"LINE 3"
                     image:[UIImage imageNamed:@"action-voicecall"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"LINE 4"
                     image:[UIImage imageNamed:@"action-voicecall"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Ext Call"
                     image:[UIImage imageNamed:@"action-voicecall"]
                    target:self
                    action:@selector(pushMenuItem:)],

      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

- (void) pushMenuItem:(id)sender
{
    KxMenuItem *item = (KxMenuItem*)sender;
    if ([item.title  isEqualToString:@"Ext Call"]) {
        //[[SipEngineManager instance] MakeCall:dialNumberLabel.text withVideoCall:false displayName:nil];
    }
    NSLog(@"%@", sender);
}
@end
