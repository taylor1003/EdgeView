//
//  TPEdgeView.m
//  EdgeView
//
//  Created by apple on 14-4-18.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "TPEdgeView.h"
#import "UIImage+Resize.h"

#define EDGE_WIDTH     4.0f
#define TOUCH_EDGE     10.0f
#define MIN_WIDTH      (2 * EDGE_WIDTH) // minimum width for stretch
#define STANDARD_WIDTH 44.0f // 如果EdgeView的宽度和高度大于等于88，触摸边界固定为44，否则以中心

// 如果没用frame初始化，EdgeView的默认宽度和高度为下面两个
#define UNSET_WIDTH    200
#define UNSET_HEIGHT   200

@interface TPEdgeView ()
{
    CGFloat recordDegree;
    
    /* 保存image尺寸，防止浮点运算不精确造成换同一张图片时图片始终在变大或者变小或者初始化frame为CGRectZero的问题 */
    CGFloat curImageWidth;
    CGFloat curImageHeight;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIView *edgeView;
@property (nonatomic, assign) BOOL isTouching;
@property (nonatomic, assign) BOOL isStretching;  // UITouch拉伸
@property (nonatomic, assign) BOOL isDragging;    // UITouch拖动
@property (nonatomic, assign) CGPoint prevPoint;
@property (nonatomic, assign) NSTimeInterval startTime;
//@property (nonatomic, copy) NSString *imageStr;
@property (nonatomic, copy) UIImage *initImage;
@property (nonatomic, assign) BOOL isResponseImage;    // 切换imageView的image时，是否根据现在的宽度适应新的图片

/* recording the  distance between touch point and center point when touch begin */
@property (nonatomic, assign) CGPoint deltaPoint;

@end

@implementation TPEdgeView

@dynamic currentImage;

- (void)dealloc
{    
    [_edgeView release];
    [_imageView release];
    if (_initImage) {
        [_initImage release];
    }
    
    [super dealloc];
}

- (void)setCurrentImage:(UIImage *)currentImage
{
    @synchronized(self) {
        if (_currentImage != currentImage) {
            [_currentImage release];
            _currentImage = [currentImage retain];
            
            [self resetViewWithOp:YES];
        }
    }
}

- (UIImage *)currentImage
{
    @synchronized(self) {
        return _currentImage;
    }
}

#pragma mark - initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _initEdgeViewWithFrame:frame isResponse:YES];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame isResponse:(BOOL)isResponse
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initEdgeViewWithFrame:frame isResponse:isResponse];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame imageString:(NSString *)imgStr isResponse:(BOOL)isResponse
{
    self = [super initWithFrame:frame];
    if (self) {
        _initImage = [[UIImage imageWithContentsOfFile:imgStr] copy];
        _currentImage = [[UIImage imageWithContentsOfFile:imgStr] retain];
        [self _initEdgeViewWithFrame:frame isResponse:isResponse];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image isResponse:(BOOL)isResponse
{
    self = [super initWithFrame:frame];
    if (self) {
        _initImage = [image copy];
        _currentImage = [image retain];
        [self _initEdgeViewWithFrame:frame isResponse:isResponse];
    }
    return self;
}

- (void)_initEdgeViewWithFrame:(CGRect)frame isResponse:(BOOL)isResponse
{
    _isResponseImage = isResponse;
    self.contentMode = UIViewContentModeRedraw;
    CGRect newFrame = CGRectZero;
    if (_currentImage != nil) { // 按照图片原尺寸自动缩放
        CGSize size = _currentImage.size;
        CGFloat width = size.width;
        CGFloat height = size.height;
        curImageWidth = width;
        curImageHeight = height;
        if (frame.size.width / frame.size.height < width / height) {
            height = frame.size.height;
            width = size.width * height / size.height;
        } else {
            width = frame.size.width;
            height = width * size.height / size.width;
        }
        newFrame = CGRectMake(frame.origin.x, frame.origin.y, width, height);
    }
    self.frame = newFrame;
    // 防止view初始化时为CGRectZero
    if (CGRectEqualToRect(newFrame, CGRectZero)) {
        self.frame = frame;
    }
    
    self.backgroundColor = [UIColor clearColor];
    
    _edgeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    _edgeView.backgroundColor = [UIColor clearColor];
    [self addSubview:_edgeView];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(EDGE_WIDTH, EDGE_WIDTH, self.bounds.size.width - 2 * EDGE_WIDTH, self.bounds.size.height - 2 * EDGE_WIDTH)];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.image = _currentImage;
    [self addSubview:_imageView];
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationImage:)];
    rotationGesture.delegate = self;
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchImage:)];
    pinchGesture.delegate = self;
    
    [self addGestureRecognizer:rotationGesture];
    [self addGestureRecognizer:pinchGesture];
    [rotationGesture release];
    [pinchGesture release];
    
    self.originFrame = self.frame;
}

