//
//  TPEdgeView.h
//  EdgeView
//
//  Created by apple on 14-4-18.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TPEdgeViewDelegate;

@interface TPEdgeView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGRect originFrame;
@property CGFloat lastRotation;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) id <TPEdgeViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame image:(NSString *)image;

- (void)resetToOrigin;

@end

@protocol TPEdgeViewDelegate <NSObject>

- (void)tpEdgeViewBringOtherViewToFront:(TPEdgeView *)tpEdgeView;

@end
