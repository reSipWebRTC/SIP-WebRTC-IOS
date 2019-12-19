//
//  RecordCell.m
//  iVoice
//
//  Created by ZhangChuntao on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordCell.h"

@implementation RecordCell

@synthesize timeLabel;
@synthesize dateLabel;
@synthesize stateLabel;
@synthesize stateImageView;

+ (RecordCell*)getNewCell
{
    NSArray* array = [[UINib nibWithNibName:@"RecordCell" bundle:nil] instantiateWithOwner:self options:nil];
    return [array lastObject];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
