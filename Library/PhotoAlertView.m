//
//  PhotoAlertView.m
//  GoodHappiness
//
//  Created by chaolong on 16/5/5.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "PhotoAlertView.h"
#import "FXBlurView.h"

@interface PhotoAlertView()<UIGestureRecognizerDelegate, UITextFieldDelegate> {
    UIView *_alertView;
    UITextField *_inputField;
    UILabel *_messageLabel;
    UILabel *_titleLabel;
    PhotoAlertType _alertType;
    NSString *_title;
    NSString *_message;
    NSArray *_buttonTitles;
}

@end

@implementation PhotoAlertView

/**
 *  椭圆形警告框
 *  @param title        标题
 *  @param message      内容
 *  @param buttonTitles 按钮标题
 *  @param alertType    警告框样式
 *  @param complete     返回block
 */
+ (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                 buttonTitles:(NSArray *)buttonTitles
                    alertType:(PhotoAlertType)alertType
                     complete:(void (^)(NSInteger buttonIndex))complete {
    PhotoAlertView *alertView = [[PhotoAlertView alloc]initAlertWithTitle:title message:message buttonTitles:buttonTitles alertType:alertType complete:complete];
    return alertView;
}

/**
 *  椭圆带输入栏警告框
 *  @param title        标题
 *  @param message      内容
 *  @param buttonTitles 按钮标题
 *  @param complete     返回block
 */
+ (instancetype)initInputFeildWithTitle:(NSString *)title
                                message:(NSString *)message
                           buttonTitles:(NSArray *)buttonTitles
                               complete:(void (^)(NSInteger buttonIndex, NSString *inputStr))complete {
    PhotoAlertView *alertView = [[PhotoAlertView alloc]initAlertInputFeildWithTitle:title message:message buttonTitles:buttonTitles complete:complete];
    return alertView;
}

- (id)initAlertWithTitle:(NSString *)title
                 message:(NSString *)message
            buttonTitles:(NSArray *)buttonTitles
               alertType:(PhotoAlertType)alertType
                complete:(void(^)(NSInteger buttonIndex))complete {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _chooseBlock = complete;
        _title = title;
        _message = message;
        _buttonTitles = buttonTitles;
        _alertType = alertType;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUI];
        });
    }
    return self;
}

- (id)initAlertInputFeildWithTitle:(NSString *)title
                           message:(NSString *)message
                      buttonTitles:(NSArray *)buttonTitles
                          complete:(void (^)(NSInteger buttonIndex, NSString *inputStr))complete {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _inputChooseBlock = complete;
        _title = title;
        _message = message;
        _buttonTitles = buttonTitles;
        _alertType = PhotoAlertInputStyle;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUI];
        });
    }
    return self;
}

