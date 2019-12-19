//
//  ContactsCell.m
//  iVoice
//
//  Created by ZhangChuntao on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CommonTypes.h"

@implementation RecentCell

@synthesize nameLabel, timeLabel, viberLabel;
@synthesize thumbnailImageView;
@synthesize detailButton;
@synthesize recordCountLabel;

- (void)setRecordCount:(int)count
{
    if (count == 0 || count == 1) {
        self.recordCountLabel.hidden = YES;
    }
    else {
        self.recordCountLabel.hidden = NO;
        self.recordCountLabel.text = [NSString stringWithFormat:@"(%d)", count];
        CGSize size = [self.nameLabel.text sizeWithFont:self.nameLabel.font];
        self.recordCountLabel.frame = CGRectMake(self.nameLabel.frame.origin.x + size.width + 5>218?218:self.nameLabel.frame.origin.x + size.width + 5, recordCountLabel.frame.origin.y, recordCountLabel.frame.size.width, recordCountLabel.frame.size.height);
    }
}

-(void)setUserData:(void*)data
{
	ptr=data;
}

-(void*)getUserData
{
	return ptr;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.25f];
    }
    self.timeLabel.alpha = editing?0:1;
    self.detailButton.alpha = editing? 0:1;
    if (animated) {
        [UIView commitAnimations];
    }
    [super setEditing:editing animated:animated];
}

- (void)setDurationLabel:(NSString *)text;
{
    self.viberLabel.hidden = NO;
    self.viberLabel.text = text;
}

- (void)initSubviews
{
    //self.thumbnailImageView.image = [UIImage imageNamed:@"call-contacts.png"];
    self.thumbnailImageView.backgroundColor = [UIColor clearColor];
    self.thumbnailImageView.contentMode = UIViewContentModeCenter;
    //self.thumbnailImageView.layer.cornerRadius = 20;
    //self.thumbnailImageView.layer.masksToBounds = YES;
    
    CGRect bounds = self.bounds;
    float MidY = CGRectGetMidY(bounds);
    float MaxX = CGRectGetMaxX(bounds);
    self.timeLabel.center = CGPointMake(MaxX - (MaxX / 8) - (self.timeLabel.frame.size.width / 2), MidY);
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