#pragma mark - override drawRect:

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawLayer:_edgeView.layer inContext:context];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGColorRef colorRef = [UIColor colorWithRed:245/255.0f green:122/255.0f blue:179/255.0f alpha:0.5].CGColor;
    if (!_isStretching) {
        colorRef = [UIColor clearColor].CGColor;
    }
    layer.masksToBounds = YES;
    layer.cornerRadius = 6.0f;
    CGContextSetStrokeColorWithColor(ctx, colorRef);
    
    CGContextSaveGState(ctx);
    
    CGContextSetLineWidth(ctx, EDGE_WIDTH);
    CGContextAddRect(ctx, CGRectMake(EDGE_WIDTH / 2, EDGE_WIDTH / 2, layer.bounds.size.width - EDGE_WIDTH, layer.bounds.size.height - EDGE_WIDTH));
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview bringSubviewToFront:self];
    
    UITouch *touch = [touches anyObject];
    _prevPoint = [touch locationInView:self];
    if (_isStretching) {
        if (self.bounds.size.width >= 88.0f) {
            if (_prevPoint.x <= STANDARD_WIDTH || _prevPoint.x >= self.bounds.size.width - STANDARD_WIDTH) {
                _isTouching = YES;
            }
        } else {
            _isTouching = YES;
        }
        
        if (self.bounds.size.height >= 88.0f) {
            if (_prevPoint.y <= STANDARD_WIDTH || _prevPoint.y >= self.bounds.size.height - STANDARD_WIDTH) {
                _isTouching = YES;
            }
        } else {
            _isTouching = YES;
        }
        
    } else {
        _startTime = touch.timestamp;
        CGPoint superPrevPoint = [self convertPoint:_prevPoint toView:self.superview];
        _deltaPoint = CGPointMake(superPrevPoint.x - self.center.x, superPrevPoint.y - self.center.y);
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint movePoint = [[touches anyObject] locationInView:self];
    
    if (_isTouching && _isStretching) { // 拉伸view
        
        CGRect prevBounds = self.bounds;
        
        CGFloat deltaX = movePoint.x - _prevPoint.x;
        CGFloat deltaY = movePoint.y - _prevPoint.y;
        CGFloat dx = 0.f, dy = 0.f;
        
        CGFloat touchAreaWidth = self.bounds.size.width >= 88.0f ? STANDARD_WIDTH : (self.bounds.size.width / 2);
        if (_prevPoint.x <= touchAreaWidth) {
            CGRect bounds = CGRectMake(0, 0, self.bounds.size.width - deltaX, self.bounds.size.height);
            if (bounds.size.width < MIN_WIDTH) {
                return;
            }
            self.bounds = bounds;
            
            dx = -(self.bounds.size.width - prevBounds.size.width) / 2;
            self.center = CGPointMake(self.center.x + dx * cos(recordDegree), self.center.y + dx * sin(recordDegree));
        } else if (_prevPoint.x >= self.bounds.size.width - touchAreaWidth) {
            
            CGRect bounds = CGRectMake(0, 0, self.bounds.size.width + deltaX, self.bounds.size.height);
            if (bounds.size.width < MIN_WIDTH) {
                return;
            }
            self.bounds = bounds;
            
            dx = (self.bounds.size.width - prevBounds.size.width) / 2;
            self.center = CGPointMake(self.center.x + dx * cos(recordDegree), self.center.y + dx * sin(recordDegree));
            _prevPoint = movePoint;
        }
        
        CGFloat touchAreaHeight = self.bounds.size.height >= 88 ? STANDARD_WIDTH : (self.bounds.size.height / 2);
        if (_prevPoint.y <= touchAreaHeight) {
            
            CGRect bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - deltaY);
            if (bounds.size.height < MIN_WIDTH) {
                return;
            }
            self.bounds = bounds;
            
            dy = (self.bounds.size.height - prevBounds.size.height) / 2;
            self.center = CGPointMake(self.center.x + dy * sin(recordDegree), self.center.y - dy * cos(recordDegree));
        } else if (_prevPoint.y >= self.bounds.size.height - touchAreaHeight) {
            
            CGRect bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height + deltaY);
            if (bounds.size.height < MIN_WIDTH) {
                return;
            }
            self.bounds = bounds;
            
            dy = (self.bounds.size.height - prevBounds.size.height) / 2;
            self.center = CGPointMake(self.center.x - dy * sin(recordDegree), self.center.y + dy * cos(recordDegree));
            
            _prevPoint = movePoint;
        }
        
        [self resetViewWithOp:NO];
        
    } else if (!_isStretching && !_isTouching) {
        _isDragging = YES;
        
        CGPoint superMovePoint = [self convertPoint:movePoint toView:self.superview];
        self.center = CGPointMake(superMovePoint.x - _deltaPoint.x, superMovePoint.y - _deltaPoint.y);
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isTouching && !_isDragging) {
        UITouch *touch = [touches anyObject];
        if (touch.timestamp - _startTime >= 0.5) {
            _isStretching = !_isStretching;
        }
    }
    
    [self resetViewWithOp:YES];
    
    
    _prevPoint = CGPointZero;
    _isTouching = NO;
    _isDragging = NO;
    if ([self.delegate respondsToSelector:@selector(tpEdgeViewBringOtherViewToFront:)]) {
        [self.delegate tpEdgeViewBringOtherViewToFront:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetViewWithOp:YES];
    
    _prevPoint = CGPointZero;
    _isTouching = NO;
    _isDragging = NO;
    if ([self.delegate respondsToSelector:@selector(tpEdgeViewBringOtherViewToFront:)]) {
        [self.delegate tpEdgeViewBringOtherViewToFront:self];
    }
}

