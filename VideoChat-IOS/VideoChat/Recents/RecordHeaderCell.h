//
//  RecordHeaderCell.h
//  iVoice
//
//  Created by ZhangChuntao on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordHeaderCell : UIView

@property (retain, nonatomic) IBOutlet UILabel* stateLabel;
@property (retain, nonatomic) IBOutlet UILabel* timeLabel;

+ (RecordHeaderCell*)getNewCell;

@end
