//
//  AppDelegate.h
//  VideDemo
//
//  Created by longshine on 2020/2/24.
//  Copyright © 2020 com.longshine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <reSipWebRTCSDK/SipEngineManager.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic,retain) Account* currentCount;
@property UIBackgroundTaskIdentifier backgroundTaskId;
@property(nonatomic) BOOL background;
@property (nonatomic,retain) NSTimer* timer;

@end