#pragma mark - 重绘视图以及所有子视图
- (void)resetViewWithOp:(BOOL)value
{
    [self setNeedsDisplay];
    _imageView.frame = CGRectMake(EDGE_WIDTH, EDGE_WIDTH, self.bounds.size.width - 2 * EDGE_WIDTH, self.bounds.size.height - 2 * EDGE_WIDTH);
    
    if (value) {
        if (!_isResponseImage) {
            CGSize size = _imageView.frame.size;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UIImage *image = [_currentImage resizedImage:size interpolationQuality:kCGInterpolationDefault];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _imageView.image = image;
                });
            });
        } else {
            BOOL isResetFrame = NO;
            CGRect bounds = self.imageView.frame;
            if (curImageWidth == 0 || curImageHeight == 0) { // 未用图片初始化控件
                if (CGRectEqualToRect(bounds, CGRectMake(-EDGE_WIDTH, -EDGE_WIDTH, 2 * EDGE_WIDTH, 2 * EDGE_WIDTH))) {
                    isResetFrame = YES;
                    bounds = CGRectMake(0, 0, UNSET_WIDTH - 2 * EDGE_WIDTH, UNSET_HEIGHT - 2 * EDGE_WIDTH);
                }
                curImageWidth = UNSET_WIDTH - 2 * EDGE_WIDTH;
                curImageHeight = UNSET_HEIGHT - 2 * EDGE_WIDTH;
            }
            CGFloat width, height;
            if (curImageWidth / curImageHeight < _currentImage.size.width / _currentImage.size.height) {
                width = bounds.size.width;
                if (width < UNSET_WIDTH) {
                    width = UNSET_WIDTH;
                }
                height = width * _currentImage.size.height / _currentImage.size.width;
            } else if (curImageWidth / curImageHeight > _currentImage.size.width / _currentImage.size.height){
                height = bounds.size.height;
                if (height < UNSET_HEIGHT) {
                    height = UNSET_HEIGHT;
                }
                width = height * _currentImage.size.width / _currentImage.size.height;
            } else {
                height = bounds.size.height;
                width = bounds.size.width;
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UIImage *image = [self.currentImage resizedImage:CGSizeMake(width, height) interpolationQuality:kCGInterpolationDefault];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _imageView.frame = CGRectMake(EDGE_WIDTH, EDGE_WIDTH, width, height);
                    _imageView.image = image;
                });
            });
            
            self.bounds = CGRectMake(0, 0, width + EDGE_WIDTH * 2, height + EDGE_WIDTH * 2);
            if (isResetFrame) {
                self.frame = self.bounds;
            }
            
            curImageWidth = _currentImage.size.width;
            curImageHeight = _currentImage.size.height;
        }
        
    }
    
    [_imageView setNeedsDisplay];
}

