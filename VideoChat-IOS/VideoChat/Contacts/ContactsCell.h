//
//  ContactsCell.h
//  iVoice
//
//  Created by ZhangChuntao on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsCell : UITableViewCell <UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel* nameLabel;
@property (retain, nonatomic) IBOutlet UIImageView* thumbnailImageView;
@property (nonatomic) NSString *number;

- (void)initSubviews;
- (void)setUserInfo:(void*)data;

@end
