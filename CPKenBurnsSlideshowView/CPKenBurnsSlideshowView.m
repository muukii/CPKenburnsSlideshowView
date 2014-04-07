//
//  CPKenBurnsSlideshowView.m
//  CPKenBurnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import "CPKenBurnsSlideshowView.h"
#import "CPKenburnsView.h"

@interface CPKenBurnsSlideshowView ()
@property (nonatomic, strong) NSMutableArray *kenburnsViews;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation CPKenBurnsSlideshowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImages:(NSArray *)images
{
    _images = images;
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
