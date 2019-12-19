
#import "RecentDetailViewController.h"
#import "CustomButton.h"
#import "CommonTypes.h"
#import "UIImage+ARDUtilities.h"
#import <reSipWebRTCSDK/SipEngineManager.h>
#import "RecordHeaderCell.h"
#import "RecordCell.h"

#import "KeyPadViewController.h"
#import "MainTabBarViewController.h"
#import "AppDelegate.h"

#include <string>
#include <vector>

@interface RecentDetailViewController ()
{
    UIImageView *headImageView_;
    UILabel *headContactNameLabel_;
    UIButton *makeVoiceCallButton;
    UIButton *makeVideoCallButton;
    UIButton *navigationMoreButton_;
    
    UIView *phoneNumbersView_;
    UIView *callReportViews_;
    NSString *first_number_;
    UIImageView *line_image0_;
    UIImageView *line_image_;
}
@end

@implementation RecentDetailViewController

@synthesize contact;
@synthesize cdr;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
    [self layoutSubviews];
    
    first_number_  = [NSString stringWithUTF8String:self.contact->phone().c_str()];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubViews
{
    UIColor *button_color = buttonBlueColor;

    makeVoiceCallButton = [CustomButton addButton:@"action-voicecall.png" backgroundColor:button_color mainColor:[UIColor clearColor] highlightedColor:[UIColor whiteColor] setBorder:NO tag:ACTION_MAKE_AUDIO_CALL button_size:kActionButtonSize];
    
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
    
    makeVideoCallButton = [CustomButton addButton:@"action-videocall.png" backgroundColor:button_color mainColor:[UIColor clearColor] highlightedColor:[UIColor whiteColor] setBorder:NO tag:ACTION_MAKE_VIDEO_CALL button_size:kActionButtonSize];
    
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
    
    headContactNameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    headContactNameLabel_.font = [UIFont systemFontOfSize:24];
    [headContactNameLabel_ setTextAlignment:NSTextAlignmentCenter];
    
    if(self.contact->name().length() > 0 )
    {
        headContactNameLabel_.text = [NSString stringWithUTF8String:self.contact->name().c_str()];
    }else{
        headContactNameLabel_.text = [NSString stringWithUTF8String:self.contact->phone().c_str()];
    }
    
    [headContactNameLabel_ setBackgroundColor:[UIColor clearColor]];
    [headContactNameLabel_ setTextColor:[UIColor grayColor]];
    
    [self.view addSubview:headContactNameLabel_];
    
    headImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"call-contact-head.png" color:[UIColor whiteColor]]];
    
    [headImageView_ setBackgroundColor:contactHeadBlueColor];
    headImageView_.contentMode = UIViewContentModeCenter;
    headImageView_.layer.cornerRadius = kContactHeadButtonSize / 2;
    headImageView_.layer.masksToBounds = YES;
    
    [self.view addSubview:headImageView_];
    
    line_image0_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    line_image0_.backgroundColor = [UIColor grayColor];
    line_image0_.alpha = 0.15;
    [self.view addSubview:line_image0_];
    
    line_image_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    line_image_.backgroundColor = [UIColor grayColor];
    line_image_.alpha = 0.15;
    [self.view addSubview:line_image_];
    
    phoneNumbersView_ = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:phoneNumbersView_];
    
    callReportViews_ = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:callReportViews_];
}

