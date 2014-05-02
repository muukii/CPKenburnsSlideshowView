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

@interface CPKenburnsSlideshowView () <UIScrollViewDelegate,CPKenburnsInfiniteScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *kenburnsViews;
@property (nonatomic, strong) NSMutableArray *kenburnsTitleViews;
@property (nonatomic, strong) CPKenburnsInfiniteScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentItem;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImageView *gradientView;
@property (nonatomic, strong) UIView *darkCoverView;
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
    self.kenburnsViews = [NSMutableArray array];
    self.kenburnsTitleViews = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; ++i) {
        CPKenburnsView *kenburnsView = [[CPKenburnsView alloc] initWithFrame:self.bounds];
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
}

- (void)configureTimer
{
    if (self.slideshow) {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.slideshowDuration target:self selector:@selector(scrollToNextPhoto) userInfo:nil repeats:YES];
    }
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
    }
}

- (void)setImages:(NSArray *)images
{
    if (images.count == 0) {
        self.scrollView.scrollEnabled = NO;
        return;
    }
    _images = images;
    self.currentItem = 0;
    [self updateImages:self.currentItem];
    [self configureTimer];
}

- (void)updateImages:(NSInteger)item
{
    [self asynchronousSetImageView:[self currentKenBurnsView] imageObject:[self imageObjectWithItem:item]];
    [self asynchronousSetImageView:[self previousKenBurnsView] imageObject:[self imageObjectWithItem:(item - 1)]];
    [self asynchronousSetImageView:[self nextKenBurnsView] imageObject:[self imageObjectWithItem:(item + 1)]];

    if ([self.delegate respondsToSelector:@selector(slideshowView:willShowKenBurnsView:)]) {
        [self.delegate slideshowView:self willShowKenBurnsView:[self currentKenBurnsView]];
        [self.delegate slideshowView:self willShowKenBurnsView:[self previousKenBurnsView]];
        [self.delegate slideshowView:self willShowKenBurnsView:[self nextKenBurnsView]];
    }

    [[self currentTitleView] setImageObject:[self imageObjectWithItem:item]];
    [[self previousTitleView] setImageObject:[self imageObjectWithItem:(item - 1)]];
    [[self nextTitleView] setImageObject:[self imageObjectWithItem:(item + 1)]];



    [self insertSubview:[self nextKenBurnsView] atIndex:0];
    [self insertSubview:[self currentKenBurnsView] atIndex:2];
    [self insertSubview:[self previousKenBurnsView] atIndex:1];
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
    } else {
        if ([self.delegate respondsToSelector:@selector(slideshowView:downloadImageUrl:completionBlock:)]) {
            [self.delegate slideshowView:self downloadImageUrl:imageObject.imageUrl completionBlock:^(UIImage *image) {
                imageView.image = image;
            }];
        }
        if ([self.delegate respondsToSelector:@selector(slideshowView:downloadImageUrl:kenburnsView:)]) {
            [self.delegate slideshowView:self downloadImageUrl:imageObject.imageUrl kenburnsView:imageView];
        }
    }
}

- (CPKenburnsView *)currentKenBurnsView
{
    return self.kenburnsViews[CPKenburnsSlideshowViewOrderCurrent];
}

- (void)setCurrentKenBurnsView:(CPKenburnsView *)kenBurnsView
{
    [self.kenburnsViews replaceObjectAtIndex:CPKenburnsSlideshowViewOrderCurrent withObject:kenBurnsView];
}

- (CPKenburnsView *)nextKenBurnsView
{
    return self.kenburnsViews[CPKenburnsSlideshowViewOrderNext];
}

- (void)setNextKenBurnsView:(CPKenburnsView *)kenBurnsView
{
    [self.kenburnsViews replaceObjectAtIndex:CPKenburnsSlideshowViewOrderNext withObject:kenBurnsView];
}

- (CPKenburnsView *)previousKenBurnsView
{
    return self.kenburnsViews[CPKenburnsSlideshowViewOrderPrevious];
}

- (void)setPreviousKenBurnsView:(CPKenburnsView *)kenBurnsView
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
    [[self previousKenBurnsView] setAlpha:0];
    [[self nextKenBurnsView] setAlpha:1];

    CGPoint currentOffset = self.scrollView.contentOffset;
    currentOffset.x += CGRectGetWidth(self.scrollView.bounds);
    self.scrollView.fadeDuration = self.automaticFadeDuration;
    [self.scrollView setContentOffset:currentOffset animated:YES];
}

