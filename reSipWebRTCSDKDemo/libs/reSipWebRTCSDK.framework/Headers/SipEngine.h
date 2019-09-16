//
//  SipEngine.h
//  AppRTCDemo
//
//  Created by shideasn on 16/6/15.
//  Copyright © 2016年 Shin Hiroe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegistrationManager.h"
#import "CallManager.h"
#import <reSIProcate/RTCSipEngine.h>

@interface SipEngine : NSObject
{
}

@property(nonatomic, readonly) RTCSipEngine* rtcSipEngine;

+(SipEngine *)instance;
/*初始化*/
- (int)Initialize;
- (void)Terminate;
- (CallManager*)getCallManager;
- (RegistrationManager*)getRegistrationManager;
    
@end

