//
//  CPKneBurnsSlideshowTitleView.h
//  CPKenBurnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPKenBurnsImage.h"

@interface CPKenBurnsSlideshowTitleView : UIView
@property (nonatomic, strong) CPKenBurnsImage *imageObject;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
- (void)configureView;
@end
