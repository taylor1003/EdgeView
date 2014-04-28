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
    
    testview = [[TPEdgeView alloc] initWithFrame:CGRectMake(0, 200, 200, 200) image:[[NSBundle mainBundle] pathForResource:@"1.jpg" ofType:nil]];
    testview.delegate = self;
    [self.view addSubview:testview];
    
}

- (void)resetTpEdgeView
{
    [testview resetToOrigin];
}

- (void)tpEdgeViewBringOtherViewToFront:(TPEdgeView *)tpEdgeView
{
    [self.view bringSubviewToFront:btn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
