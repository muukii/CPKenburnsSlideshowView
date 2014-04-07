//
//  CPInfiniteScrollView
//  CPKenBurnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol CPKenBurnsInfiniteScrollViewDelegate;
@interface CPKenBurnsInfiniteScrollView : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger currentItem;
@property (nonatomic, assign) id <CPKenBurnsInfiniteScrollViewDelegate> callBack;
@end
@protocol CPKenBurnsInfiniteScrollViewDelegate <NSObject>
@optional
- (void)infiniteScrollView:(CPKenBurnsInfiniteScrollView *)infiniteScrollView didShowNextItem:(NSInteger)item currentItem:(NSInteger)currentItem;
- (void)infiniteScrollView:(CPKenBurnsInfiniteScrollView *)infiniteScrollView didShowPreviousItem:(NSInteger)item currentItem:(NSInteger)currentItem;
@end
