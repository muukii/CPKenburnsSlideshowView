//
//  CPKneBurnsSlideshowTitleView.m
//  CPKenBurnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import "CPKenBurnsSlideshowTitleView.h"
@interface CPKenBurnsSlideshowTitleView ()

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

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetHeight(self.bounds) - 60, 250, 20)];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetHeight(self.bounds) - 40, 250, 20)];
    self.subTitleLabel.textColor = [UIColor whiteColor];

    [self addSubview:self.titleLabel];
    [self addSubview:self.subTitleLabel];
}

- (void)setImageObject:(CPKenBurnsImage *)imageObject
{
    self.titleLabel.text = imageObject.title;
    self.subTitleLabel.text = imageObject.subTitle;
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
