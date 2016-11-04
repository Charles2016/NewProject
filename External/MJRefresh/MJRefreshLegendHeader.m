//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
//  MJRefreshLegendHeader.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "MJRefreshLegendHeader.h"
#import "MJRefreshConst.h"
#import "UIView+MJExtension.h"

@interface MJRefreshLegendHeader()
@property (nonatomic, weak) UIImageView *arrowImage;
@property (nonatomic, weak) UIActivityIndicatorView *activityView;

@end

@implementation MJRefreshLegendHeader
#pragma mark - 懒加载
- (UIImageView *)arrowImage
{
    if (!_arrowImage) {
        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:MJRefreshSrcName(@"arrow.png")]];
        [self addSubview:_arrowImage = arrowImage];
    }
    return _arrowImage;
}

- (UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.bounds = self.arrowImage.bounds;
        [self addSubview:_activityView = activityView];
    }
    return _activityView;
}

//懒加载animateimageView,用力啊播放动画
- (UIImageView *)animateimageView
{
    NSMutableArray *imageArray=[NSMutableArray new];
    if (!_animateimageView) {
        _animateimageView=[UIImageView new];
        for (int i=1; i<=26; i++) {
            [imageArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d",i]]];
        }
        self.animateimageView.animationImages=imageArray;
        self.animateimageView.animationDuration=0.05*imageArray.count;
        self.animateimageView.contentMode=UIViewContentModeCenter;
        [self addSubview:self.animateimageView];
    }
    return _animateimageView;
    
}
#pragma mark - 初始化
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.animateimageView.center=self.center;
}

#pragma mark - 公共方法
#pragma mark 设置状态
- (void)setState:(MJRefreshHeaderState)state
{
    if (self.state == state) return;
    
    // 旧状态
    MJRefreshHeaderState oldState = self.state;
    
    switch (state) {
        case MJRefreshHeaderStateIdle: {
            if (oldState == MJRefreshHeaderStateRefreshing) {
                [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                } completion:^(BOOL finished) {
                    [self.animateimageView stopAnimating];
                }];
            } else {
                [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                    self.animateimageView.image=[UIImage imageNamed:@"3"];
                }];
            }
            break;
        }
            //松开就可以进行刷新
        case MJRefreshHeaderStatePulling: {
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                [self.animateimageView startAnimating];
    
            }];
            break;
        }
            //正在刷新
        case MJRefreshHeaderStateRefreshing: {
            [self.animateimageView startAnimating];
            break;
        }
            
        default:
            break;
    }
    // super里面有回调，应该在最后面调用
    [super setState:state];
}

@end
