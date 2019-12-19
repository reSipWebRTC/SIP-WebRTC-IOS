
#import "RecentsTableViewController.h"
#import "RecentDetailViewController.h"
#import "RecentCell.h"
#import "CommonTypes.h"
#import "UserCallReportUtil.h"
#import "UserContactUtil.h"
#import <reSipWebRTCSDK/SipEngineManager.h>
#import "UIImage+ARDUtilities.h"

@interface RecentsTableViewController ()
{
    NSInteger show_cdr_type;
    NSInteger nb_max_cdrs;
    NSMutableArray* typeArray;
    UISegmentedControl *segmentedControl;
}
@end

@implementation RecentsTableViewController

@synthesize targetPhonenum;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    show_cdr_type = kAllCalls;
    nb_max_cdrs = NB_MAX_CDR_RECORD;
    
    [self initSubViews];
    
}

-(void)initSubViews
{
    segmentedControl = [ [ UISegmentedControl alloc ] initWithItems: nil ];
    segmentedControl.segmentedControlStyle =
    UISegmentedControlStyleBar;
    [ segmentedControl insertSegmentWithTitle:
     @"All" atIndex:0 animated: NO ];
    [ segmentedControl insertSegmentWithTitle:
     @"Missed" atIndex:1 animated: NO ];
    
    segmentedControl.selectedSegmentIndex  = 0;
    
    self.navigationItem.titleView = segmentedControl;
    
    [ segmentedControl addTarget: self
                          action: @selector(controlPressed:)
                forControlEvents: UIControlEventValueChanged
     ];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //[button setBackgroundImage:[UIImage imageForName:@"add_buddy.png" color:buttonBlueColor] forState:UIControlStateNormal];
    
    [button setTitle:@"Clear" forState:UIControlStateNormal];
    [button setTitleColor:buttonBlueColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clearCallReportAction)
     forControlEvents:UIControlEventTouchUpInside];
    
    CGSize fontSize = [button.titleLabel.text sizeWithFont:button.titleLabel.font];
    button.frame = CGRectMake(0, 0, fontSize.width, fontSize.height);
    
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = menuButton;
}

- (void) controlPressed:(id)sender {
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    NSLog(@"Segment %d selected\n", (int)selectedSegment);
    show_cdr_type = (selectedSegment == 0)? kAllCalls : kAllMissedCall;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)clearCallReportAction
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:NSLocalizedString(@"Are you sure you want to clear Call records", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                          otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [self clearCallReport];
    }
}

