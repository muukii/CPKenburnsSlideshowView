//
//  CPViewController.m
//  CPKenBurnsSlideshowView-Demo
//
//  Created by Muukii on 4/7/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

#import "CPViewController.h"
#import "CPKenBurnsImage.h"
@interface CPViewController ()

@end

@implementation CPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        CPKenBurnsImage *image = [CPKenBurnsImage new];
        image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i]];
        [images addObject:image];
    }

    NSLog(@"%@",images);

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
