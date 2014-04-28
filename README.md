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

	TPEdgeView *testview = [[TPEdgeView alloc] initWithFrame:CGRectMake(0, 200, 200, 200) image:[[NSBundle mainBundle] pathForResource:@"1.jpg" ofType:nil]];
    testview.delegate = self;
    [self.view addSubview:testview];
    
    因为在操作之前会将TPEdgeView提到最前面，所以在操作结束后会调用代理函数- (void)tpEdgeViewBringOtherViewToFront:(TPEdgeView *)tpEdgeView。
    简易最好实现代理函数，以便将view中的其他view提到前面。
	
	