//
//  ContactsCell.m
//  iVoice
//
//  Created by ZhangChuntao on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactsCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UserContactUtil.h"
#import "CommonTypes.h"
#import <reSipWebRTCSDK/SipEngineManager.h>

@implementation ContactsCell

@synthesize thumbnailImageView;
@synthesize nameLabel;
@synthesize number;

- (void)initSubviews
{
    self.thumbnailImageView.image = [UIImage imageNamed:@"call-contacts.png"];
    self.thumbnailImageView.backgroundColor = contactHeadBlueColor;
    self.thumbnailImageView.layer.cornerRadius = 20;
    self.thumbnailImageView.layer.masksToBounds = YES;
}
- (void)setUserInfo:(void*)data
{
    Contact* contact = (Contact*)data;
    self.nameLabel.text = [NSString stringWithCString:contact->name().c_str() encoding:NSUTF8StringEncoding];
    contact->set_phone(contact->phones().at(0));
    self.number = [NSString stringWithCString:contact->phone().c_str() encoding:NSUTF8StringEncoding];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
