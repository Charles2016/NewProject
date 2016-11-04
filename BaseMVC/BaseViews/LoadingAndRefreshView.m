 //
//  LoadingAndReflashView.m
//  HKMember
//
//  Created by hua on 14-4-9.
//  Copyright (c) 2014年 mypuduo. All rights reserved.
//

#import "LoadingAndRefreshView.h"

@implementation LoadingAndRefreshView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI {
    _loadingViewBg = [[UIImageView alloc] init];
    _loadingViewBg.size = CGSizeMake(100, 100);
    _loadingViewBg.backgroundColor = UIColorHex_Alpha(0x000000, 0.8);
    _loadingViewBg.layer.cornerRadius = 10;
    _loadingViewBg.clipsToBounds = YES;
    [self addSubview:_loadingViewBg];
    
    _loadingView = [[UIImageView alloc] init];
    _loadingView.image = [UIImage imageNamed:@"loading_icon"];
    _loadingView.size = _loadingView.image.size;
    [self addSubview:_loadingView];
    
    _loadingTip = [[UILabel alloc] initWithFrame:CGRectMake(0, _loadingViewBg.bottom, self.width, 30)];
    _loadingTip.textAlignment = NSTextAlignmentCenter;
    _loadingTip.backgroundColor = [UIColor clearColor];
    _loadingTip.font = kFontSize13;
    _loadingTip.textColor = UIColorHex(0x787878);
    _loadingTip.text = @"正在玩命加载中...";
    [self addSubview:_loadingTip];
    
    _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _refreshBtn.frame = CGRectMake(0, _loadingTip.bottom + 10, (self.width - 30)/2, 32);
    [_refreshBtn addTarget:self action:@selector(refreshClick) forControlEvents:UIControlEventTouchUpInside];
    [_refreshBtn setTitle:@"重新加载" forState:UIControlStateNormal];
    [_refreshBtn setBackgroundImage:kButtonImage(@"button_image_yellow") forState:UIControlStateNormal];
    [_refreshBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
    _refreshBtn.layer.cornerRadius = 5;
    _refreshBtn.clipsToBounds = YES;
    [self addSubview:_refreshBtn];
}

- (void)setSuccessState {
    [self removeFromSuperview];
}

- (void)setLoadingStateWithOffset:(CGFloat)offset style:(LoadingStyle)style {
    _loadingView.image = [UIImage imageNamed:@"loading_icon"];
    _loadingTip.text = @"正在玩命加载中...";
    self.height = self.superview.height - offset;
    [self setViewWithStyle:style];
}

- (void)setFailStateWithTitle:(NSString *)titleStr imageStr:(NSString *)imageStr offset:(CGFloat)offset {
    self.height = self.superview.height - offset;
    _loadingView.image = [UIImage imageNamed:imageStr.length ? imageStr : @"loading_fail"];
    _loadingTip.text = titleStr.length ? titleStr : @"加载失败，请检查网络";
    [self setViewWithStyle:LoadingStyleFailNormal];
}

- (void)setBlankStateWithAttributedString:(NSAttributedString *)attributedString imageStr:(NSString *)imageStr {
    _loadingView.image = [UIImage imageNamed:imageStr.length ? imageStr : @"loading_blank"];
    _loadingTip.attributedText = attributedString;
    [self setViewWithStyle:LoadingStyleBlankNormal];
}

- (void)setBlankStateWithTitle:(NSString *)titleStr imageStr:(NSString *)imageStr buttonTitle:(NSString *)buttonTitle offset:(CGFloat)offset {
    self.height = self.superview.height - offset;
    _loadingView.image = [UIImage imageNamed:imageStr.length ? imageStr : @"loading_blank"];
    _loadingTip.text = titleStr.length ? titleStr : @"暂无数据";
    LoadingStyle style;
    if (buttonTitle.length) {
        style = LoadingStyleBlankWithButton;
        [_refreshBtn setTitle:buttonTitle forState:UIControlStateNormal];
    } else {
        style = LoadingStyleBlankNormal;
    }
    [self setViewWithStyle:style];
}

- (void)setViewWithStyle:(LoadingStyle)style {
    _loadingView.size = _loadingView.image.size;
    _loadingViewBg.size = CGSizeMake(_loadingView.width + 20, _loadingView.height + 20);
    _loadingView.center = CGPointMake(self.width / 2, self.height / 2);
    _loadingViewBg.center = CGPointMake(self.width / 2, self.height / 2);
    _loadingTip.top = _loadingView.bottom + 5;
    _refreshBtn.centerX = _loadingTip.centerX;
    _refreshBtn.top = _loadingTip.bottom + 10;
    _refreshBtn.hidden = YES;
    _loadingViewBg.hidden = YES;
    [_loadingView.layer removeAllAnimations];
    self.backgroundColor = kColorWhite;
    // status1加载中 2加载失败 3无数据 4无数据带按钮
    if (style == LoadingStyleNormal) {
        [self startRotation];
        _loadingViewBg.hidden = NO;
        _loadingViewBg.centerY -= _loadingTip.height;
        _loadingView.centerY = _loadingViewBg.centerY;
        _loadingTip.top = _loadingViewBg.bottom + 5;
        _status = LoadingStatusStart;
    } else if (style == LoadingStyleBgClear) {
        [self startRotation];
        self.backgroundColor = kColorClear;
        _loadingViewBg.hidden = NO;
        _loadingViewBg.centerY -= _loadingTip.height;
        _loadingView.centerY = _loadingViewBg.centerY;
        _loadingTip.top = _loadingViewBg.bottom + 5;
        _status = LoadingStatusStart;
    } else if (style == LoadingStyleFailNormal) {
        _refreshBtn.hidden = NO;
        _loadingView.top = (self.height - _loadingView.height - _loadingTip.height - _refreshBtn.height - 15) / 2;
        _loadingTip.top = _loadingView.bottom + 5;
        _refreshBtn.centerX = _loadingTip.centerX;
        _refreshBtn.top = _loadingTip.bottom + 10;
        _status = LoadingStatusFail;
    } else if (style == LoadingStyleBlankNormal) {
        _loadingTip.hidden = NO;
        _loadingView.top = (self.height - _loadingView.height - _loadingTip.height - 5) / 2;
        _loadingTip.top = _loadingView.bottom + 5;
        _status = LoadingStatusBlank;
    } else if (style == LoadingStyleBlankWithButton) {
        _refreshBtn.hidden = NO;
        _loadingTip.hidden = NO;
        _loadingView.top = (self.height - _loadingView.height - _loadingTip.height - 15 - _refreshBtn.height) / 2;
        _loadingTip.top = _loadingView.bottom + 5;
        _refreshBtn.top = _loadingTip.bottom + 10;
        _status = LoadingStatusBlank;
    }
}

#pragma mark - 旋转
-(void)startRotation {
    CABasicAnimation* rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotation.duration = 0.8;
    rotation.repeatCount = FLT_MAX;
    rotation.cumulative = NO;
    [_loadingView.layer addAnimation:rotation forKey:@"rotation"];
}

// 刷新
- (void)refreshClick {
    _loadingView.image = [UIImage sd_animatedGIFNamed:@"loading_icon"];
    _loadingTip.text = @"正在玩命加载中...";
    if (_delegate && [_delegate respondsToSelector:@selector(refreshClickWithStatus:)]) {
        [_delegate refreshClickWithStatus:_status];
    }
}

- (void)setNetBtnClick {
    NSURL *url = [NSURL URLWithString:@"prefs:root = set"];
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }else{
        [iToast alertWithTitle:@"系统不支持跳转"];
    }
}

@end
