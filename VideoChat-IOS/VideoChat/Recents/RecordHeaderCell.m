//
//  RecordHeaderCell.m
//  iVoice
//
//  Created by ZhangChuntao on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordHeaderCell.h"

@implementation RecordHeaderCell

@synthesize timeLabel;
@synthesize stateLabel;

+ (RecordHeaderCell*)getNewCell
{
    NSArray* array = [[UINib nibWithNibName:@"RecordHeaderCell" bundle:nil] instantiateWithOwner:self options:nil];
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
