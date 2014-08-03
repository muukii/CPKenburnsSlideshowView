#import "CPKenburnsSlideshowView.h"
#import "CPKenburnsSlideshowTitleView.h"
#import "CPKenburnsInfiniteScrollView.h"
#import "CPKenburnsImage.h"
#import "CPKenburnsView.h"

typedef NS_ENUM(NSInteger, CPKenburnsSlideshowViewOrder) {
    CPKenburnsSlideshowViewOrderPrevious = 0,
    CPKenburnsSlideshowViewOrderCurrent = 1,
    CPKenburnsSlideshowViewOrderNext = 2
};

@interface CPKenburnsSlideshowView () <UIScrollViewDelegate,CPKenburnsInfiniteScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *kenburnsViews;
@property (nonatomic, strong) NSMutableArray *kenburnsTitleViews;
@property (nonatomic, strong) CPKenburnsInfiniteScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImageView *gradientView;
@property (nonatomic, strong) UIView *darkCoverView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, readwrite) BOOL isShowingCoverImage;
@property (nonatomic, assign) BOOL isCoverImageAnimating;
@end

@implementation CPKenburnsSlideshowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleViewClass = [CPKenburnsSlideshowTitleView class];
        [self configureView];
        [self configureParameter];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.titleViewClass = [CPKenburnsSlideshowTitleView class];
        [self configureView];
        [self configureParameter];
    }
    return self;
}

- (void)configureParameter
{
    self.automaticFadeDuration = 1.5f;
    self.slideshowDuration = 10.f;
    self.slideshow = YES;
}

- (void)configureView
{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    self.scrollView = [[CPKenburnsInfiniteScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds)*3, CGRectGetHeight(self.bounds));
    self.scrollView.delegate = self;
    self.scrollView.callBack = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds), 0);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled = YES;
    self.kenburnsViews = [NSMutableArray array];
    self.kenburnsTitleViews = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; ++i) {
        CPKenburnsView *kenburnsView = [[CPKenburnsView alloc] initWithFrame:self.bounds];
        kenburnsView.backgroundColor = self.backgroundColor;
        kenburnsView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.kenburnsViews insertObject:kenburnsView atIndex:0];
        [self addSubview:kenburnsView];

        CGRect rect = self.bounds;
        rect.origin.x = CGRectGetWidth(self.bounds) * i;
        CPKenburnsSlideshowTitleView *titleView = [[self.titleViewClass alloc] initWithFrame:rect];
        titleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.kenburnsTitleViews addObject:titleView];
        [self.scrollView addSubview:titleView];
    }

    self.gradientView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.gradientView.contentMode = UIViewContentModeBottom;
    self.gradientView.image = kenBurnsGradationImage(CGSizeMake(CGRectGetWidth(self.bounds), 110));
    self.gradientView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    self.darkCoverView = [[UIView alloc] initWithFrame:self.bounds];
    self.darkCoverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.darkCoverView.alpha = 0;
    self.darkCoverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.darkCoverView];
    [self addSubview:self.gradientView];
    [self addSubview:self.scrollView];
    
    self.coverImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.userInteractionEnabled = YES;
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.coverImageView.backgroundColor = [UIColor blackColor];
    self.coverImageView.hidden = YES;
    self.coverImageView.alpha = 0;
    self.coverImageView.image = self.coverImage;
    [self addSubview:self.coverImageView];

    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    self.longPressGesture.minimumPressDuration = .225f;
    self.longPressGesture.delegate = self;
    [self addGestureRecognizer:self.longPressGesture];
}

- (void)handleLongPressGesture:(id)sender
{
    if (self.longTapGestureEnable) {
        UILongPressGestureRecognizer *gesture = sender;
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
                [self stopTimer];
                [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0) animated:YES];
                [[self currentKenburnsView] showWholeImage];
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
                [self restartTimer];
                [[self currentKenburnsView] zoomAndRestartAnimation];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Timer
- (void)configureTimer
{
    if (self.slideshow) {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.slideshowDuration target:self selector:@selector(scrollToNextPhoto) userInfo:nil repeats:YES];
    }
}
- (void)stopTimer
{
    [self.timer invalidate];
}

- (void)restartTimer
{
    [self configureTimer];
}