- (void)layoutSubviews
{
    CGRect bounds = self.view.bounds;
    float MaxX = CGRectGetMaxX(bounds);
    float MaxY = CGRectGetMaxY(bounds);
    float RowStartXLeft = ((MaxX / 3) - (kDefaultButtonSize / 2));
    float RowStartXCenter = (MaxX / 2);
    float RowStartXRight = (MaxX - (MaxX / 3) + (kDefaultButtonSize / 2));
    float LabelY = (MaxY / 8) + (kContactHeadButtonSize / 2);
    
    float ContactHeadButtonSize = kContactHeadButtonSize;
    
    if(iPhone4)
    {
        LabelY = ((MaxY / 8) - (MaxX / 16)) + 20;
    }

    headImageView_.frame = CGRectMake(0.0f,0.0f,ContactHeadButtonSize,ContactHeadButtonSize);
    headImageView_.center = CGPointMake(RowStartXCenter,LabelY);
    
    LabelY +=  (ContactHeadButtonSize / 2);
    if(iPhone4)
    {
        LabelY += 12.5;
    }else
    {
        LabelY += 25;
    }
    
    CGSize fontSize = [headContactNameLabel_.text sizeWithFont:headContactNameLabel_.font];
    headContactNameLabel_.frame = CGRectMake(0.0f,0.0f,fontSize.width,fontSize.height);
    headContactNameLabel_.center = CGPointMake(RowStartXCenter,LabelY);
    
    LabelY += fontSize.height;
    if(iPhone4)
    {
        LabelY += 12.5;
    }else
    {
        LabelY += 25;
    }
    
    /*添加拨号按钮*/
    float action_button_size = kActionButtonSize;
    float scale = iPhone5? 2.5 : 2.75;
    
    makeVoiceCallButton.frame = CGRectMake(0,0,action_button_size * scale, action_button_size);
    makeVoiceCallButton.center = CGPointMake(RowStartXLeft + (kDefaultButtonPadding * 1.5), LabelY);
    
    makeVideoCallButton.frame = CGRectMake(0,0,action_button_size * scale, action_button_size);
    makeVideoCallButton.center = CGPointMake(RowStartXRight - (kDefaultButtonPadding * 1.5), LabelY);
    
    
    /*显示通话记录*/
    
    if(iPhone4)
    {
        LabelY += (kActionButtonSize / 2);
    }else
    {
        LabelY += kActionButtonSize;
    }
    
    LabelY += 10;
    
    line_image0_.frame = CGRectMake(0,0,MaxX - (kDefaultButtonPadding * 2), 1);
    line_image0_.center = CGPointMake(RowStartXCenter, LabelY);
    LabelY += 10;
    
    float callReportSubViewHeight = 0;
    if (self.cdr)
    {
        for (UIView* view in [callReportViews_ subviews]) {
            [view removeFromSuperview];
        }
        NSString* lastState = nil;
        float inViewHeight = 0;
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        UIImageView* imageview = [[UIImageView alloc] initWithFrame:CGRectMake(1, inViewHeight, 302, 1)];
        imageview.image = [UIImage imageNamed:@"seperator.png"];
        [callReportViews_ addSubview:imageview];
        inViewHeight += 1;
        RecordHeaderCell* headerView = [RecordHeaderCell getNewCell];
        if (cdr->status == kIncomingCall || cdr->status == kIncomingMissed) {
            headerView.stateLabel.text = NSLocalizedString(@"Incoming Call", @"");
        }
        else {
            headerView.stateLabel.text = NSLocalizedString(@"Outgoing Call", @"");
        }
        lastState = headerView.stateLabel.text;
        NSDate* date = [formatter dateFromString:[NSString stringWithFormat:@"%s",cdr->start_date]];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        headerView.timeLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
        [callReportViews_ addSubview:headerView];
        headerView.frame = CGRectMake(0, inViewHeight, headerView.frame.size.width, headerView.frame.size.height);
        inViewHeight += headerView.frame.size.height;
        RecordCell* recordView = [RecordCell getNewCell];
        [formatter setDateFormat:@"HH:mm"];
        recordView.timeLabel.text = [formatter stringFromDate:date];
        if (cdr->status == kIncomingCall || cdr->status == kOutgoingCall) {
            recordView.stateLabel.text = [NSString stringWithFormat:@"%@ %.2d:%.2d", NSLocalizedString(@"Duration", @""), cdr->duration/60, cdr->duration%60];
        }
        else if (cdr->status == kIncomingMissed) {
            recordView.stateLabel.text = NSLocalizedString(@"Missed", @"");
        }
        else {
            recordView.stateLabel.text = NSLocalizedString(@"Canceled", @"");
        }
        
        if(cdr->status == kOutgoingCall || cdr->status == kOutgoingFailed )
        {
            recordView.stateImageView.image = [UIImage imageForName:(cdr->video_call)? @"recentinfo-videoout.png" : @"recentinfo-voiceout.png" color:contactHeadBlueColor];
            
        }else if(cdr->status == kIncomingCall || cdr->status == kIncomingMissed )
        {
            recordView.stateImageView.image = [UIImage imageForName:(cdr->video_call)? @"recentinfo-videoin.png" : @"recentinfo-voicein.png" color:contactHeadBlueColor];
        }
        
        [recordView.stateImageView setBackgroundColor:[UIColor clearColor]];
        
        [callReportViews_ addSubview:recordView];
        recordView.frame = CGRectMake(0, inViewHeight, recordView.frame.size.width, recordView.frame.size.height);
        inViewHeight += recordView.frame.size.height;
        
        if (cdr->details_.size() > 0) {
            std::vector<call_report_detail> vectorReportIncoming;
            std::vector<call_report_detail> vectorReportOutgoing;
            for (NSInteger i = cdr->details_.size() - 1; i >= 0; i--) {
                call_report_detail* detail = cdr->details_[i];
                if (detail->status == kIncomingCall || detail->status == kIncomingMissed) {
                    vectorReportIncoming.push_back(*detail);
                }
                else {
                    vectorReportOutgoing.push_back(*detail);
                }
            }
            std::vector<call_report_detail> vectorAll;
            if ([lastState isEqualToString:NSLocalizedString(@"Incoming Call", @"")]) {
                for (int i = 0; i < vectorReportOutgoing.size(); i++) {
                    if(vectorReportIncoming.size() > 0)
                        vectorReportIncoming.push_back(vectorReportIncoming[i]);
                }
                vectorAll = vectorReportIncoming;
            }
            else {
                for (int i = 0; i < vectorReportIncoming.size(); i++) {
                    if(vectorReportIncoming.size() > 0)
                        vectorReportOutgoing.push_back(vectorReportIncoming[i]);
                }
                vectorAll = vectorReportOutgoing;
            }
            for (int i = 0; i < vectorAll.size(); i++) {
                call_report_detail* detail = &vectorAll[i];
                
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                NSDate* date = [formatter dateFromString:[NSString stringWithFormat:@"%s",detail->start_date]];
                NSString* state = nil;
                if (detail->status == kIncomingCall || detail->status == kIncomingMissed) {
                    state = NSLocalizedString(@"Incoming Call", @"");
                }
                else {
                    state = NSLocalizedString(@"Outgoing Call", @"");
                }
                if (![lastState isEqualToString:state]) {
                    lastState = state;
                    RecordHeaderCell* headerView = [RecordHeaderCell getNewCell];
                    headerView.stateLabel.text = state;
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                    headerView.timeLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
                    [callReportViews_ addSubview:headerView];
                    headerView.frame = CGRectMake(0, inViewHeight, headerView.frame.size.width, headerView.frame.size.height);
                    inViewHeight += headerView.frame.size.height;
                    lastState = headerView.stateLabel.text;
                }
                RecordCell* recordView = [RecordCell getNewCell];
                [formatter setDateFormat:@"HH:mm"];
                recordView.timeLabel.text = [formatter stringFromDate:date];
                if (detail->status == kIncomingCall || detail->status == kOutgoingCall) {
                    recordView.stateLabel.text = [NSString stringWithFormat:@"%@ %.2d:%.2d", NSLocalizedString(@"Duration", @""), detail->duration/60, detail->duration%60];
                }
                else if (detail->status == kIncomingMissed) {
                    recordView.stateLabel.text = NSLocalizedString(@"Missed", @"");
                }
                else {
                    recordView.stateLabel.text = NSLocalizedString(@"Canceled", @"");
                }
                if(detail->status == kOutgoingCall || detail->status == kOutgoingFailed )
                {
                    recordView.stateImageView.image = [UIImage imageForName:(detail->video_call)? @"recentinfo-videoout.png" : @"recentinfo-voiceout.png" color:contactHeadBlueColor];
                    
                }else if(detail->status == kIncomingCall || detail->status == kIncomingMissed )
                {
                    recordView.stateImageView.image = [UIImage imageForName:(detail->video_call)? @"recentinfo-videoin.png" : @"recentinfo-voicein.png" color:contactHeadBlueColor];
                }
                [callReportViews_ addSubview:recordView];
                recordView.frame = CGRectMake(0, inViewHeight, recordView.frame.size.width, recordView.frame.size.height);
                inViewHeight += recordView.frame.size.height;
            }
        }
        UIImageView* imageviews = [[UIImageView alloc] initWithFrame:CGRectMake(1, inViewHeight, 302, 1)];
        imageviews.image = [UIImage imageNamed:@"seperator.png"];
        [callReportViews_ addSubview:imageviews];
        callReportSubViewHeight += inViewHeight + kMarginVertical;
    }
    else {
        callReportViews_.hidden = YES;
    }

    float callReportViewLabelWidth = MaxX - (kDefaultButtonPadding * 2);
    
    callReportViews_.frame = CGRectMake(0,0,callReportViewLabelWidth, callReportSubViewHeight);
    callReportViews_.center = CGPointMake(RowStartXCenter, LabelY + (callReportSubViewHeight / 2));
    
    
    LabelY += callReportSubViewHeight + 10;
    
    float phoneNumberViewLabelWidth = MaxX - (kDefaultButtonPadding * 2);
    for(UIView *subview in [phoneNumbersView_ subviews]) {
        [subview removeFromSuperview];
    }
    
    /*仅显示当前号码的联系人信息*/
    std::vector<phone_info> phones_infos = self.contact->phoneInfo();
    float phoneNumberViewLabelHeight = 0;
    float phoneSubViewHeight = 45;
    phone_info_t *phone_info = nil;
    for(int i = 0; i < phones_infos.size(); i++)
    {
        phone_info_t *info = &phones_infos.at(i);
        if(info->phonenum == self.cdr->number)
        {
            phone_info = info;
            break;
        }
    }
    
    line_image_.hidden = YES;
    if(phone_info)
    {
        line_image_.hidden = NO;
        line_image_.frame = CGRectMake(0,0,MaxX - (kDefaultButtonPadding * 2), 1);
        line_image_.center = CGPointMake(RowStartXCenter, LabelY);
        LabelY += 10;
        
        phoneNumberViewLabelHeight = 0 * phoneSubViewHeight;
        CGRect rect = CGRectMake(0,phoneNumberViewLabelHeight,phoneNumberViewLabelWidth, phoneSubViewHeight);
        UIView *subPhoneView = [[UIView alloc] initWithFrame:rect];
        
        UILabel *phone_type = [[UILabel alloc] initWithFrame:CGRectZero];
        [phone_type setBackgroundColor:[UIColor clearColor]];
        [phone_type setAlpha:0.55f];
        [phone_type setTextColor:[UIColor blackColor]];
        phone_type.font = [UIFont systemFontOfSize:12];
        [phone_type setTextAlignment:NSTextAlignmentCenter];
        phone_type.text = [NSString stringWithUTF8String:phone_info->type.c_str()];
        [subPhoneView addSubview:phone_type];
        
        UILabel *phone_num = [[UILabel alloc] initWithFrame:CGRectZero];
        phone_num.text = [NSString stringWithUTF8String:phone_info->phonenum.c_str()];
        [phone_num setBackgroundColor:[UIColor clearColor]];
        [phone_num setAlpha:0.75f];
        [phone_num setTextColor:[UIColor blackColor]];
        phone_num.font = [UIFont systemFontOfSize:17];
        [phone_num setTextAlignment:NSTextAlignmentCenter];
        [subPhoneView addSubview:phone_num];
        
        UIButton *gsm_call_button = [CustomButton addCleanButton:@"action-regularcall.png" backgroundColor:[UIColor clearColor] mainColor:buttonBlueColor setBorder:YES tag:0 button_size:kCleanActionButtonSize];
        
        [gsm_call_button addTarget:self
                                action:@selector(onGSMCallButtonClicked:)
                      forControlEvents:UIControlEventTouchUpInside];
        
        [subPhoneView addSubview:gsm_call_button];
        
        UIButton *sms_button = [CustomButton addCleanButton:@"action-message.png" backgroundColor:[UIColor clearColor] mainColor:buttonBlueColor setBorder:YES tag:0 button_size:kCleanActionButtonSize];
        
        [sms_button addTarget:self
                                action:@selector(onSMSButtonClicked:)
                      forControlEvents:UIControlEventTouchUpInside];
        
        [subPhoneView addSubview:sms_button];
        
        
        /*布局每一条记录*/
        
        /*类型
          号码              gsmcall   sms
         */
        CGRect sub_view_bounds = subPhoneView.bounds;
        CGSize fontSize = [phone_type.text sizeWithFont:phone_type.font];
        phone_type.frame = CGRectMake(4,CGRectGetMinY(sub_view_bounds) - 3,fontSize.width,fontSize.height);
        fontSize = [phone_num.text sizeWithFont:phone_num.font];
        phone_num.frame = CGRectMake(3,CGRectGetMinY(sub_view_bounds) + 8,fontSize.width,fontSize.height);
        
        gsm_call_button.frame  = CGRectMake(phoneNumberViewLabelWidth - (kCleanActionButtonSize * 2) - (kDefaultButtonPadding * 2) - (kCleanActionButtonSize / 2),CGRectGetMinY(sub_view_bounds),kCleanActionButtonSize,kCleanActionButtonSize);
        
        sms_button.frame = CGRectMake(phoneNumberViewLabelWidth - (kDefaultButtonPadding * 2) - (kCleanActionButtonSize / 2),CGRectGetMinY(sub_view_bounds),kCleanActionButtonSize,kCleanActionButtonSize);
        
        [phoneNumbersView_ addSubview:subPhoneView];
    }
    
    phoneNumberViewLabelHeight += phoneSubViewHeight;
    
    phoneNumbersView_.frame = CGRectMake(0,0,phoneNumberViewLabelWidth, phoneNumberViewLabelHeight + phoneSubViewHeight);
    phoneNumbersView_.center = CGPointMake(RowStartXCenter, LabelY + ((phoneNumberViewLabelHeight + phoneSubViewHeight)/ 2));
    
}

