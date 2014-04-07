//
//  CPKneBurnsSlideshowTitleView.m
//  CPKenBurnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import "CPKenBurnsSlideshowTitleView.h"
@interface CPKenBurnsSlideshowTitleView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@end
@implementation CPKenBurnsSlideshowTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

- (void)configureView
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 30, 200, 20)];
    self.titleLabel.backgroundColor = [UIColor blueColor];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];

    [self addSubview:self.titleLabel];
    [self addSubview:self.subTitleLabel];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setSubTitle:(NSString *)subTitle
{
    _subTitle = subTitle;
    self.subTitleLabel.text = subTitle;
}

@end
