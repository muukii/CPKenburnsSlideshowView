//
//  CPKenburnsImage.h
//  CPKenburnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPKenburnsImage : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *locationDescription;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UIView *customView;
@end