#pragma mark

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    [self.kenburnsViews enumerateObjectsUsingBlock:^(CPKenburnsView *view, NSUInteger idx, BOOL *stop) {
        view.backgroundColor = backgroundColor;
    }];
}

- (void)setCoverImage:(UIImage *)coverImage
{
    _coverImage = coverImage;
    self.coverImageView.image = coverImage;
}

- (void)setSlideshowDuration:(CGFloat)slideshowDuration
{
    _slideshowDuration = slideshowDuration;
    [self configureTimer];
}

- (void)setTitleViewClass:(Class)titleViewClass
{
    _titleViewClass = titleViewClass;
    [self configureView];
}

- (void)setAutomaticFadeDuration:(CGFloat)automaticFadeDuration
{
    _automaticFadeDuration = automaticFadeDuration;
    self.scrollView.fadeDuration = automaticFadeDuration;
}

- (void)setSlideshow:(BOOL)slideshow
{
    _slideshow = slideshow;
    if (slideshow) {
        [self configureTimer];
    } else {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)setImages:(NSMutableArray *)images
{
    if (images.count == 0) {
        self.scrollView.scrollEnabled = NO;
        return;
    }
    
    _images = images;
    self.currentIndex = 0;
    [self updateImages:self.currentIndex];
    [self configureTimer];
}

- (void)updateImages:(NSInteger)index
{
    [self asynchronousSetImageView:[self currentKenburnsView] imageObject:[self imageObjectWithItem:index]];
    [self asynchronousSetImageView:[self previousKenburnsView] imageObject:[self imageObjectWithItem:(index - 1)]];
    [self asynchronousSetImageView:[self nextKenburnsView] imageObject:[self imageObjectWithItem:(index + 1)]];

    if ([self.delegate respondsToSelector:@selector(slideshowView:willShowKenburnsView:)]) {
        [self.delegate slideshowView:self willShowKenburnsView:[self currentKenburnsView]];
        [self.delegate slideshowView:self willShowKenburnsView:[self previousKenburnsView]];
        [self.delegate slideshowView:self willShowKenburnsView:[self nextKenburnsView]];
    }

    [[self currentTitleView] setImageObject:[self imageObjectWithItem:index]];
    [[self previousTitleView] setImageObject:[self imageObjectWithItem:(index - 1)]];
    [[self nextTitleView] setImageObject:[self imageObjectWithItem:(index + 1)]];

    [self insertSubview:[self nextKenburnsView] atIndex:0];
    [self insertSubview:[self currentKenburnsView] atIndex:2];
    [self insertSubview:[self previousKenburnsView] atIndex:1];
}

- (NSInteger)validateItem:(NSInteger)item
{
    if (item < 0) {
        NSInteger _item = (self.images.count) - (int)fabs(item) % self.images.count;
        return _item == self.images.count ? 0 : _item;
    } else if (self.images.count <= item) {
        NSInteger _item = (item % (self.images.count));
        return _item;
    } else {
        return item;
    }
}

- (void)stopAnimation
{
    [self currentKenburnsView].state = CPKenburnsImageViewStatePausing;
    [self nextKenburnsView].state = CPKenburnsImageViewStatePausing;
    [self previousKenburnsView].state = CPKenburnsImageViewStatePausing;
}

- (void)restartAnimation
{
    [self currentKenburnsView].state = CPKenburnsImageViewStateAnimating;
    [self nextKenburnsView].state = CPKenburnsImageViewStateAnimating;
    [self previousKenburnsView].state = CPKenburnsImageViewStateAnimating;
}

- (void)restartAllKenburnsMotion
{
    [self.kenburnsViews enumerateObjectsUsingBlock:^(CPKenburnsView *view, NSUInteger idx, BOOL *stop) {
        [view restartMotion];
    }];
}

- (void)showCoverImage:(BOOL)show
{
    if (self.isCoverImageAnimating) {
        return;
    }
    
    if (show) {
        self.isCoverImageAnimating = YES;
        self.coverImageView.hidden = NO;
        if (!self.coverImage) {
            self.coverImageView.image = self.currentKenburnsView.imageView.image;
        }
        [UIView animateWithDuration:self.automaticFadeDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.coverImageView.alpha = 1.f;
        } completion:^(BOOL finished) {
            if (finished) {
                self.isShowingCoverImage = YES;
                [self stopAnimation];
                [self setSlideshow:NO];
                self.isCoverImageAnimating = NO;
            }
        }];
    }else {
        self.isCoverImageAnimating = YES;
        [self restartAnimation];
        [self setSlideshow:YES];
        [UIView animateWithDuration:self.automaticFadeDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.coverImageView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                self.isCoverImageAnimating = NO;
                self.isShowingCoverImage = NO;
                self.coverImageView.hidden = YES;
            }
        }];
    }
}

