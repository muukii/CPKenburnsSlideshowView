#import "CPKenBurnsSlideshowView.h"
#import "CPKenBurnsSlideshowTitleView.h"
#import "CPKenBurnsInfiniteScrollView.h"
#import "CPKenBurnsImage.h"
#import "CPKenBurnsView.h"

typedef NS_ENUM(NSInteger, CPKenBurnsSlideshowViewOrder) {
    CPKenBurnsSlideshowViewOrderPrevious = 0,
    CPKenBurnsSlideshowViewOrderCurrent = 1,
    CPKenBurnsSlideshowViewOrderNext = 2
};

@interface CPKenBurnsSlideshowView () <UIScrollViewDelegate,CPKenBurnsInfiniteScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *kenburnsViews;
@property (nonatomic, strong) NSMutableArray *kenburnsTitleViews;
@property (nonatomic, strong) CPKenBurnsInfiniteScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentItem;
@end

@implementation CPKenBurnsSlideshowView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureView];
    }
    return self;
}

- (void)configureView
{
    self.scrollView = [[CPKenBurnsInfiniteScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds)*3, CGRectGetHeight(self.bounds));
    self.scrollView.delegate = self;
    self.scrollView.callBack = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds), 0);
    self.kenburnsViews = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; ++i) {
        CPKenBurnsView *kenburnsView = [[CPKenBurnsView alloc] initWithFrame:self.bounds];
        [kenburnsView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.kenburnsViews insertObject:kenburnsView atIndex:0];
        [self addSubview:kenburnsView];

        CGRect rect = self.bounds;
        rect.origin.x = CGRectGetWidth(self.bounds) * i;
        CPKenBurnsSlideshowTitleView *titleView = [[CPKenBurnsSlideshowTitleView alloc] initWithFrame:rect];
        titleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.scrollView addSubview:titleView];
    }
    [self addSubview:self.scrollView];
}

- (void)setImages:(NSArray *)images
{
    _images = images;
    self.currentItem = 0;
    [self updateImages:self.currentItem];
}

- (void)updateImages:(NSInteger)item
{
    [[self currentKenBurnsView] setImage:[self imageWithItem:item]];

    NSInteger previousItem = item - 1;
    [[self previousKenBurnsView] setImage:[self imageWithItem:previousItem]];
    [[self previousKenBurnsView] setAlpha:0];
    NSInteger nextItem = item + 1;
    [[self nextKenBurnsView] setImage:[self imageWithItem:nextItem]];
}

- (NSInteger)validateItem:(NSInteger)item
{
    if (item < 0) {
        NSInteger _item = self.images.count - (int)fabs(item);
        return _item;
    } else  if (self.images.count <= item) {
        NSInteger _item = (item % (self.images.count));
        return _item;
    } else {
        return item;
    }
}

- (UIImage *)imageWithItem:(NSInteger)item
{
    CPKenBurnsImage *image = self.images[[self validateItem:item]];
    return image.image;
}

- (CPKenBurnsView *)currentKenBurnsView
{
    return self.kenburnsViews[CPKenBurnsSlideshowViewOrderCurrent];
}

- (void)setCurrentKenBurnsView:(CPKenBurnsView *)kenBurnsView
{
    [self.kenburnsViews replaceObjectAtIndex:CPKenBurnsSlideshowViewOrderCurrent withObject:kenBurnsView];
}

- (CPKenBurnsView *)nextKenBurnsView
{
    return self.kenburnsViews[CPKenBurnsSlideshowViewOrderNext];
}

- (void)setNextKenBurnsView:(CPKenBurnsView *)kenBurnsView
{
    [self.kenburnsViews replaceObjectAtIndex:CPKenBurnsSlideshowViewOrderNext withObject:kenBurnsView];
}

- (CPKenBurnsView *)previousKenBurnsView
{
    return self.kenburnsViews[CPKenBurnsSlideshowViewOrderPrevious];
}

- (void)setPreviousKenBurnsView:(CPKenBurnsView *)kenBurnsView
{
    [self.kenburnsViews replaceObjectAtIndex:CPKenBurnsSlideshowViewOrderPrevious withObject:kenBurnsView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    const CGFloat width = CGRectGetWidth(self.bounds);

    CGFloat _alpha = cos((180 * fabsf((scrollView.contentOffset.x-width)/width)) * M_PI / 180.0)/2 + 0.5;
    if (_alpha > 0.999) {
        _alpha = 1.f;
    }
//    NSLog(@"%f",_alpha);
    if (ceilf((scrollView.contentOffset.x - width)) < 0) {
            //drag right
        [[self previousKenBurnsView] setAlpha:1-_alpha];
        [[self nextKenBurnsView] setAlpha:0];
    } else {
            //drag left
        [[self currentKenBurnsView] setAlpha:_alpha];
        [[self nextKenBurnsView] setAlpha:1];
    }

}

- (void)swapKenBurnsView:(CPKenBurnsSlideshowViewOrder)order1 order2:(CPKenBurnsSlideshowViewOrder)order2
{
    id _order1 = self.kenburnsViews[order1];
    id _order2 = self.kenburnsViews[order2];

    [self.kenburnsViews replaceObjectAtIndex:order1 withObject:_order2];
    [self.kenburnsViews replaceObjectAtIndex:order2 withObject:_order1];
}
#pragma mark - CPKenBurnsInfiniteScrollViewDelegate

- (void)infiniteScrollView:(CPKenBurnsInfiniteScrollView *)infiniteScrollView didShowNextItem:(NSInteger)item currentItem:(NSInteger)currentItem
{
    NSLog(@"next %ld current %ld",item,currentItem);
    CPKenBurnsView *currentView = [self currentKenBurnsView];
    CPKenBurnsView *nextView = [self nextKenBurnsView];
    CPKenBurnsView *previousView = [self previousKenBurnsView];

    [self setPreviousKenBurnsView:currentView];

    [self setCurrentKenBurnsView:nextView];

    [self setNextKenBurnsView:previousView];
    [[self nextKenBurnsView] setImage:[self imageWithItem:item]];

    [self insertSubview:[self nextKenBurnsView] atIndex:0];
    [self insertSubview:[self currentKenBurnsView] atIndex:1];
    [self insertSubview:[self previousKenBurnsView] atIndex:2];

    [[self previousKenBurnsView] setAlpha:0];
    [[self currentKenBurnsView] setAlpha:1];
    [[self nextKenBurnsView] setAlpha:1];
}

- (void)infiniteScrollView:(CPKenBurnsInfiniteScrollView *)infiniteScrollView didShowPreviousItem:(NSInteger)item currentItem:(NSInteger)currentItem
{
    NSLog(@"previous %ld current %ld",item,currentItem);
    CPKenBurnsView *currentView = [self currentKenBurnsView];
    CPKenBurnsView *nextView = [self nextKenBurnsView];
    CPKenBurnsView *previousView = [self previousKenBurnsView];

    [self setPreviousKenBurnsView:nextView];
    [self setNextKenBurnsView:currentView];
    [self setCurrentKenBurnsView:previousView];


    [[self previousKenBurnsView] setAlpha:0];
    [[self currentKenBurnsView] setAlpha:1];
    [[self nextKenBurnsView] setAlpha:0];

    [self insertSubview:[self previousKenBurnsView] atIndex:2];
    [self insertSubview:[self currentKenBurnsView] atIndex:1];
    [self insertSubview:[self nextKenBurnsView] atIndex:0];

    [[self previousKenBurnsView] setImage:[self imageWithItem:item]];

}

@end
