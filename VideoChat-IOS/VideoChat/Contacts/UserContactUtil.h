//
//  UserContactUtil.h
//  iVoice
//
//  Created by ZhangChuntao on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "user_contacts.h"
#include "pinyin.h"

@interface ContactManagerUtil : NSObject
{
    NSInteger peopleCount;
    CFArrayRef results;
}


+ (ContactManagerUtil*)instance;

- (ContactManager&)getContactManager;

- (NSString*)doPhoneSearch:(NSString*)phonenum;

- (NSString*)doPinyinSearch:(NSString*)phonenum;

- (void)readAllPeoples;

- (NSInteger)peopleCount;

@end
