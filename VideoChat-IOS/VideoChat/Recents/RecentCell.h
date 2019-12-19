//
//  ContactsCell.h
//  iVoice
//
//  Created by ZhangChuntao on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRecentCellHeight     50.0f

@interface  RecentCell: UITableViewCell
{
	void *ptr;
	BOOL have_record;    
}

@property (retain, nonatomic) IBOutlet UIImageView* thumbnailImageView;
@property (retain, nonatomic) IBOutlet UILabel* nameLabel;
@property (retain, nonatomic) IBOutlet UILabel* timeLabel;
@property (retain, nonatomic) IBOutlet UILabel* viberLabel;
@property (retain, nonatomic) IBOutlet UIButton* detailButton;
@property (retain, nonatomic) IBOutlet UILabel* recordCountLabel;

- (void)initSubviews;
- (void)setDurationLabel:(NSString *)text;
- (void)setUserData:(void*)data;
- (void*)getUserData;
- (void)setRecordCount:(int)count;

@end
