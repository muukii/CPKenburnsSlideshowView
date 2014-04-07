//
//  CPInfiniteScrollView
//  CPKenBurnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import "CPKenBurnsInfiniteScrollView.h"

@interface CPKenBurnsInfiniteScrollView ()

@end

@implementation CPKenBurnsInfiniteScrollView
#pragma mark - Layout
// recenter content periodically to achieve impression of infinite scrolling

- (void)recenterIfNecessary
{
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;

    if (currentOffset.x >= contentWidth/3 * 2) {
            //next page
        if ([self.callBack respondsToSelector:@selector(infiniteScrollView:didShowNextItem:currentItem:)]) {
            [self.callBack infiniteScrollView:self didShowNextItem:++self.currentItem currentItem:self.currentItem];
        }
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
    } else if (currentOffset.x < 0.5) {
            //previous page
        if ([self.callBack respondsToSelector:@selector(infiniteScrollView:didShowPreviousItem:currentItem:)]) {
            [self.callBack infiniteScrollView:self didShowPreviousItem:--self.currentItem currentItem:self.currentItem];
        }
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self recenterIfNecessary];
}
@end
