//
//  AppDelegate.h
//  EdgeView
//
//  Created by apple on 14-4-18.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RootViewController *rv;
@property (strong, nonatomic) UINavigationController *nav;

@end
