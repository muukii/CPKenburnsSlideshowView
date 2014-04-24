//
//  CPKenBurnsSlideshowView.h
//  CPKenBurnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPKenburnsView.h"
@class CPKenBurnsImage;

typedef void(^DownloadCompletionBlock)(UIImage *image);

@protocol CPKenBurnsSlideshowViewDeleagte;
@interface CPKenBurnsSlideshowView : UIView
- (id)initWithFrame:(CGRect)frame;
@property (nonatomic, assign) id <CPKenBurnsSlideshowViewDeleagte> delegate;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) BOOL slideshow; //Auto paging
@property (nonatomic, assign) CGFloat slideshowDuration; // default 10.f
@property (nonatomic, assign) CGFloat automaticFadeDuration; // default 1.5f
@property (nonatomic, assign) Class titleViewClass;

@end

@protocol CPKenBurnsSlideshowViewDeleagte <NSObject>
@optional
- (void)slideshowView:(CPKenBurnsSlideshowView *)slideshowView downloadImageUrl:(NSURL *)imageUrl completionBlock:(DownloadCompletionBlock)completionBlock;
- (void)slideshowView:(CPKenBurnsSlideshowView *)slideshowView willShowKenBurnsView:(CPKenburnsView *)kenBurnsView;
@end