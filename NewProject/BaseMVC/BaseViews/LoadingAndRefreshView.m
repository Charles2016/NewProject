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
    [self addSubview:_loadingViewBg];
    
    _loadingView = [[UIImageView alloc] init];
    [self setLoadingViewImage];
    [self addSubview:_loadingView];
    
    _loadingTip = [[UILabel alloc] initWithFrame:CGRectMake(0, _loadingViewBg.bottom, self.width, 30 * H_Unit)];
    _loadingTip.textAlignment = NSTextAlignmentCenter;
    _loadingTip.backgroundColor = [UIColor clearColor];
    _loadingTip.font = kFontSize13;
    _loadingTip.textColor = UIColorHex(0x787878);
    _loadingTip.text = @"正在玩命开车中...";
    [self addSubview:_loadingTip];
    
    _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _refreshBtn.frame = CGRectMake(0, _loadingTip.bottom + 10, 0, 32 * H_Unit);
    [_refreshBtn addTarget:self action:@selector(refreshClick) forControlEvents:UIControlEventTouchUpInside];
    [_refreshBtn setTitle:@"重新加载" forState:UIControlStateNormal];
    _refreshBtn.titleLabel.font = kFontSize16;
    [_refreshBtn setTitleColor:kColorNavBgFrist forState:UIControlStateNormal];
    _refreshBtn.layer.cornerRadius = _refreshBtn.height / 2;
    _refreshBtn.layer.borderColor = kColorNavBgFrist.CGColor;
    _refreshBtn.layer.borderWidth = 1;
    _refreshBtn.clipsToBounds = YES;
    [self addSubview:_refreshBtn];
}

- (void)setSuccessState {
    [self removeFromSuperview];
}

- (void)setLoadingStateWithOffset:(CGFloat)offset style:(LoadingStyle)style {
    [self setLoadingViewImage];
    self.height = self.superview.height - offset;
    self.top = offset;
    _loadingTip.text = @"正在玩命加载中...";
    [self setViewWithStyle:style];
}

- (void)setFailStateWithTitle:(NSString *)titleStr imageStr:(NSString *)imageStr offset:(CGFloat)offset {
    self.height = self.superview.height - offset;
    self.top = offset;
    _loadingViewBg.image = [UIImage imageNamed:imageStr.length ? imageStr : @"loading_fail"];
    _loadingTip.text = titleStr.length ? titleStr : @"加载失败，请检查网络";
    [self setViewWithStyle:LoadingStyleFailNormal];
}

- (void)setBlankStateWithAttributedString:(NSAttributedString *)attributedString imageStr:(NSString *)imageStr {
    _loadingViewBg.image = [UIImage imageNamed:imageStr.length ? imageStr : @"loading_blank"];
    _loadingTip.attributedText = attributedString;
    [self setViewWithStyle:LoadingStyleBlankNormal];
}

- (void)setBlankStateWithTitle:(NSString *)titleStr imageStr:(NSString *)imageStr buttonTitle:(NSString *)buttonTitle offset:(CGFloat)offset {
    self.height = self.superview.height - offset;
    self.top = offset;
    _loadingViewBg.image = [UIImage imageNamed:imageStr.length ? imageStr : @"loading_blank"];
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
    _loadingViewBg.size = _loadingViewBg.image.size;
    _loadingViewBg.center = CGPointMake(self.width / 2, self.height / 2 - 20 * H_Unit);
    _loadingViewBg.hidden = NO;
    
    _loadingView.center = CGPointMake(self.width / 2, self.height / 2 - 20 * H_Unit);
    _loadingView.hidden = YES;
    
    _loadingTip.top = _loadingView.bottom + 5;
    _refreshBtn.width = [DataHelper widthWithString:_refreshBtn.titleLabel.text font:kFontSize16] + 40 * W_Unit;
    _refreshBtn.centerX = _loadingTip.centerX;
    _refreshBtn.top = _loadingTip.bottom + 10;
    _refreshBtn.hidden = YES;
    self.backgroundColor = kColorWhite;
    [_loadingView stopAnimating];
    // status1加载中 2加载失败 3无数据 4无数据带按钮
    if (style == LoadingStyleNormal) {
        [self setLoadingViewImage];
        _loadingView.hidden = NO;
        _loadingViewBg.hidden = YES;
        _loadingTip.top = _loadingView.bottom + 5;
        _status = LoadingStatusStart;
    } else if (style == LoadingStyleBgClear) {
        self.backgroundColor = kColorClear;
        _loadingViewBg.centerY -= _loadingTip.height;
        _loadingView.centerY = _loadingViewBg.centerY;
        _loadingTip.top = _loadingViewBg.bottom + 5;
        _status = LoadingStatusStart;
    } else if (style == LoadingStyleFailNormal) {
        _refreshBtn.hidden = NO;
        _loadingTip.top = _loadingViewBg.bottom + 5;
        _refreshBtn.centerX = _loadingTip.centerX;
        _refreshBtn.top = _loadingTip.bottom + 10;
        _status = LoadingStatusFail;
    } else if (style == LoadingStyleBlankNormal) {
        _loadingTip.hidden = NO;
        _loadingTip.top = _loadingViewBg.bottom + 5;
        _status = LoadingStatusBlank;
    } else if (style == LoadingStyleBlankWithButton) {
        _refreshBtn.hidden = NO;
        _loadingTip.hidden = NO;
        _loadingTip.top = _loadingViewBg.bottom + 5;
        _refreshBtn.top = _loadingTip.bottom + 10;
        _status = LoadingStatusBlank;
    }
}

#pragma mark - 获取gif中的图片and设置加载图片的gif效果
- (void)setLoadingViewImage {
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"loading_icon" withExtension:@"gif"]; //加载GIF图片
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef) fileUrl, NULL);           //将GIF图片转换成对应的图片源
    size_t frameCout = CGImageSourceGetCount(gifSource);                                         //获取其中图片源个数，即由多少帧图片组成
    NSMutableArray *images = [[NSMutableArray alloc] init];                                      //定义数组存储拆分出来的图片
    for (size_t i = 0; i < frameCout; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL); //从GIF图片中取出源图片
        UIImage *imageName = [UIImage imageWithCGImage:imageRef];                  //将图片源转换成UIimageView能使用的图片源
        [images addObject:imageName];                                              //将图片加入数组中
        CGImageRelease(imageRef);
    }
    _loadingView.size = CGSizeMake(kScreenWidth, 77 * H_Unit);
    _loadingView.contentMode = UIViewContentModeScaleToFill;
    _loadingView.animationImages = images;
    _loadingView.animationDuration = 1; //每次动画时长
    [_loadingView startAnimating];
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
    if (_delegate && [_delegate respondsToSelector:@selector(refreshClickWithStatus:)]) {
        [_delegate refreshClickWithStatus:_status];
    }
}

@end
