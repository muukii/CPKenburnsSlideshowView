//
//  CPKenburnsSlideshowView.h
//  CPKenburnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPKenburnsView.h"
@class CPKenburnsImage;

typedef void(^DownloadCompletionBlock)(UIImage *image);

@protocol CPKenburnsSlideshowViewDeleagte;
@interface CPKenburnsSlideshowView : UIView
- (id)initWithFrame:(CGRect)frame;
@property (nonatomic, assign) id <CPKenburnsSlideshowViewDeleagte> delegate;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) BOOL slideshow; //Auto paging
@property (nonatomic, assign) CGFloat slideshowDuration; // default 10.f
@property (nonatomic, assign) CGFloat automaticFadeDuration; // default 1.5f
@property (nonatomic, assign) Class titleViewClass;

@end

@protocol CPKenburnsSlideshowViewDeleagte <NSObject>
@optional
- (void)slideshowView:(CPKenburnsSlideshowView *)slideshowView downloadImageUrl:(NSURL *)imageUrl completionBlock:(DownloadCompletionBlock)completionBlock;
- (void)slideshowView:(CPKenburnsSlideshowView *)slideshowView willShowKenBurnsView:(CPKenburnsView *)kenBurnsView;
@end