-(void) onGSMCallButtonClicked:(id)sender
{
    UIButton *button = sender;
    NSInteger phone_index = button.tag;
    NSString *number = [NSString stringWithUTF8String:self.contact->phones().at(phone_index).c_str()];
    UIWebView*callWebview =[[UIWebView alloc] init];
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",number]];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    //记得添加到view上
    [self.view addSubview:callWebview];
}

- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    [alert show];
}


-(void)displaySMSComposerSheet:(NSString *)recipient
{
    
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = [NSArray arrayWithObject:recipient];
        controller.body = @"";
        controller.messageComposeDelegate = self;
        
        [self presentModalViewController:controller animated:YES];
        
        //[[[[controller viewControllers] lastObject] navigationItem] setTitle:@"测试短信"];//修改短信界面标题
    }else{
        
        [self alertWithTitle:@"提示信息" msg:@"设备没有短信功能"];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
            
        case MessageComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
            
        case MessageComposeResultSent:
             NSLog(@"Result: Sent");
            break;
            
        case MessageComposeResultFailed:
            NSLog(@"Result: Failed");
            break;
            
        default:
            
            break;
            
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

-(void) onSMSButtonClicked:(id)sender
{
    UIButton *button = sender;
    NSInteger phone_index = button.tag;
    NSString *number = [NSString stringWithUTF8String:self.contact->phones().at(phone_index).c_str()];
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    
    if (messageClass != nil) {
        
        if ([messageClass canSendText]) {
            
            [self displaySMSComposerSheet:number];
            
        }else {
            //设备没有短信功能
         }
        
    }else {
        // iOS版本过低,iOS4.0以上才支持程序内发送短信
    }
}

-(void) onButtonTouchDown:(id)sender
{
    
}

-(void) onButtonUpInSide:(id)sender
{
    UIButton *button = sender;
    if(button.tag == ACTION_MAKE_VIDEO_CALL) // 视频呼叫
    {
        if (first_number_.length > 0)
        {
#if OEM_VERSION
            [[KeyPadViewController instance] setCallingNumber:first_number_];
            [[MainTabBarViewController instance] setMainTabBarSelectedIndex:2];
#else
            //[[SipEngineManager instance] MakeCall:first_number_ withVideoCall:true displayName:nil];
#endif
        }
    }else if(button.tag == ACTION_MAKE_AUDIO_CALL) //音频呼叫
    {
        if (first_number_.length > 0)
        {
#if OEM_VERSION
            [[KeyPadViewController instance] setCallingNumber:first_number_];
            [[MainTabBarViewController instance] setMainTabBarSelectedIndex:2];
#else
            //[[SipEngineManager instance] MakeCall:first_number_ withVideoCall:false displayName:nil];           
#endif
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.view layoutIfNeeded];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