- (void)setUI {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self];
    window.backgroundColor = kColorWhite;
    self.backgroundColor = UIColorHex_Alpha(0x000000, 0.6);
    self.frame = window.frame;
    // 高斯模糊view加在self.window上面有问题
    /*FXBlurView *bgView = [[FXBlurView alloc]initWithFrame:CGRectMake(0, 0, 40, 80)];
    bgView.backgroundColor = kColorWhite;
    bgView.tintColor = kColorClear;
    bgView.blurRadius = 4;
    [self addSubview:bgView];*/
    
    UIColor *cancleColor, *otherColor, *bgColor, *borderColor;
    UIColor *titleColor, *messageColor, *inputColor;
    if (_alertType == PhotoAlertNormal) {
        borderColor = kColorWhite;
        bgColor = kColorDeepBlack;
        cancleColor = kColorNavBground;
        otherColor = kColorWhite;
        titleColor = kColorWhite;
        messageColor = kColorLightBlack;
    } else if (_alertType == PhotoAlertViewSingle || _alertType == PhotoAlertViewSingleBlack) {
        borderColor = kColorBlack;
        bgColor = kColorWhite;
        cancleColor = _alertType == PhotoAlertViewSingleBlack ? kColorBlack : kColorLightBlack;
        otherColor =  _alertType == PhotoAlertViewSingleBlack ? kColorLightBlack : kColorBlack;
        titleColor = kColorBlack;
        messageColor = kColorLightBlack;
    } else if (_alertType == PhotoAlertInputStyle) {
        borderColor = kColorBlack;
        bgColor = kColorWhite;
        cancleColor = kColorLightBlack;
        otherColor = kColorBlack;
        titleColor = kColorBlack;
        messageColor = kColorLightBlack;
        inputColor = kColorBlack;
    }
    // 计算标题和内容高度
    CGFloat titleWidth = self.frame.size.width - 70 - 30;
    CGFloat titleHeight = 0;
    CGFloat messageHeight = 0;
    if (![NSString isNull:_title]) {
        titleHeight = [DataHelper heightWithString:_title font:kFontSize18 constrainedToWidth:titleWidth];
    }
    if (![NSString isNull:_message]) {
        messageHeight = [DataHelper heightWithString:_message font:kFontSize16 constrainedToWidth:titleWidth];
    }
    CGFloat viewHeight = titleHeight + messageHeight + 30 + 15 + 49;
    viewHeight += messageHeight ? 15 : 0;
    viewHeight += _inputChooseBlock ? 40 + 15 : 0;
    viewHeight = viewHeight > 160 ? viewHeight : 160;
    
    _alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width - 70, viewHeight)];
    _alertView.center = self.center;
    _alertView.clipsToBounds = YES;
    _alertView.layer.cornerRadius = 10.0f;
    _alertView.layer.borderWidth = 1.0;
    _alertView.layer.borderColor = borderColor.CGColor;
    _alertView.backgroundColor = bgColor;
    [self addSubview:_alertView];
    
    UIButton *button[_buttonTitles.count];
    for (int i = 0; i < _buttonTitles.count; i ++) {
        button[i] = [[UIButton alloc]initWithFrame:CGRectMake(i == 0 ? 0 : _alertView.frame.size.width - 64, _alertView.frame.size.height - 51, 64, 51)];
        button[i].tag = 105051 - i;
        button[i].touchAreaInsets = UIEdgeInsetsMake(15, i == 0 ? 0 : 50, 0, i == 0 ? 50 : 0);
        [button[i] addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button[i] setTitle:_buttonTitles[i] forState:UIControlStateNormal];
        [button[i] setTitleColor:i == 0 ? otherColor : cancleColor forState:UIControlStateNormal];
        button[i].titleLabel.font = [UIFont systemFontOfSize:16];
        [_alertView addSubview:button[i]];
    }
    if (_buttonTitles.count == 1) {
        button[0].frame = CGRectMake((_alertView.frame.size.width - 64) / 2, _alertView.frame.size.height - 51, 64, 51);
    }
    if (_title.length) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, messageHeight ? 30 : 40, titleWidth, titleHeight)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = titleColor;
        [_alertView addSubview:_titleLabel];
    }
    
    if (_message.length) {
        _messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, titleHeight ? _titleLabel.bottom + 15 : 40, titleWidth, messageHeight)];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _messageLabel.numberOfLines = 0;
        _messageLabel.text = _message;
        _messageLabel.font = [UIFont systemFontOfSize:16];
        _messageLabel.textColor = messageColor;
        [_alertView addSubview:_messageLabel];
    }
    
    if (_inputChooseBlock) {
        _titleLabel.textColor = inputColor;
        _inputField = [[UITextField alloc]initWithFrame:CGRectMake(20, messageHeight ? _messageLabel.bottom + 15 : _titleLabel.bottom + 15, _alertView.width - 40, 40)];
        _inputField.leftViewMode = UITextFieldViewModeAlways;
        _inputField.secureTextEntry = YES;
        _inputField.placeholder = @"请输入登录密码";
        _inputField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, _inputField.height)];
        _inputField.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, _inputField.height)];
        _inputField.layer.borderWidth = 0.5;
        _inputField.layer.borderColor = kColorSeparatorline.CGColor;
        _inputField.layer.cornerRadius = 5;
        [_alertView addSubview:_inputField];
    }
    
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    keyAnimation.values = @[@0.2,@1,@0.85,@1];
    keyAnimation.duration = 0.5f;
    keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_alertView.layer addAnimation:keyAnimation forKey:nil];
}

- (void)buttonAction:(UIButton *)button {
    NSInteger buttonIndex = button.tag - 105050;
    if (_chooseBlock) {
        _chooseBlock(buttonIndex);
    }
    if (_inputChooseBlock && buttonIndex == 1) {
        if (!_inputField.text.length) {
            return;
        }
        _inputChooseBlock(buttonIndex, _inputField.text);
    }
    [UIView animateWithDuration:0.3  delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _alertView.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
