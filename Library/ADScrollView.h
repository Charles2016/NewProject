//
//  ADScrollView.h
//  DemoAdvertisement
//
//  Created by zhangshaoyu on 14-7-16.
//  Copyright (c) 2014年 zhangshaoyu. All rights reserved.
//  功能描述：广告栏滚动视图

#import <UIKit/UIKit.h>
@class ADPageControl;

/// 广告栏页码位置
typedef enum{
    /// 居中位置
    PageControlCenter,
    /// 右对齐位置
    PageControlRight
}PageControlMode;

/// 设置协议
@protocol ADScrollerViewDelegate <NSObject>

@optional
/// 设置协议方法，响应被选择图片事件
- (void)ADScrollerViewDidClicked:(NSUInteger)index;

@end

@interface ADScrollView : UIView
/// 图片数组
@property (nonatomic, strong) NSArray *imageSources;
/// 标题数组
@property (nonatomic, strong) NSArray *titleSources;
/// 占位图片
@property (strong, nonatomic) UIImage *placeholderImage;
/// 代理属性
@property (nonatomic, assign) id<ADScrollerViewDelegate> delegate;
/// 代码块属性
@property (nonatomic, copy) void (^imageSelected)(UITapGestureRecognizer *tap,NSInteger index);
/// 广告栏页码位置
@property (nonatomic, assign) PageControlMode pageControlMode;
/// 隐藏半透明背景
@property (nonatomic, assign) BOOL showAlphaBground;
/// 隐藏页码
@property (nonatomic, assign) BOOL showPageControl;
/// 隐藏提示页
@property (nonatomic, assign) BOOL showPageView;
/// 页码中点的颜色
@property (nonatomic, assign) UIColor *pageColor;//常态颜色
@property (nonatomic, assign) UIColor *currentPageColor;//高亮颜色
/// 开启自动播放
@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic , assign) NSInteger isShowPageFlag;

/// 广告栏初始化方法
- (id)initWithFrameRect:(CGRect)rect imageArray:(NSArray *)imageArray titleArray:(NSArray *)titleArray;
/// 开始播放
- (void)startPlayAD;
/// 停止播放
- (void)stopPlayAD;
/// 是否允许滑动
- (void)setDragging:(BOOL)canDrag;
///  获得当前图片位置
- (NSInteger)getCurrentPage;

@end

/*
 使用广告栏
 步骤1 导航文件
 
 步骤2 导入头文件 #import "ADScrollView.h"
 
 步骤3 设置协议 ADScrollerViewDelegate
 
 步骤4 实例化（参数：图片数组，标题数组）
 ADScrollView *scroller = [[ADScrollView alloc] initWithFrameRect:CGRectMake(0, 0, 320, 150)
 ImageArray:[NSArray arrayWithObjects:@"1.jpg",@"2.jpg",@"3.jpg", nil]
 TitleArray:[NSArray arrayWithObjects:@"11",@"22",@"33", nil]];
 scroller.delegate = self;
 [self.view addSubview:scroller];
 
 步骤5 实现代理
 - (void)ADScrollerViewDidClicked:(NSUInteger)index
 {
 NSLog(@"index--%d",index);
 }
 
 步骤5 通过设置相关属性实现其他行为事件
 5-1 代码块实现
 scroller.imageSelected = ^(int index){
 NSLog(@"点击了第%d栏广告",index);
 };
 5-2 设置页码位置
 scroller.pageControlMode = PageControlCenter;
 5-3 设置控制器点的颜色(可以不设置，默认是白底 选中为红色）
 pageControl.pageColor = pageColor;
 pageControl.currentPageColor = currentPageColor;
 5-4 是否隐藏半透明背景
 scroller.showAlphaBground = YES;
 5-5 是否自动播放
 scroller.autoPlay = YES;
 */
