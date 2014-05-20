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
{
    UIImage *_currentImage;
}

@property (atomic, retain, setter = setCurrentImage:, getter = currentImage) UIImage *currentImage;
@property (nonatomic, assign) CGRect originFrame;
@property CGFloat lastRotation;
@property (nonatomic, assign) id <TPEdgeViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame isResponse:(BOOL)isResponse;
- (id)initWithFrame:(CGRect)frame imageString:(NSString *)imgStr isResponse:(BOOL)isResponse;
- (id)initWithFrame:(CGRect)frame image:(UIImage *)image isResponse:(BOOL)isResponse;

- (void)resetToOrigin;

@end

@protocol TPEdgeViewDelegate <NSObject>

- (void)tpEdgeViewBringOtherViewToFront:(TPEdgeView *)tpEdgeView;

@end
