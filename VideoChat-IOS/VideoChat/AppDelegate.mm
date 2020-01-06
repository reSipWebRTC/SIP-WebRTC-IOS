
#import "AppDelegate.h"
#import "CommonTypes.h"
#import "CallingScreenViewController.h"
#import "MainTabBarViewController.h"
#import "KeyPadViewController.h"
#import "UserContactUtil.h"
#import "UserCallReportUtil.h"
#import <reSipWebRTCSDK/SipEngineManager.h>

static NSString * const kARDDefaultSTUNServerUrl =
@"stun:39.108.167.93:19302";
static NSString * const kARDDefaultTURNServerUrl =
@"turn:39.108.167.93:19302";

@implementation AppDelegate

@synthesize current_account = _current_account;
@synthesize callParams = _callParams;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#ifdef __IPHONE_8_0 
    //这里主要是针对iOS 8.0,相应的8.1,8.2等版本各程序员可自行发挥，如果苹果以后推出更高版本还不会使用这个注册方式就不得而知了……
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }  else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
#else
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
#endif
    
    [[SipEngineManager instance] Initialize];
    
    [self setDefaults:@"Root.plist"];
    [self setDefaults:@"Network.plist"];
    [self setDefaults:@"Audio.plist"];
    [self setDefaults:@"Video.plist"];
    
    [self performSelector:@selector(loadUserDatabases) withObject:nil afterDelay:0.5f];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:9];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    return YES;
}

- (void) setDefaults:(NSString *)plist {
    
    //get the plist location from the settings bundle
    NSString *settingsPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *plistPath = [settingsPath stringByAppendingPathComponent:plist];
    
    //get the preference specifiers array which contains the settings
    NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
    
    //use the shared defaults object
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //for each preference item, set its default if there is no value set
    for(NSDictionary *item in preferencesArray) {
        
        //get the item key, if there is no key then we can skip it
        NSString *key = [item objectForKey:@"Key"];
        if (key) {
            
            //check to see if the value and default value are set
            //if a default value exists and the value is not set, use the default
            id value = [defaults objectForKey:key];
            id defaultValue = [item objectForKey:@"DefaultValue"];
            if(defaultValue && !value) {
                [defaults setObject:defaultValue forKey:key];
            }
        }
    }
    
    //write the changes to disk
    [defaults synchronize];
}

- (void)loadUserDatabases
{
    [[ContactManagerUtil instance] readAllPeoples];
    [[UserCallReportUtil instance] readCdrDatabase];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
   [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceTokesn{
    NSString* token = [NSString stringWithFormat:@"%@",deviceTokesn];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];

    IVLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", token);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token forKey:@"apns_token"];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    IVLog(@"failed to regist:%@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(3_0)
{
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    /*程序暂停后，停止一切视频捕获动作*/
    if([[SipEngineManager instance] InCalling]){
        CallingScreenViewController *video_call_screen = [CallingScreenViewController instance];
        if(video_call_screen)
        {
            [video_call_screen pauseVideoCall];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*进入后台前，刷新注册*/
    [[SipEngineManager instance] enterBackgroundMode];
    
    //self.newMsgCount = 0;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;

    /*处理进入前台*/
    [[SipEngineManager instance] becomeActive];
    
    if([[SipEngineManager instance] InCalling ])
    {
        CallingScreenViewController *video_call_screen = [CallingScreenViewController instance];
        if(video_call_screen)
        {
            /*恢复摄像头捕获*/
            [video_call_screen resumeVideoCall];
        }
    }
    
    if([[SipEngineManager instance] HaveIncomingCall])
    {
        KeyPadViewController *main_view = [KeyPadViewController instance];
        //client::Call *call = [[SipEngineManager instance] getIncomingCall];
        //if(main_view && call)
        //{
         //   [main_view showCallingViewController:call->support_video() playRinging:YES];
        //}
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    /*结束呼叫*/
    if([[SipEngineManager instance] InCalling])
    {
        [[SipEngineManager instance] TerminateCall];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    IVLog(@"Received memory warning. !!!!!");
}

-(void)loadConfig
{
    NSString *username = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"sip_user_name"];
    NSString *password = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"sip_password"];
    NSString *domain = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"sip_domain"];
      NSString *display_name  = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"sip_display_name"];
    
    _callParams = [[CallParams alloc] init];
   
    NSString *video_size = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"video_size"];
    if(video_size && [video_size length] > 0)
    {
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
        }
    }else{
        [_callParams storeVideoResolutionConfig:@"640x480"];
        [_callParams storeMaxBitrateConfig:[NSNumber numberWithInt:512]];
        [_callParams storeVideoFpsConfig:[NSNumber numberWithInt:15]];
    }
    
    NSString* stun_server =  (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"ice_stun_server"];
    
    if(stun_server && [stun_server length] > 0)
    {
        [_callParams addIceServer:stun_server username:@"" credential:@""];
    }
    
    NSString* turn_server =  (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"ice_turn_server"];
    NSString* turn_username =  (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"ice_turn_username"];
    NSString* turn_password =  (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"ice_turn_password"];
    
    if((turn_server && [turn_server length]) > 0 && (turn_username && [turn_password length] > 0))
    {
        NSLog(@"============turn_server==========:%@:%@:%@", turn_server, turn_username, turn_password);
       [_callParams addIceServer:turn_server username:turn_username credential:turn_password];
    }
    
    NSString *videoCodecInfo = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"video_Codec_Info"];
     if(videoCodecInfo && [videoCodecInfo length] > 0)
     {
        RTCVideoCodecInfo *rtcVideoCodecInfo = [[RTCVideoCodecInfo alloc] initWithName:videoCodecInfo];
        [_callParams storeVideoCodecConfig:rtcVideoCodecInfo];
     }
    
    if(username && domain && password)
    {
        if(_current_account != nil)
            [_current_account unregister];
        
        AccountConfig *accountConfig = [[AccountConfig alloc] init];
        accountConfig.username = username;
        accountConfig.password = password;
        accountConfig.server = domain;
        accountConfig.proxy = domain;
        accountConfig.trans_type = kTCP;
        accountConfig.display_name = username;
        _current_account = [[SipEngineManager instance] registerSipAccount:accountConfig];
    }
}

@end
