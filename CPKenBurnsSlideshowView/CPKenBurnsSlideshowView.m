#import "CPKenBurnsSlideshowView.h"
#import "CPKenBurnsSlideshowTitleView.h"
#import "CPKenBurnsInfiniteScrollView.h"
#import "CPKenBurnsImage.h"
#import "CPKenBurnsView.h"

@interface CPKenBurnsSlideshowView () <UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *kenburnsViews;
@property (nonatomic, strong) NSMutableArray *kenburnsTitleViews;
@property (nonatomic, strong) CPKenBurnsInfiniteScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentIndex;
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
    self.scrollView.pagingEnabled = YES;

    self.kenburnsViews = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; ++i) {
        CPKenBurnsView *kenburnsView = [[CPKenBurnsView alloc] initWithFrame:self.bounds];
        [kenburnsView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.kenburnsViews addObject:kenburnsView];
        [self addSubview:kenburnsView];

        CGRect rect = self.bounds;
        rect.origin.x = CGRectGetWidth(self.bounds) * i;
        CPKenBurnsSlideshowTitleView *titleView = [[CPKenBurnsSlideshowTitleView alloc] initWithFrame:rect];
        [self.scrollView addSubview:titleView];
    }
    [self addSubview:self.scrollView];
}

- (void)setImages:(NSArray *)images
{
    _images = images;
    CPKenBurnsImage *image = images[0];
    CPKenBurnsView *kenbunrsView = self.kenburnsViews[0];
    kenbunrsView.image = image.image;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%f",scrollView.contentOffset.x);
}

@end
