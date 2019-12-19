
#import "MainTabBarViewController.h"
#import <reSipWebRTCSDK/SipEngineManager.h>
#import "CommonTypes.h"
#import "UIImage+ARDUtilities.h"
#import "AppDelegate.h"

static MainTabBarViewController* the_instance = nil;

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectedIndex = 2;
    self.delegate = self;
    the_instance = self;
    
    //[[SipEngineManager instance] LoadConfig];
    
    //AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
    //[appDelegate loadConfig];
    
    UITabBar *tabBar = self.tabBar;

    UITabBarItem *aTabBarItem = [tabBar.items objectAtIndex:0];
    
    aTabBarItem.selectedImage = [UIImage imageForName:@"tab-recents-selected.png" color:buttonBlueColor];
    
    UITabBarItem *bTabBarItem = [tabBar.items objectAtIndex:1];
    
    bTabBarItem.selectedImage = [UIImage imageForName:@"tab-contacts-selected.png" color:buttonBlueColor];
    
    UITabBarItem *cTabBarItem = [tabBar.items objectAtIndex:2];
    
    cTabBarItem.selectedImage = [UIImage imageForName:@"tab-keypad-selected.png" color:buttonBlueColor];
    
    UITabBarItem *dTabBarItem = [tabBar.items objectAtIndex:3];
    
    dTabBarItem.selectedImage = [UIImage imageForName:@"tab-settings-selected.png" color:buttonBlueColor];
}

+(MainTabBarViewController *)instance
{
    return the_instance;
}

-(void)setMainTabBarSelectedIndex:(NSUInteger)selectedIndex
{
    self.selectedIndex = selectedIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
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
