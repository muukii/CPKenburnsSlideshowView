#import "CPKenBurnsSlideshowView.h"
#import "CPKenBurnsSlideshowTitleView.h"
#import "CPKenBurnsInfiniteScrollView.h"

@interface CPKenBurnsSlideshowView ()
@property (nonatomic, strong) NSMutableArray *kenburnsViews;
@property (nonatomic, strong) UIScrollView *scrollView;
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
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds) * 3, CGRectGetHeight(self.bounds))];
    
}


@end
