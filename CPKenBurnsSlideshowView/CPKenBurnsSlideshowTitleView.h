//
//  CPKneBurnsSlideshowTitleView.h
//  CPKenburnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPKenburnsImage.h"

@interface CPKenburnsSlideshowTitleView : UIView
@property (nonatomic, strong) CPKenburnsImage *imageObject;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) UIView *customView;
- (void)configureView;
- (void)prepareForReuse;
@end
