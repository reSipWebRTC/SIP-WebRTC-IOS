//
//  UserContactUtil.m
//  iVoice
//
//  Created by ZhangChuntao on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserContactUtil.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

static ContactManager cc_manager;
static ContactManagerUtil* manager = nil;

@implementation ContactManagerUtil

+ (ContactManagerUtil*)instance
{
    @synchronized(manager)
    {
        if (!manager) {
            manager = [[ContactManagerUtil alloc] init];
        }
        return manager;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        peopleCount = 0;
    }
    return self;
}


- (NSInteger)peopleCount
{
    return peopleCount;
}

- (ContactManager&)getContactManager
{
    return cc_manager;
}

- (NSString*)doPhoneSearch:(NSString*)phonenum
{
    std::string user = cc_manager.do_phone_search(*(new std::string([phonenum cStringUsingEncoding:[NSString defaultCStringEncoding]])));
    NSString* username = [NSString stringWithCString:user.c_str() encoding:NSUTF8StringEncoding];
    if (![username isEqualToString:@"Unknown"]) {
        return username;
    }
    NSString* convertPhone = [NSString stringWithString:phonenum];
    /*
     if ([convertPhone rangeOfString:@"+"].location == NSNotFound) {
        convertPhone = [NSString stringWithFormat:@"%@%@", SharedAppDelegate.phonePrefix, phonenum];
    }*/
    user = cc_manager.do_phone_search(*(new std::string([convertPhone cStringUsingEncoding:[NSString defaultCStringEncoding]])));
    username = [NSString stringWithCString:user.c_str() encoding:NSUTF8StringEncoding];
    if ([username isEqualToString:@"Unknown"]) {
        return phonenum;
    }
    return username;
}

- (NSString*)doPinyinSearch:(NSString*)phonenum
{
    std::string user = cc_manager.do_pinyin_search(*(new std::string([phonenum cStringUsingEncoding:[NSString defaultCStringEncoding]])));
    std::transform(user.begin(), user.end(), user.begin(), ::toupper);
    NSString* username = [NSString stringWithCString:user.c_str() encoding:NSUTF8StringEncoding];
    if ([username isEqualToString:@"UNKNOWN"]) {
        return nil;
    }
    return username;
}


-(void)readAllPeoples
{
    peopleCount = 0;
    {
        ABAddressBookRef tmpAddressBook = nil;
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
        {
            tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            
            //等待同意后向下执行
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool granted, CFErrorRef error)
                                                     {
                                                         dispatch_semaphore_signal(sema);
                                                     });
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            //dispatch_release(sema);
        }
        else
        {
            tmpAddressBook = ABAddressBookCreate();
        }
        
        if(!tmpAddressBook)
            return;
        
        cc_manager.remove_all_contacts();
        
        results = ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
        for(int i = 0; i < CFArrayGetCount(results); i++)
        {
            ABRecordRef person = CFArrayGetValueAtIndex(results, i);
            peopleCount += [self addPerson:person];
        }
        
        //释放内存
        CFRelease(results);
        CFRelease(tmpAddressBook);
    }
}

-(int)addPerson:(ABRecordRef)person{
    int num_nb=0;
    NSString *tmpContactName;
    NSString* tmpFirstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    NSString* tmpLastName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if(tmpFirstName!=NULL && [tmpFirstName length] >0
       && tmpLastName!=NULL && [tmpLastName length] >0){
        tmpContactName = [[NSString alloc] initWithFormat:@"%@ %@",tmpLastName,tmpFirstName] ;
    }else{
        if(tmpLastName!=NULL && [tmpLastName length] >0)
            tmpContactName = [[NSString alloc] initWithFormat:@"%@",tmpLastName];
        
        else if (tmpFirstName!=NULL && [tmpFirstName length] >0)
            tmpContactName = [[NSString alloc] initWithFormat:@"%@",tmpFirstName] ;
        else {
            tmpContactName = @"Unkonwn";
        }
    }
    
    NSString *py_name = @"";
    for (int i = 0; i < [tmpContactName length]; i++)
    {
        if([py_name length] < 1) {
            char firstChar = pinyinFirstLetter([tmpContactName characterAtIndex:i]);
            if ((firstChar >= 'a' && firstChar <= 'z') || (firstChar >= 'A' && firstChar <= 'Z')) {
                py_name = [NSString stringWithFormat:@"%c",firstChar];
            }else {
                py_name = [NSString stringWithFormat:@"#%c",firstChar];
            }
        }
        else {
            py_name = [NSString stringWithFormat:@"%@%c",py_name,pinyinFirstLetter([tmpContactName characterAtIndex:i])];
        }
    }
    
    py_name = [py_name uppercaseString];
    
    ABMultiValueRef tmpPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    Contact cc;
    cc.set_name([tmpContactName cStringUsingEncoding:NSUTF8StringEncoding]);
    cc.set_address_id(ABRecordGetRecordID(person));
    for(NSInteger j = 0; j < ABMultiValueGetCount(tmpPhones); j++)
    {
        NSString* phonetype = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(tmpPhones, j);
        phonetype = [phonetype stringByReplacingOccurrencesOfString:@"_$!<" withString:@""];
        phonetype = [phonetype stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
        phonetype = NSLocalizedString(phonetype, @"");
        NSString* tmpPhoneIndex = (__bridge NSString*)ABMultiValueCopyValueAtIndex(tmpPhones, j);
        NSString* new_phone = [tmpPhoneIndex stringByReplacingOccurrencesOfString:@" " withString:@""];
        new_phone = [new_phone stringByReplacingOccurrencesOfString:@" " withString:@""];
        new_phone = [new_phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
#if 0
        NSString* phone_prefix = [NSString stringWithString:new_phone];
        if ([phone_prefix hasPrefix:@"00"] && phone_prefix.length > 2) {
            phone_prefix = [NSString stringWithFormat:@"+%@", [phone_prefix substringFromIndex:2]];
        }
        
        else if ([phone_prefix hasPrefix:@"0"] && phone_prefix.length > 2) {
            phone_prefix = [NSString stringWithFormat:@"%@%@", SharedAppDelegate.phonePrefix, [phone_prefix substringFromIndex:1]];
        }
        if ([phone_prefix rangeOfString:@"+"].location == NSNotFound ||
            [phone_prefix rangeOfString:@"+"].location != 0) {
            phone_prefix = [NSString stringWithFormat:@"%@%@", SharedAppDelegate.phonePrefix, new_phone];
        }
        cc.set_phones([phone_prefix cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
        if(j ==0) cc.set_phone([new_phone cStringUsingEncoding:NSUTF8StringEncoding]);
        cc.set_phones([new_phone cStringUsingEncoding:NSUTF8StringEncoding]);
        cc.set_pinyin([py_name cStringUsingEncoding:NSUTF8StringEncoding]);
        cc.set_types([phonetype cStringUsingEncoding:NSUTF8StringEncoding]);
        cc.set_origin_phones([new_phone cStringUsingEncoding:NSUTF8StringEncoding]);
        phone_info_t phone_info;
        phone_info.phonenum = [new_phone cStringUsingEncoding:NSUTF8StringEncoding];
        phone_info.type = [phonetype cStringUsingEncoding:NSUTF8StringEncoding];
        cc.set_phone_info(phone_info);
        
        num_nb++;
    }
    cc_manager.add_contact(cc);
    CFRelease(tmpPhones);
    return num_nb;
}


@end
