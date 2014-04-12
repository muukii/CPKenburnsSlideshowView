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
{
    BOOL _animation;
}
#pragma mark - Layout
// recenter content periodically to achieve impression of infinite scrolling
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentItem = 0;
    }
    return self;
}
- (void)recenterIfNecessary
{
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
    CGFloat distanceFromCenter = (currentOffset.x - centerOffsetX);
//    NSLog(@"%f",distanceFromCenter);
    if (distanceFromCenter > 0) {
            //next page
        if (distanceFromCenter >= CGRectGetWidth(self.bounds)) {
            self.contentOffset = CGPointMake(ceilf(centerOffsetX), currentOffset.y);
            if ([self.callBack respondsToSelector:@selector(infiniteScrollView:didShowNextItem:currentItem:)]) {
                NSInteger nextItem = self.currentItem + 2;
                self.currentItem++;
                [self.callBack infiniteScrollView:self didShowNextItem:nextItem currentItem:self.currentItem];
            }
        }
    } else {
            //previous page
        if (distanceFromCenter <= -CGRectGetWidth(self.bounds)) {
            self.contentOffset = CGPointMake(ceilf(centerOffsetX), currentOffset.y);
            if ([self.callBack respondsToSelector:@selector(infiniteScrollView:didShowPreviousItem:currentItem:)]) {
                NSInteger previousItem = self.currentItem - 2;
                self.currentItem--;
                [self.callBack infiniteScrollView:self didShowPreviousItem:previousItem currentItem:self.currentItem];
            }
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (!_animation) {
        [self recenterIfNecessary];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    if (animated) {
        _animation = YES;
        [UIView animateWithDuration:self.fadeDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [super setContentOffset:contentOffset animated:NO];
        } completion:^(BOOL finished) {
            _animation = NO;
            [self recenterIfNecessary];
        }];
    } else {
        [super setContentOffset:contentOffset animated:NO];
    }

}
@end