-(void)clearCallReport
{
    CdrDatabase *cdr_db = [[UserCallReportUtil instance] getCdrDatabase];
    cdr_db->cdr_remove_all();
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if (tableView == sourceTableView)
    {
        CdrDatabase *cdr_db = [[UserCallReportUtil instance] getCdrDatabase];
        NSInteger cdr_count = cdr_db->cdr_size((int)show_cdr_type);
        //IVLog(@"cdrs size:%d max:%d", cdr_count, nb_max_cdrs);
        if(cdr_count>nb_max_cdrs) return nb_max_cdrs;
        else return cdr_count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRecentCellHeight;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (tableView == sourceTableView)
    {
        CdrDatabase *cdr_db = [[UserCallReportUtil instance] getCdrDatabase];
        call_report_t *cdr = cdr_db->cdr_at((int)indexPath.row,(int)show_cdr_type);
        
        NSString *timeStr;
        NSString *dateString;
        NSInteger days_diff;
        
        static NSString* identifier = @"RecentCell";
        RecentCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            NSArray* array = [[UINib nibWithNibName:@"RecentCell" bundle:nil] instantiateWithOwner:self options:nil];
            cell = [array lastObject];
            CGRect bounds = self.view.bounds;
            float MaxX = CGRectGetMaxX(bounds);
            cell.frame = CGRectMake(0,0,MaxX, kRecentCellHeight);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell initSubviews];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
        
        [cell setUserData:cdr];
        cell.detailButton.tag = indexPath.row;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
        timeStr = [NSString stringWithFormat:@"%s",cdr->start_date];
        
        NSDate* date = [formatter dateFromString:timeStr];
        NSDate *datenow = [NSDate date];
        
        {
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            unsigned int unitFlags = NSDayCalendarUnit;
            NSDateComponents *comps = [gregorian components:unitFlags fromDate:date  toDate:datenow  options:0];
            days_diff = [comps day];
        }
        if (cdr->status == kOutgoingCall) {
            cell.nameLabel.textColor = RGBCOLOR(90, 89, 89);
        }else if(cdr->status == kIncomingCall){
            cell.nameLabel.textColor = RGBCOLOR(90, 89, 89);
        }else if(cdr->status == kOutgoingFailed){
            cell.nameLabel.textColor = [UIColor redColor];
        }else if(cdr->status == kIncomingMissed){
            cell.nameLabel.textColor = [UIColor redColor];
        }
        if (days_diff == 0) {
            dateString = [NSDateFormatter localizedStringFromDate:date dateStyle: NSDateFormatterNoStyle timeStyle: NSDateFormatterShortStyle];
        }else if(days_diff == 1)
        {
            dateString = NSLocalizedString(@"Yesterday", @"");
        }else if(days_diff <= 4)
        {
            [formatter setDateFormat:@"EEEE"];
            dateString = [formatter stringFromDate:date];
        }else if(days_diff > 4){
            [formatter setDateFormat:@"YY-MM-dd"];
            dateString = [formatter stringFromDate:date];
        }
        //[cell.nameLabel setText:[NSString stringWithCString:cdr->name? cdr->name:cdr->number encoding:NSUTF8StringEncoding]];
        cell.nameLabel.text = [[ContactManagerUtil instance] doPhoneSearch:[NSString stringWithCString:cdr->number encoding:[NSString defaultCStringEncoding]]];
        [cell.timeLabel setText:[NSString stringWithFormat:@"%@",dateString]];
    
        
        if(cdr->status == kOutgoingFailed)
        {
            [cell setDurationLabel:NSLocalizedString(@"Cancel", @"")];
        }
        
        if(cdr->status == kIncomingMissed)
        {
            [cell setDurationLabel:NSLocalizedString(@"Missed", @"")];
        }
        
        if(cdr->status == kOutgoingCall || cdr->status == kIncomingCall)
        {
            [cell setDurationLabel:[NSString stringWithFormat:NSLocalizedString(@"%ds ", @""),cdr->duration]];
        }
        
        
        if(cdr->status == kOutgoingCall || cdr->status == kOutgoingFailed )
        {
            cell.thumbnailImageView.image = [UIImage imageForName:(cdr->video_call)? @"recents-videoout.png" : @"recents-voiceout.png" color:contactHeadBlueColor];
            
        }else if(cdr->status == kIncomingCall || cdr->status == kIncomingMissed )
        {
            cell.thumbnailImageView.image = [UIImage imageForName:(cdr->video_call)? @"recents-videoin.png" : @"recents-voicein.png" color:contactHeadBlueColor];
        }

        NSInteger count = cdr->details_.size();
        [cell setRecordCount:(int)count + 1];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///if (tableView == sourceTableView)
    {
        CdrDatabase *cdr_db = [[UserCallReportUtil instance] getCdrDatabase];
        RecentCell* cell = (RecentCell*)[tableView cellForRowAtIndexPath:indexPath];
        cdr_db->cdr_remove((call_report*)[cell getUserData]);
        [tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RecentDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"RecentDetailViewController"];
    
    RecentCell* cell = (RecentCell*)[tableView cellForRowAtIndexPath:indexPath];
    call_report_t* cdr = (call_report_t *)[cell getUserData];
    controller.cdr = cdr;
    
    Contact* contact = [[ContactManagerUtil instance] getContactManager].do_search(cdr->number);
    
    if(!contact)
    {
        controller.contact = new Contact("",cdr->number,"",false,true);
    }else{
        controller.contact = contact;
    }
    [self.navigationController pushViewController:controller animated:YES];
    
#if 0
    RecentCell* cell = (RecentCell*)[tableView cellForRowAtIndexPath:indexPath];
    call_report_t* cdr = (call_report_t *)[cell getUserData];
    if (![[SipEngineManager instance] NetworkIsReachable]) {
        self.targetPhonenum = [NSString stringWithCString:cdr->number encoding:[NSString defaultCStringEncoding]];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"Network not available, make call with GSM ?", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"Sure", @""), nil];
        alert.tag = 1;
        [alert show];
        return;
    }
    
    [[SipEngineManager instance] MakeCall:[NSString stringWithUTF8String:cdr->number] withVideoCall:cdr->video_call displayName:nil];
#endif
}

- (void)handleDetailAction:(UIButton*)sender
{
#if 0
    int index = sender.tag;
    RecentCell* cell = (RecentCell*)[sourceTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    call_report_t *cdr = (call_report_t*)[cell getUserData];
    ContactDetailViewController* controller = [[ContactDetailViewController alloc] initWithNibName:iPhone5?@"ContactDetailViewController-5" : @"ContactDetailViewController" bundle:nil];
    controller.phonenum = [NSString stringWithCString:cdr->number encoding:NSUTF8StringEncoding];
    //    controller.filter = 5;
    controller.backTitle = NSLocalizedString(@"Back", @"");
    controller.callreport = cdr;
    controller.mDelegate = SharedAppDelegate.contactViewController;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
#endif
}

@end
