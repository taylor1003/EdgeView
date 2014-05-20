UIView控件
=========

1、功能
----------

	UIView和UIImageView结合，在UIView的基础上addSubView:UIImageView，两者之间还有一个辅助UIView，用于拉伸。
	UIView的功能：拖拽、放大、旋转、拉伸，没有添加边界限制功能，长按图片进入拉伸模式。
	拉伸时，如果改变的属性（长度、宽度）值大于88，则触摸区域的有效值时44，如果小于88，以中心点为分界线，可以分别上下左右拉伸。
	
	控件实现了- (void)resetToOrigin函数，调用此函数，view将恢复到初始化位置和状态。
	
2、使用方法
----------

	TPEdgeView *testview = [[TPEdgeView alloc] initWithFrame:CGRectMake(0, 200, 200, 200) image:image isResponse:YES];
    testview.delegate = self;
    [self.view addSubview:testview];
    
    因为在操作之前会将TPEdgeView提到最前面，所以在操作结束后会调用代理函数- (void)tpEdgeViewBringOtherViewToFront:(TPEdgeView *)tpEdgeView。
    简易最好实现代理函数，以便将view中的其他view提到前面。

3、补充
-------

因为项目需求对控件中图片更换比较频繁，图片也比较大，鉴于内存紧张，显示图片都在GCD中重绘了，显示的是一张全新的图片。在放大缩小过程中也会根据显示的尺寸在原图上重绘一张新图片用于显示。

UIImage+Resize.m文件 - (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality 函数中添加了几行跟原文件中不同的代码，主要是在GCD重绘过程中如果改变了currrentImage有可能引起崩溃。虽然currentImage用在自定义setter中已经用@synchronized同步，表示线程安全，但实际应用中还是遇到了崩溃的情况。添加那几行代码之后没有再因为更改currentImage而引发崩溃。
	
	