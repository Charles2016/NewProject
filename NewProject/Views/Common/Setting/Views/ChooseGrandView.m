//
//  ChooseGrandView.m
//  CarMango
//
//  Created by Charles on 4/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "ChooseGrandView.h"

@interface ChooseGrandView () {
    UIView *_alertView;
    UILabel *_title;
    UIButton *_close;
    UIImageView *_boy;
    UIImageView *_girl;
    UIButton *_boyButton;
    UIButton *_girlButton;
    UIButton *_complete;
    NSInteger _grand;
}

@end

@implementation ChooseGrandView

- (void)setUI {
    _grand = 3;
    _alertView = InsertView(self, CGRectZero, kColorWhite);
    _alertView.clipsToBounds = YES;
    _alertView.layer.cornerRadius = 10;
    [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.height.mas_equalTo(300);
        make.width.equalTo(self.mas_width).offset(-80);
    }];
    
    _title = InsertLabel(_alertView, CGRectZero, NSTextAlignmentCenter, @"选择你的性别", kFontSize18, kColorWhite, NO);
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.top.and.left.equalTo(_alertView);
        make.height.mas_equalTo(61);
    }];
    _title.backgroundColor = kColorNavBgFrist;
    
    UIImage *closeImage = [UIImage imageNamed:@"mine_info_close"];
    _close = InsertButtonWithType(_alertView, CGRectZero, 104215, self, @selector(hide:), UIButtonTypeCustom);
    [_close setImage:closeImage forState:UIControlStateNormal];
    [_close mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_alertView.mas_right).offset(-15);
        make.centerY.equalTo(_title.mas_centerY);
        make.size.mas_equalTo(closeImage.size);
    }];
    
    _boy = InsertImageView(_alertView, CGRectZero, [UIImage imageNamed:@"mine_info_boy"]);
    [_boy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_alertView.mas_left).offset(30);
        make.top.equalTo(_title.mas_bottom).offset(42);
        make.size.mas_equalTo(_boy.image.size);
    }];
    
    _girl = InsertImageView(_alertView, CGRectZero, [UIImage imageNamed:@"mine_info_girl"]);
    [_girl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_alertView.mas_right).offset(-30);
        make.top.equalTo(_title.mas_bottom).offset(42);
        make.size.mas_equalTo(_girl.image.size);
    }];
    
    _boyButton = InsertButtonWithType(_alertView, CGRectZero, 104216, self, @selector(chooseAction:), UIButtonTypeCustom);
    [_boyButton setBackgroundImage:[UIImage imageWithColor:UIColorHex(0xd9d9d9)] forState:UIControlStateNormal];
    [_boyButton setBackgroundImage:[UIImage imageWithColor:UIColorHex(0x9fdaf7)] forState:UIControlStateSelected];
    [_boyButton setTitle:@"男" forState:UIControlStateNormal];
    _boyButton.titleLabel.font = kFontSize18;
    _boyButton.layer.cornerRadius = 10;
    _boyButton.clipsToBounds = YES;
    _boyButton.touchAreaInsets = UIEdgeInsetsMake(100, 20, 10, 20);
    [_boyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_boy.mas_centerX);
        make.top.equalTo(_boy.mas_bottom).offset(16);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
    
    _girlButton = InsertButtonWithType(_alertView, CGRectZero, 104217, self, @selector(chooseAction:), UIButtonTypeCustom);
    [_girlButton setBackgroundImage:[UIImage imageWithColor:UIColorHex(0xd9d9d9)] forState:UIControlStateNormal];
    [_girlButton setBackgroundImage:[UIImage imageWithColor:UIColorHex(0xf99f98)] forState:UIControlStateSelected];
    [_girlButton setTitle:@"女" forState:UIControlStateNormal];
    _girlButton.titleLabel.font = kFontSize18;
    _girlButton.layer.cornerRadius = 10;
    _girlButton.clipsToBounds = YES;
    _girlButton.touchAreaInsets = UIEdgeInsetsMake(100, 20, 10, 20);
    [_girlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_girl.mas_centerX);
        make.top.equalTo(_girl.mas_bottom).offset(16);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
    
    if (GetDataUserInfo.Grand == 1) {
        _grand = 1;
        _boyButton.selected = YES;
    } else if (GetDataUserInfo.Grand == 0) {
        _grand = 0;
        _girlButton.selected = YES;
    }
    
    InsertView(_alertView, CGRectMake(0, 256, self.width - 40, 0.5), kColorNavBgFrist);
    
    _complete = InsertButtonWithType(_alertView, CGRectZero, 104218, self, @selector(hide:), UIButtonTypeCustom);
    [_complete setTitle:@"完成" forState:UIControlStateNormal];
    [_complete setTitleColor:kColorNavBgFrist forState:UIControlStateNormal];
    _complete.titleLabel.font = kFontSize15;
    [_complete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_alertView.mas_centerX);
        make.bottom.equalTo(_alertView.mas_bottom);
        make.width.equalTo(_alertView.mas_width);
        make.height.mas_equalTo(44);
    }];
    [self show];
}

/**
 *  初始化UI
 */
- (instancetype)initAlertViewWithChooseGrandComplete:(void (^)(NSInteger buttonIndex))complete {
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if (self) {
        _completeBlock = complete;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUI];
        });
    }
    return self;
}

/**
 *  展示alertView并返回值 0女 1男
 */
+ (instancetype)alertWithChooseGrandComplete:(void (^)(NSInteger buttonIndex))complete {
    ChooseGrandView *alertView = [[ChooseGrandView alloc] initAlertViewWithChooseGrandComplete:complete];
    return alertView;
}

- (void)chooseAction:(UIButton *)button {
    button.selected = YES;
    if (button.tag == 104216) {
        _grand = 1;
        _girlButton.selected = NO;
    } else if (button.tag == 104217) {
        _grand = 0;
        _boyButton.selected = NO;
    }
}


- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    keyAnimation.values = @[@0.2,@1,@0.85,@1];
    keyAnimation.duration = 0.5f;
    keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_alertView.layer addAnimation:keyAnimation forKey:nil];
    _alertView.transform = CGAffineTransformMakeScale(1, 1);
}

- (void)hide:(UIButton *)button {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    if (button.tag == 104218) {
        _completeBlock(_grand);
    }
    
}

@end