- (NSInteger)currentIndex
{
    return [self validateItem:_currentIndex];
}

- (void)addImage:(CPKenburnsImage *)image
{
    [self.images addObject:image];
}

- (void)jumpToIndex:(NSInteger)index
{
    [self updateImages:index];
}

- (void)jumpToIndex:(NSInteger)index animated:(BOOL)animated
{
#warning TODO
    [self updateImages:index];
}

- (CPKenburnsImage *)imageObjectWithItem:(NSInteger)item
{
    if( self.images == nil || self.images.count <= 0 ){
        return nil;
    }
    CPKenburnsImage *image = self.images[[self validateItem:item]];
    return image;
}

- (void)asynchronousSetImageView:(CPKenburnsView *)imageView imageObject:(CPKenburnsImage *)imageObject
{
    imageView.image = nil;
    if (imageObject.image) {
        imageView.image = imageObject.image;
        //pause animation
        [self previousKenburnsView].state = CPKenburnsImageViewStatePausing;
        [self nextKenburnsView].state = CPKenburnsImageViewStatePausing;
    } else {
        if ([self.delegate respondsToSelector:@selector(slideshowView:downloadImageUrl:completionBlock:)]) {
            [self.delegate slideshowView:self downloadImageUrl:imageObject.imageUrl completionBlock:^(UIImage *image) {
                imageView.image = image;
                //pause animation
                [self previousKenburnsView].state = CPKenburnsImageViewStatePausing;
                [self nextKenburnsView].state = CPKenburnsImageViewStatePausing;
            }];
        }
        if ([self.delegate respondsToSelector:@selector(slideshowView:downloadImageUrl:kenburnsView:)]) {
            [self.delegate slideshowView:self downloadImageUrl:imageObject.imageUrl kenburnsView:imageView];
        }
    }
}

- (CPKenburnsView *)currentKenburnsView
{
    return self.kenburnsViews[CPKenburnsSlideshowViewOrderCurrent];
}

- (void)setCurrentKenburnsView:(CPKenburnsView *)kenBurnsView
{
    [self.kenburnsViews replaceObjectAtIndex:CPKenburnsSlideshowViewOrderCurrent withObject:kenBurnsView];
}

- (CPKenburnsView *)nextKenburnsView
{
    return self.kenburnsViews[CPKenburnsSlideshowViewOrderNext];
}

- (void)setNextKenburnsView:(CPKenburnsView *)kenBurnsView
{
    [self.kenburnsViews replaceObjectAtIndex:CPKenburnsSlideshowViewOrderNext withObject:kenBurnsView];
}

- (CPKenburnsView *)previousKenburnsView
{
    return self.kenburnsViews[CPKenburnsSlideshowViewOrderPrevious];
}

- (void)setPreviousKenburnsView:(CPKenburnsView *)kenBurnsView
{
    [self.kenburnsViews replaceObjectAtIndex:CPKenburnsSlideshowViewOrderPrevious withObject:kenBurnsView];
}

- (CPKenburnsSlideshowTitleView *)currentTitleView
{
    return self.kenburnsTitleViews[CPKenburnsSlideshowViewOrderCurrent];
}

- (CPKenburnsSlideshowTitleView *)previousTitleView
{
    return self.kenburnsTitleViews[CPKenburnsSlideshowViewOrderPrevious];
}

- (CPKenburnsSlideshowTitleView *)nextTitleView
{
    return self.kenburnsTitleViews[CPKenburnsSlideshowViewOrderNext];
}

- (void)scrollToNextPhoto
{
    [[self previousKenburnsView] setAlpha:0];
    [[self nextKenburnsView] setAlpha:1];

    CGPoint currentOffset = self.scrollView.contentOffset;
    currentOffset.x += CGRectGetWidth(self.scrollView.bounds);
    self.scrollView.fadeDuration = self.automaticFadeDuration;
    [self.scrollView setContentOffset:currentOffset slowAnimated:YES];
}

