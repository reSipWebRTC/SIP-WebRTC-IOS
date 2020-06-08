//
//  AppDelegate.m
//  VideDemo
//
//  Created by longshine on 2020/2/24.
//  Copyright © 2020 com.longshine. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _background = TRUE;
    self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        //RCLogError("[RCDevice unlisten], Forcing background stop");
        NSLog(@"backgroundTimeRemaining:%f",application.backgroundTimeRemaining);
        [self handleSignlingBackgroundTimeout];
    }];
    
    //_timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(stopSipEngineCore:) userInfo:nil repeats:YES];

      //异步
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //### background task starts
            NSLog(@"========Running in the background\n");
            [NSThread sleepForTimeInterval:120]; //wait for 120 sec
            NSLog(@"=============Background time Remaining: %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
            //[self handleSignlingBackgroundTimeout];
        NSLog(@"=======appWillEnterBackgroundNotification=====");
        if(self->_background) {
          if(![[SipEngineManager instance] InCalling]) {
               if(self->_currentCount)
                 {
                     [self->_currentCount unregister];
                     self->_currentCount = nil;
                 }
                 
               [[SipEngineManager instance] stopSipEngineCore];
          }
        }
        });
    
      /*if(![[SipEngineManager instance] InCalling]) {
            if(self->_currentCount)
            {
                [self->_currentCount unregister];
                self->_currentCount = nil;
            }
                    
        [[SipEngineManager instance] stopSipEngineCore];
      }*/
    
      [[NSNotificationCenter defaultCenter] postNotificationName:@"enterBackground" object:nil];
}

-(void)stopSipEngineCore:(NSTimer *)timer
{
    //[_timer invalidate];
    //[self handleSignlingBackgroundTimeout];
      //[self endBack]; // 任务执行完毕，主动调用该方法结束任务
}

- (void)handleSignlingBackgroundTimeout
{
    NSLog(@"===============handleSignlingBackgroundTimeout======");
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    _background = FALSE;
    [[SipEngineManager instance] startSipEngineCore];
    
    if(!self->_currentCount) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             AccountConfig *accountConfig = [[AccountConfig alloc] init];
             accountConfig.username = @"1121";
             accountConfig.password = @"4321";
             accountConfig.server = @"222.211.83.186:15380";
             accountConfig.proxy = @"222.211.83.186:15380";
             accountConfig.trans_type = kTCP;
             accountConfig.display_name = @"david.xu";
             self->_currentCount = [[SipEngineManager instance] registerSipAccount:accountConfig];
       });
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"becomeActive" object:nil];

}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
