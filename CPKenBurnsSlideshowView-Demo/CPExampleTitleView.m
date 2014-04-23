//
//  CPExampleTitleView.m
//  CPKenburnsSlideshowView-Demo
//
//  Created by Muukii on 4/8/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import "CPExampleTitleView.h"

@implementation CPExampleTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)configureView
{
    [super configureView];
//    self.titleLabel.backgroundColor = [UIColor grayColor];
}

- (void)setImageObject:(CPKenburnsImage *)imageObject
{
    [super setImageObject:imageObject];
    self.titleLabel.text = imageObject.title;
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