- (void)scrollToPreviousPhoto
{
    [[self previousKenburnsView] setAlpha:1];
    [[self nextKenburnsView] setAlpha:0];

    CGPoint currentOffset = self.scrollView.contentOffset;
    currentOffset.x -= CGRectGetWidth(self.scrollView.bounds);
    self.scrollView.fadeDuration = self.automaticFadeDuration;
    [self.scrollView setContentOffset:currentOffset animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self configureTimer];
    
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    const CGFloat width = CGRectGetWidth(self.bounds);

    CGFloat _alpha = cos((180 * fabsf((scrollView.contentOffset.x-width)/width)) * M_PI / 180.0)/2 + 0.5;
    CGFloat _darkCoverAlpha = sin(180*(fabsf((scrollView.contentOffset.x-width)/width)) * M_PI / 180.0) - 0.4;
    if (_alpha > 0.999) {
        _alpha = 1.f;
    }
    
    self.darkCoverView.alpha = _darkCoverAlpha;
    if (ceilf((scrollView.contentOffset.x - width)) < 0) {
            //drag right
        [[self currentKenburnsView] setAlpha:_alpha];
        [[self previousKenburnsView] setAlpha:1];
        [[self nextKenburnsView] setAlpha:0];
        
        //restart animation
        [self previousKenburnsView].state = CPKenburnsImageViewStateAnimating;
    } else {
        //drag left
        [[self currentKenburnsView] setAlpha:_alpha];
        [[self previousKenburnsView] setAlpha:0];
        [[self nextKenburnsView] setAlpha:1];
        
        //restart animation
        [self nextKenburnsView].state = CPKenburnsImageViewStateAnimating;
    }
    
    @try {
        if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [self.delegate scrollViewDidScroll:scrollView];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
   
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}


#pragma mark - CPKenburnsInfiniteScrollViewDelegate

- (void)infiniteScrollView:(CPKenburnsInfiniteScrollView *)infiniteScrollView didShowNextItem:(NSInteger)item currentItem:(NSInteger)currentItem
{
//    NSLog(@"next %ld current %ld",item,currentItem);
    self.currentIndex = currentItem;

    CPKenburnsView *currentView = [self currentKenburnsView];
    CPKenburnsView *nextView = [self nextKenburnsView];
    CPKenburnsView *previousView = [self previousKenburnsView];

    [self setPreviousKenburnsView:currentView];
    [self setCurrentKenburnsView:nextView];
    [self setNextKenburnsView:previousView];

    if ([self.delegate respondsToSelector:@selector(slideshowView:willShowKenburnsView:)]) {
        [self.delegate slideshowView:self willShowKenburnsView:[self nextKenburnsView]];
    }
    [self asynchronousSetImageView:[self nextKenburnsView] imageObject:[self imageObjectWithItem:item]];

    [[self currentTitleView] prepareForReuse];
    [[self previousTitleView] prepareForReuse];
    [[self nextTitleView] prepareForReuse];

    [[self currentTitleView] setImageObject:[self imageObjectWithItem:currentItem]];
    [[self previousTitleView] setImageObject:[self imageObjectWithItem:(currentItem - 1)]];
    [[self nextTitleView] setImageObject:[self imageObjectWithItem:(item)]];

    [[self previousKenburnsView] setAlpha:0];
    [[self currentKenburnsView] setAlpha:1];
    [[self nextKenburnsView] setAlpha:0];

    [self insertSubview:[self nextKenburnsView] atIndex:0];
    [self insertSubview:[self currentKenburnsView] atIndex:2];
    [self insertSubview:[self previousKenburnsView] atIndex:1];

    [self.kenburnsViews enumerateObjectsUsingBlock:^(CPKenburnsView *view, NSUInteger idx, BOOL *stop) {
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }];
    
    //pause animation
    [self previousKenburnsView].state = CPKenburnsImageViewStatePausing;
    [self nextKenburnsView].state = CPKenburnsImageViewStatePausing;
}

- (void)infiniteScrollView:(CPKenburnsInfiniteScrollView *)infiniteScrollView didShowPreviousItem:(NSInteger)item currentItem:(NSInteger)currentItem
{
//    NSLog(@"previous %ld current %ld",item,currentItem);
    self.currentIndex = currentItem;

    CPKenburnsView *currentView = [self currentKenburnsView];
    CPKenburnsView *nextView = [self nextKenburnsView];
    CPKenburnsView *previousView = [self previousKenburnsView];

    [self setPreviousKenburnsView:nextView];
    [self setNextKenburnsView:currentView];
    [self setCurrentKenburnsView:previousView];

    if ([self.delegate respondsToSelector:@selector(slideshowView:willShowKenburnsView:)]) {
        [self.delegate slideshowView:self willShowKenburnsView:[self previousKenburnsView]];
    }

    [self asynchronousSetImageView:[self previousKenburnsView] imageObject:[self imageObjectWithItem:item]];

    [[self currentTitleView] prepareForReuse];
    [[self previousTitleView] prepareForReuse];
    [[self nextTitleView] prepareForReuse];

    [[self currentTitleView] setImageObject:[self imageObjectWithItem:currentItem]];
    [[self previousTitleView] setImageObject:[self imageObjectWithItem:item]];
    [[self nextTitleView] setImageObject:[self imageObjectWithItem:(currentItem + 1)]];

    [[self previousKenburnsView] setAlpha:0];
    [[self currentKenburnsView] setAlpha:1];
    [[self nextKenburnsView] setAlpha:0];

    [self insertSubview:[self nextKenburnsView] atIndex:0];
    [self insertSubview:[self currentKenburnsView] atIndex:2];
    [self insertSubview:[self previousKenburnsView] atIndex:1];
    
    [self.kenburnsViews enumerateObjectsUsingBlock:^(CPKenburnsView *view, NSUInteger idx, BOOL *stop) {
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }];
    
    //pause animation
    [self previousKenburnsView].state = CPKenburnsImageViewStatePausing;
    [self nextKenburnsView].state = CPKenburnsImageViewStatePausing;
}

UIImage *
kenBurnsGradationImage(CGSize size)
{

    UIGraphicsBeginImageContextWithOptions(size, NO, 2);

        //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

        //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.3];
    UIColor* color2 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0];

        //// Gradient Declarations
    NSArray* gradient2Colors = [NSArray arrayWithObjects:
                                (id)color.CGColor,
                                (id)color2.CGColor, nil];
    CGFloat gradient2Locations[] = {0.05, 0.9};
    CGGradientRef gradient2 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradient2Colors, gradient2Locations);

        //// Frames
    CGRect frame = CGRectMake(0, 0,size.width,size.height);


        //// GradientOverlay2 Drawing
    UIBezierPath* gradientOverlay2Path = [UIBezierPath bezierPath];
    [gradientOverlay2Path moveToPoint: CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 1)];
    [gradientOverlay2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 320, CGRectGetMinY(frame))];
    [gradientOverlay2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 320, CGRectGetMinY(frame) + 130)];
    [gradientOverlay2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 131)];
    [gradientOverlay2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 1)];
    [gradientOverlay2Path closePath];
    CGContextSaveGState(context);
    [gradientOverlay2Path addClip];
    CGRect gradientOverlay2Bounds = CGPathGetPathBoundingBox(gradientOverlay2Path.CGPath);
    CGContextDrawLinearGradient(context, gradient2,
                                CGPointMake(CGRectGetMidX(gradientOverlay2Bounds) + 0 * CGRectGetWidth(gradientOverlay2Bounds) / 320, CGRectGetMidY(gradientOverlay2Bounds) + 65.5 * CGRectGetHeight(gradientOverlay2Bounds) / 131),
                                CGPointMake(CGRectGetMidX(gradientOverlay2Bounds) + 0 * CGRectGetWidth(gradientOverlay2Bounds) / 320, CGRectGetMidY(gradientOverlay2Bounds) + -65.5 * CGRectGetHeight(gradientOverlay2Bounds) / 131),
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

        //// Cleanup
    CGGradientRelease(gradient2);
    CGColorSpaceRelease(colorSpace);
    


    UIGraphicsEndImageContext();
    
    return image;
    
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [self currentKenburnsView].imageView.hidden;
}

- (void)dealloc
{
    self.scrollView = nil;
    self.delegate = nil;
    [self.timer invalidate];
}

@end
