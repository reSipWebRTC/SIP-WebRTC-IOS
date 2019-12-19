
#import "SettingsViewController.h"
#import <reSipWebRTCSDK/SipEngineManager.h>
#import "AppDelegate.h"

#ifdef USES_IASK_STATIC_LIBRARY
#import "InAppSettingsKit/IASKSettingsReader.h"
#else
#import "IASKSettingsReader.h"
#endif

@interface SettingsViewController ()
{
    
}
@property (nonatomic) UIPopoverController* currentPopoverController;
@end

@implementation SettingsViewController

@synthesize navigationController;
@synthesize appSettingsViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    navigationController = [[UINavigationController alloc] init];
    
    if (!appSettingsViewController) {
        appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
        appSettingsViewController.delegate = self;
        
        [self setupHiddenKeys:NO];
        
        appSettingsViewController.showDoneButton = NO;
        appSettingsViewController.showCreditsFooter = NO;
    }
    [navigationController.view setBackgroundColor:[UIColor clearColor]];
    [navigationController pushViewController:appSettingsViewController animated:FALSE];
    [self.view addSubview:navigationController.view];
    
    settting_changed_ = NO;
}

- (void)setupHiddenKeys:(BOOL)animated
{
    NSMutableSet *hidden_sets = [[NSMutableSet alloc] init];
    
    BOOL proxy_enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"sip_enable_advanced"];
    
    if(!proxy_enabled)
        [hidden_sets unionSet:[[NSMutableSet alloc] initWithObjects:@"sip_proxy",@"sip_enable_proxy",@"sip_auth_name", nil]];
    
    BOOL ice_enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"network_enable_ice"];
    
    if(!ice_enabled)
        [hidden_sets unionSet:[[NSMutableSet alloc] initWithObjects:@"ice_turn_username", @"ice_turn_password",@"ice_turn_server",nil]];
    
    [self.appSettingsViewController setHiddenKeys:hidden_sets animated:animated];
}

#pragma mark - View Lifecycle
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.currentPopoverController) {
        [self dismissCurrentPopover];
    }
}

- (void) dismissCurrentPopover {
    [self.currentPopoverController dismissPopoverAnimated:YES];
    self.currentPopoverController = nil;
}

- (void)showSettingsPopover:(id)sender {
    if(self.currentPopoverController) {
        [self dismissCurrentPopover];
        return;
    }
    
    self.appSettingsViewController.showDoneButton = NO;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navController];
    popover.delegate = self;
    [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    self.currentPopoverController = popover;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
   
    [self setupHiddenKeys:NO];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSettingsPopover:)];
    }
}

#pragma mark kIASKAppSettingChanged notification
- (void)settingDidChange:(NSNotification*)notification {
    [self setupHiddenKeys:YES];
    settting_changed_ = YES;
}

#pragma mark -
#pragma mark IASKAppSettingsViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // your code here to reconfigure the app for changed settings
}

// optional delegate method for handling mail sending result
- (void)settingsViewController:(id<IASKViewController>)settingsViewController mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    if ( error != nil ) {
        // handle error here
    }
    
    if ( result == MFMailComposeResultSent ) {
        // your code here to handle this result
    }
    else if ( result == MFMailComposeResultCancelled ) {
        // ...
    }
    else if ( result == MFMailComposeResultSaved ) {
        // ...
    }
    else if ( result == MFMailComposeResultFailed ) {
        // ...
    }
}

-(CGFloat)settingsViewController:(id<IASKViewController>)settingsViewController
                        tableView:(UITableView *)tableView
        heightForHeaderForSection:(NSInteger)section {
    NSString* key = [settingsViewController.settingsReader keyForSection:section];
    if ([key isEqualToString:@"IASKLogo"]) {
        return [UIImage imageNamed:@"Icon.png"].size.height + 25;
    } else if ([key isEqualToString:@"IASKCustomHeaderStyle"]) {
        return 55.f;
    }
    return 0;
}

- (UIView *)settingsViewController:(id<IASKViewController>)settingsViewController
                         tableView:(UITableView *)tableView
           viewForHeaderForSection:(NSInteger)section {
    NSString* key = [settingsViewController.settingsReader keyForSection:section];
    if ([key isEqualToString:@"IASKLogo"]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
        imageView.contentMode = UIViewContentModeCenter;
        return imageView;
    } else if ([key isEqualToString:@"IASKCustomHeaderStyle"]) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor redColor];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 1);
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:16.f];
        
        //figure out the title from settingsbundle
        label.text = [settingsViewController.settingsReader titleForSection:section];
        
        return label;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier {
    if ([specifier.key isEqualToString:@"customCell"]) {
        return 44*3;
    }
    return 0;
}

#if 0
- (UITableViewCell*)tableView:(UITableView*)theTableView cellForSpecifier:(IASKSpecifier*)specifier {
    CustomViewCell *cell = (CustomViewCell*)[theTableView dequeueReusableCellWithIdentifier:specifier.key];
    
    if (!cell) {
        cell = (CustomViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"CustomViewCell"
                                                               owner:self
                                                             options:nil] objectAtIndex:0];
    }
    cell.textView.text= [[NSUserDefaults standardUserDefaults] objectForKey:specifier.key] != nil ?
    [[NSUserDefaults standardUserDefaults] objectForKey:specifier.key] : [specifier defaultStringValue];
    cell.textView.delegate = self;
    [cell setNeedsLayout];
    return cell;
}
#endif

#pragma mark UITextViewDelegate (for CustomViewCell)
- (void)textViewDidChange:(UITextView *)textView {
    [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"customCell"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged object:@"customCell"];
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.currentPopoverController = nil;
}

#pragma mark -
- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier {
    if ([specifier.key isEqualToString:@"ButtonDemoAction1"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo Action 1 called" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else if ([specifier.key isEqualToString:@"ButtonDemoAction2"]) {
        NSString *newTitle = [[[NSUserDefaults standardUserDefaults] objectForKey:specifier.key] isEqualToString:@"Logout"] ? @"Login" : @"Logout";
        [[NSUserDefaults standardUserDefaults] setObject:newTitle forKey:specifier.key];
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    self.appSettingsViewController = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    //离开设置界面时保存设置
    //add by david.xu
    if(settting_changed_) {
        AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
        [appDelegate loadConfig];
    }
    
    settting_changed_ = NO;
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
