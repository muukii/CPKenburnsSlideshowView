//
//  CPViewController.m
//  CPKenBurnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import "CPViewController.h"
#import "CPKenBurnsImage.h"
#import "CPKenBurnsSlideshowView.h"
@interface CPViewController ()
@property (weak, nonatomic) IBOutlet CPKenBurnsSlideshowView *kenburnsSlideshowView;

@end

@implementation CPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray *images = [NSMutableArray array];
    for (int i = 1; i < 7; i++) {
        CPKenBurnsImage *image = [CPKenBurnsImage new];
        image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i]];
        [images addObject:image];
    }

    NSLog(@"%@",images);
    self.kenburnsSlideshowView.images = images;
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

@end
