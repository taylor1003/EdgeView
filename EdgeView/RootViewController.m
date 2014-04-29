//
//  RootViewController.m
//  EdgeView
//
//  Created by apple on 14-4-18.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "RootViewController.h"
#import "TPEdgeView.h"

@interface RootViewController () <TPEdgeViewDelegate>
{
    UIButton *btn;
    UIButton *btnChange;
    TPEdgeView *testview;
}

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.7];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(50,50, 50, 50);
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"复原" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(resetTpEdgeView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btnChange = [UIButton buttonWithType:UIButtonTypeCustom];
    btnChange.frame = CGRectMake(150, 50, 50, 50);
    btnChange.backgroundColor = [UIColor orangeColor];
    [btnChange setTitle:@"换图" forState:UIControlStateNormal];
    [btnChange addTarget:self action:@selector(changeImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnChange];
    
    testview = [[TPEdgeView alloc] initWithFrame:CGRectMake(0, 200, 200, 200) image:[[NSBundle mainBundle] pathForResource:@"1.jpg" ofType:nil] isResponse:YES];
    testview.delegate = self;
    [self.view addSubview:testview];
    
}

- (void)resetTpEdgeView
{
    [testview resetToOrigin];
}

- (void)changeImage
{
    testview.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"2.jpg" ofType:nil]];
    
}

- (void)tpEdgeViewBringOtherViewToFront:(TPEdgeView *)tpEdgeView
{
    [self.view bringSubviewToFront:btn];
    [self.view bringSubviewToFront:btnChange];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
