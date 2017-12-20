//
//  LoadingBgView.h
//  GameTerrace
//
//  Created by Charles on 2017/12/13.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingBgView : UIView

@property (nonatomic, strong) UIImageView *loadingView; // 正在加载图
@property (nonatomic, strong) UIImageView *loadingViewBg; // 正在加载背景图
@property (nonatomic, strong) UIButton *refreshBtn;     // 刷新按钮
@property (nonatomic, strong) UILabel *loadingTip;      // 加载的文字
@property (nonatomic, assign) LoadingStatus status; // 加载状态
@property (nonatomic, copy) void (^refreshClick)(LoadingStatus status);

- (void)setLoadingStateWithOffset:(CGFloat)offset style:(LoadingStyle)style;
- (void)setSuccessState;
- (void)setFailStateWithTitle:(NSString *)titleStr imageStr:(NSString *)imageStr offset:(CGFloat)offset;
- (void)setBlankStateWithTitle:(NSString *)titleStr imageStr:(NSString *)imageStr buttonTitle:(NSString *)buttonTitle offset:(CGFloat)offset;

@end
