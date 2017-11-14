//
//  LoadingAndReflashView.h
//  HKMember
//
//  Created by hua on 14-4-9.
//  Copyright (c) 2014年 mypuduo. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    LoadingStatusStart,// 开始加载
    LoadingStatusSuccess,// 加载成功
    LoadingStatusBlank, // 暂无数据
    LoadingStatusFail, // 加载失败
} LoadingStatus;

typedef enum {
    LoadingStyleNormal,// 正常加载状态
    LoadingStyleBgClear,// 加载状态无背景颜色
    LoadingStyleBlankNormal,// 正常暂无数据
    LoadingStyleBlankWithButton,// 正常暂无数据带按钮
    LoadingStyleFailNormal,// 正常暂加载失败
} LoadingStyle;

@protocol LoadingAndRefreshViewDelegate <NSObject>
// 加载失败后点击刷新重新加载
- (void)refreshClickWithStatus:(LoadingStatus)status;

@end

@interface LoadingAndRefreshView : UIView

@property (nonatomic, strong) UIImageView *loadingView; // 正在加载图
@property (nonatomic, strong) UIImageView *loadingViewBg; // 正在加载背景图
@property (nonatomic, strong) UIButton *refreshBtn;     // 刷新按钮
@property (nonatomic, strong) UILabel *loadingTip;      // 加载的文字
@property (nonatomic, assign) LoadingStatus status; // 加载状态

@property (nonatomic, weak) id <LoadingAndRefreshViewDelegate> delegate;

- (void)setLoadingStateWithOffset:(CGFloat)offset style:(LoadingStyle)style;
- (void)setSuccessState;
- (void)setFailStateWithTitle:(NSString *)titleStr imageStr:(NSString *)imageStr offset:(CGFloat)offset;
- (void)setBlankStateWithTitle:(NSString *)titleStr imageStr:(NSString *)imageStr buttonTitle:(NSString *)buttonTitle offset:(CGFloat)offset;

@end