// 将View恢复到最初的大小和位置
- (void)resetToOrigin
{
    _isStretching = NO;
    recordDegree = 0;
    self.transform = CGAffineTransformMakeRotation(recordDegree);
    
    if (_initImage) {
        self.currentImage = _initImage;
    }
    
    self.bounds = CGRectMake(0, 0, self.originFrame.size.width, self.originFrame.size.height);
    self.frame = self.originFrame;
    [self resetViewWithOp:NO];
}

#pragma mark - UIGestureRecognizer Respond Functions

- (void)rotationImage:(UIRotationGestureRecognizer *)gesture
{
    if (_isStretching) {
        return;
    }
    [self.superview bringSubviewToFront:self];
    
    CGPoint location = [gesture locationInView:self.superview];
    gesture.view.center = CGPointMake(location.x, location.y);
    
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        [self resetViewWithOp:YES];
        self.lastRotation = 0;
        return;
    }
    
    CGAffineTransform currentTransform = self.transform;
    CGFloat rotation = 0.0 - (self.lastRotation - gesture.rotation);
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotation);
    self.transform = newTransform;
    
    [self resetViewWithOp:NO];
    self.lastRotation = gesture.rotation;
    
    if ([self.delegate respondsToSelector:@selector(tpEdgeViewBringOtherViewToFront:)]) {
        [self.delegate tpEdgeViewBringOtherViewToFront:self];
    }
    
    recordDegree = atan2f(self.transform.b, self.transform.a);
}

- (void)pinchImage:(UIPinchGestureRecognizer *)gesture
{
    if (_isStretching) {
        return;
    }
    
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        [self resetViewWithOp:YES];
        return;
    }
    
    [self.superview bringSubviewToFront:self];
    
    CGRect scaledBounds = CGRectMake(0, 0, self.bounds.size.width * gesture.scale, self.bounds.size.height * gesture.scale);
    self.bounds = scaledBounds;
    CGPoint location = [gesture locationInView:self.superview];
    self.center = CGPointMake(location.x, location.y);
    
    [self resetViewWithOp:NO];
    gesture.scale = 1;
    
    if ([self.delegate respondsToSelector:@selector(tpEdgeViewBringOtherViewToFront:)]) {
        [self.delegate tpEdgeViewBringOtherViewToFront:self];
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