- (void)scrollToPreviousPhoto
{
    [[self previousKenBurnsView] setAlpha:1];
    [[self nextKenBurnsView] setAlpha:0];

    CGPoint currentOffset = self.scrollView.contentOffset;
    currentOffset.x -= CGRectGetWidth(self.scrollView.bounds);
    self.scrollView.fadeDuration = self.automaticFadeDuration;
    [self.scrollView setContentOffset:currentOffset animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self configureTimer];
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
        [[self currentKenBurnsView] setAlpha:_alpha];
        [[self previousKenBurnsView] setAlpha:1];
        [[self nextKenBurnsView] setAlpha:0];
    } else {
            //drag left
        [[self currentKenBurnsView] setAlpha:_alpha];
        [[self previousKenBurnsView] setAlpha:0];
        [[self nextKenBurnsView] setAlpha:1];
    }
//    NSLog(@"%f %f %f",[[self previousKenBurnsView] alpha],[[self currentKenBurnsView] alpha],[[self nextKenBurnsView] alpha]);
}

#pragma mark - CPKenburnsInfiniteScrollViewDelegate

- (void)infiniteScrollView:(CPKenburnsInfiniteScrollView *)infiniteScrollView didShowNextItem:(NSInteger)item currentItem:(NSInteger)currentItem
{
//    NSLog(@"next %ld current %ld",item,currentItem);
    self.currentItem = currentItem;

    CPKenburnsView *currentView = [self currentKenBurnsView];
    CPKenburnsView *nextView = [self nextKenBurnsView];
    CPKenburnsView *previousView = [self previousKenBurnsView];

    [self setPreviousKenBurnsView:currentView];
    [self setCurrentKenBurnsView:nextView];
    [self setNextKenBurnsView:previousView];

    if ([self.delegate respondsToSelector:@selector(slideshowView:willShowKenBurnsView:)]) {
        [self.delegate slideshowView:self willShowKenBurnsView:[self nextKenBurnsView]];
    }
    [self asynchronousSetImageView:[self nextKenBurnsView] imageObject:[self imageObjectWithItem:item]];

    [[self currentTitleView] setImageObject:[self imageObjectWithItem:currentItem]];
    [[self previousTitleView] setImageObject:[self imageObjectWithItem:(currentItem - 1)]];
    [[self nextTitleView] setImageObject:[self imageObjectWithItem:(item)]];

    [[self previousKenBurnsView] setAlpha:0];
    [[self currentKenBurnsView] setAlpha:1];
    [[self nextKenBurnsView] setAlpha:0];

    [self insertSubview:[self nextKenBurnsView] atIndex:0];
    [self insertSubview:[self currentKenBurnsView] atIndex:2];
    [self insertSubview:[self previousKenBurnsView] atIndex:1];

    [self.kenburnsViews enumerateObjectsUsingBlock:^(CPKenburnsView *view, NSUInteger idx, BOOL *stop) {
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }];

}

- (void)infiniteScrollView:(CPKenburnsInfiniteScrollView *)infiniteScrollView didShowPreviousItem:(NSInteger)item currentItem:(NSInteger)currentItem
{
//    NSLog(@"previous %ld current %ld",item,currentItem);
    self.currentItem = currentItem;

    CPKenburnsView *currentView = [self currentKenBurnsView];
    CPKenburnsView *nextView = [self nextKenBurnsView];
    CPKenburnsView *previousView = [self previousKenBurnsView];

    [self setPreviousKenBurnsView:nextView];
    [self setNextKenBurnsView:currentView];
    [self setCurrentKenBurnsView:previousView];

    if ([self.delegate respondsToSelector:@selector(slideshowView:willShowKenBurnsView:)]) {
        [self.delegate slideshowView:self willShowKenBurnsView:[self previousKenBurnsView]];
    }

    [self asynchronousSetImageView:[self previousKenBurnsView] imageObject:[self imageObjectWithItem:item]];

    [[self currentTitleView] setImageObject:[self imageObjectWithItem:currentItem]];
    [[self previousTitleView] setImageObject:[self imageObjectWithItem:item]];
    [[self nextTitleView] setImageObject:[self imageObjectWithItem:(currentItem + 1)]];

    [[self previousKenBurnsView] setAlpha:0];
    [[self currentKenBurnsView] setAlpha:1];
    [[self nextKenBurnsView] setAlpha:0];

    [self insertSubview:[self nextKenBurnsView] atIndex:0];
    [self insertSubview:[self currentKenBurnsView] atIndex:2];
    [self insertSubview:[self previousKenBurnsView] atIndex:1];
    
    [self.kenburnsViews enumerateObjectsUsingBlock:^(CPKenburnsView *view, NSUInteger idx, BOOL *stop) {
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }];
}

UIImage *
kenBurnsGradationImage(CGSize size)
{

    UIGraphicsBeginImageContextWithOptions(size, NO, 2);

        //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

        //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.9];
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


@end
