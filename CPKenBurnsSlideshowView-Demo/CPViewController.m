//
//  CPViewController.m
//  CPKenburnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import "CPViewController.h"
#import "CPKenburnsImage.h"
#import "CPKenburnsSlideshowView.h"
#import "CPExampleTitleView.h"
@interface CPViewController () <CPKenburnsSlideshowViewDeleagte>
@property (weak, nonatomic) IBOutlet CPKenburnsSlideshowView *kenburnsSlideshowView;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation CPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray *images = [NSMutableArray array];
    for (int i = 1; i < 13; i++) {
        CPKenburnsImage *image = [CPKenburnsImage new];
        image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i]];
        image.title = [NSString stringWithFormat:@"%d",i];
        [images addObject:image];
    }

    NSLog(@"%@",images);
    self.kenburnsSlideshowView.titleViewClass = [CPExampleTitleView class];
    self.kenburnsSlideshowView.images = images;
    self.kenburnsSlideshowView.delegate = self;
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    }
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)valueChanged:(id)sender {
    CGRect rect = self.kenburnsSlideshowView.frame;
    rect.size.height = 320 + 170 * [(UISlider *)sender value];
    self.kenburnsSlideshowView.frame = rect;
}

- (void)slideshowView:(CPKenburnsSlideshowView *)slideshowView downloadImageUrl:(NSURL *)imageUrl completionBlock:(DownloadCompletionBlock)completionBlock
{
    NSLog(@"%@",imageUrl.absoluteString);
}

@end
