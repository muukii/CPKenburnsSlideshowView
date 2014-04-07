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
    [[self previousKenBurnsView] setImage:[self imageWithItem:--item]];
    [[self nextKenBurnsView] setImage:[self imageWithItem:++item]];
}

- (NSInteger)validateItem:(NSInteger)item
{
    if (item > self.images.count) {
        return item % self.images.count;
    } else if (item < 0) {
#warning とりあえず
        return self.images.count - (int)fabs(item);
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

- (CPKenBurnsView *)nextKenBurnsView
{
    return self.kenburnsViews[CPKenBurnsSlideshowViewOrderNext];
}

- (CPKenBurnsView *)previousKenBurnsView
{
    return self.kenburnsViews[CPKenBurnsSlideshowViewOrderPrevious];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    const CGFloat width = CGRectGetWidth(self.bounds);

    NSLog(@"%f",(scrollView.contentOffset.x-width)/width);
    CGFloat _alpha = (scrollView.contentOffset.x-width)/width;
    [[self currentKenBurnsView] setAlpha:cos((180 * _alpha) * M_PI / 180.0)/2 + 0.5];
}

#pragma mark - CPKenBurnsInfiniteScrollViewDelegate

- (void)infiniteScrollView:(CPKenBurnsInfiniteScrollView *)infiniteScrollView didShowNextItem:(NSInteger)item currentItem:(NSInteger)currentItem
{
    NSLog(@"%ld",item);
}

- (void)infiniteScrollView:(CPKenBurnsInfiniteScrollView *)infiniteScrollView didShowPreviousItem:(NSInteger)item currentItem:(NSInteger)currentItem
{
    NSLog(@"%ld",item);
}

@end
