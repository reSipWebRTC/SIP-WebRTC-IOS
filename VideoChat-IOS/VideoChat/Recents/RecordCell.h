//
//  RecordCell.h
//  iVoice
//
//  Created by ZhangChuntao on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordCell : UIView

@property (retain, nonatomic) IBOutlet UILabel* timeLabel;
@property (retain, nonatomic) IBOutlet UILabel* stateLabel;
@property (retain, nonatomic) IBOutlet UILabel* dateLabel;
@property (retain, nonatomic) IBOutlet UIImageView *stateImageView;

+ (RecordCell*)getNewCell;

@end
