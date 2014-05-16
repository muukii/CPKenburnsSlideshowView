//
//  CPInfiniteScrollView
//  CPKenburnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol CPKenburnsInfiniteScrollViewDelegate;
@interface CPKenburnsInfiniteScrollView : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger currentItem;
@property (nonatomic, assign) id <CPKenburnsInfiniteScrollViewDelegate> callBack;
@property (nonatomic, assign) CGFloat fadeDuration;
- (void)setContentOffset:(CGPoint)contentOffset slowAnimated:(BOOL)animated;
@end


@protocol CPKenburnsInfiniteScrollViewDelegate <NSObject>
@optional
- (void)infiniteScrollView:(CPKenburnsInfiniteScrollView *)infiniteScrollView didShowNextItem:(NSInteger)item currentItem:(NSInteger)currentItem;
- (void)infiniteScrollView:(CPKenburnsInfiniteScrollView *)infiniteScrollView didShowPreviousItem:(NSInteger)item currentItem:(NSInteger)currentItem;

@end
