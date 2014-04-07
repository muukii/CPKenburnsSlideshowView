//
//  CPKenBurnsImage.h
//  CPKenBurnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPKenBurnsImage : NSObject
@property (nonatomic,assign) UIImage *image;
@property (nonatomic,assign) CGFloat latitude;
@property (nonatomic,assign) CGFloat longitude;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *subTitle;
@property (nonatomic,strong) NSString *locationDescription;
@property (nonatomic,strong) NSDate *date;
@end
