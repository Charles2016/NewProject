//
//  HXFAlertView.m
//  RacingCarLottery
//
//  Created by chaolong on 16/6/7.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "HXFAlertView.h"
#import <objc/runtime.h>

@interface HXFAlertView() <UITextFieldDelegate>{
    UIView *_alertView;
    UILabel *_titleLabel;
    UILabel *_messageLabel;
    UITextField *_inputField;
    UIButton *_cancelButton;
    NSMutableArray *_otherButtons;
    NSMutableArray *_separateLines;
    UIView *_spanceView;
    AlertViewType _alertViewType;
}

@end

@implementation HXFAlertView

/**
 *  alertView单个按钮样式
 *  @param title        标题
 *  @param message      消息
 *  @param cancelButton 对应按钮
 */
+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message
                  cancelButton:(NSString *)cancelButton
                      complete:(void (^)(NSInteger buttonIndex))complete {
    HXFAlertView *alertView = [[HXFAlertView alloc] initAlertViewWithTitle:title message:message cancelButton:cancelButton otherButton:nil alertViewType:AlertViewSingle complete:complete];
    return alertView;
}

/**
 *  alertView两个按钮样式
 *  @param title        标题
 *  @param message      消息
 *  @param cancelButton 取消按钮
 *  @param otherButton  其他按钮
 */
+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message
                  cancelButton:(NSString *)cancelButton
                   otherButton:(NSString *)otherButton
                      complete:(void (^)(NSInteger buttonIndex))complete {
    HXFAlertView *alertView = [[HXFAlertView alloc] initAlertViewWithTitle:title message:message cancelButton:cancelButton otherButton:otherButton alertViewType:AlertViewNormal complete:complete];
    return alertView;
}

/**
 *  alertView两个按钮带输入栏样式
 *  @param title         标题
 *  @param message       消息
 *  @param alertViewType 输入栏样式
 *  @param cancelButton  取消按钮
 *  @param otherButton   其他按钮
 */
+ (instancetype)alertInputFeildWithTitle:(NSString *)title
                                 message:(NSString *)message
                           alertViewType:(AlertViewType)alertViewType
                            cancelButton:(NSString *)cancelButton
                             otherButton:(NSString *)otherButton
                                complete:(void (^)(NSInteger buttonIndex, NSString *inputStr))complete {
    HXFAlertView *alertView = [[HXFAlertView alloc] initAlertInputFeildWithTitle:title message:message cancelButton:cancelButton otherButton:otherButton alertViewType:alertViewType complete:complete];
    return alertView;
}


/**
 * actionSheet系统默认样式(按钮字体默认蓝色)
 * @param title        标题
 * @param message      消息
 * @param cancelButton 取消按钮
 * @param otherButtons 其他按钮
 */
+ (instancetype)actionSheetWithTitle:(NSString *)title
                             message:(NSString *)message
                        cancelButton:(NSString *)cancelButton
                        otherButtons:(NSArray *)otherButtons
                            complete:(void (^)(NSInteger buttonIndex))complete {
    HXFAlertView *alertView = [[HXFAlertView alloc] initActionSheetWithTitle:title message:message cancelButton:cancelButton otherButtons:otherButtons otherColors:nil alertViewType:AlertViewSheet complete:complete];
    return alertView;
}

/**
 *  actionSheet可设置按钮字体颜色样式(按钮字体默认蓝色)
 *  @param title        标题
 *  @param message      消息
 *  @param cancelButton 取消按钮
 *  @param otherButtons 其他按钮数组
 *  @param otherColor   设置按钮颜色
 */
+ (instancetype)actionSheetWithTitle:(NSString *)title
                             message:(NSString *)message
                        cancelButton:(NSString *)cancelButton
                        otherButtons:(NSArray *)otherButtons
                         otherColors:(NSArray *)otherColors
                       alertViewType:(AlertViewType)alertViewType
                            complete:(void (^)(NSInteger buttonIndex))complete {
    
    HXFAlertView *alertView = [[HXFAlertView alloc] initActionSheetWithTitle:title message:message cancelButton:cancelButton otherButtons:otherButtons otherColors:otherColors alertViewType:alertViewType complete:complete];
    return alertView;
}

/**
 *  提示框初始化方法
 *  @param title         标题
 *  @param message       信息
 *  @param cancelButton  取消按钮
 *  @param otherButton   其他按钮
 *  @param alertViewType 按钮样式AlertViewSingle or AlertViewNormal
 */
- (instancetype)initAlertViewWithTitle:(NSString *)title
                               message:(NSString *)message
                          cancelButton:(NSString *)cancelButton
                           otherButton:(NSString *)otherButton
                         alertViewType:(AlertViewType)alertViewType
                              complete:(void (^)(NSInteger buttonIndex))complete {
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if (self) {
        _completeBlock = complete;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUIWithTitle:title message:message cancelButton:cancelButton otherButtons:otherButton.length ? @[otherButton] : nil otherColors:nil alertViewType:alertViewType];
        });
    }
    return self;
}

/**
 *  带输入栏提示框初始化方法
 *  @param title         标题
 *  @param message       信息
 *  @param cancelButton  取消按钮
 *  @param otherButton   其他按钮
 *  @param alertViewType 按钮样式AlertViewSingle or AlertViewNormal
 */
- (instancetype)initAlertInputFeildWithTitle:(NSString *)title
                                     message:(NSString *)message
                                cancelButton:(NSString *)cancelButton
                                 otherButton:(NSString *)otherButton
                               alertViewType:(AlertViewType)alertViewType
                                    complete:(void (^)(NSInteger buttonIndex, NSString *inputStr))complete {
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if (self) {
        _inputCompleteBlock = complete;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUIWithTitle:title message:message cancelButton:cancelButton otherButtons:otherButton.length ? @[otherButton] : nil otherColors:nil alertViewType:alertViewType];
        });
    }
    return self;
}


/**
 *  actionSheet初始化方法
 *  @param title        标题
 *  @param message      信息
 *  @param cancelButton 取消按钮
 *  @param otherButtons 其他按钮数组
 *  @param otherColor   其他按钮颜色自定义
 *  @param type         显示样式 2系统样样式 3自定义满屏颜色
 */
- (instancetype)initActionSheetWithTitle:(NSString *)title
                                 message:(NSString *)message
                            cancelButton:(NSString *)cancelButton
                            otherButtons:(NSArray *)otherButtons
                             otherColors:(NSArray *)otherColors
                           alertViewType:(AlertViewType)alertViewType
                                complete:(void (^)(NSInteger buttonIndex))complete {
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if (self) {
        _completeBlock = complete;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUIWithTitle:title message:message cancelButton:cancelButton otherButtons:otherButtons otherColors:otherColors alertViewType:alertViewType];
        });
        
    }
    return self;
}

- (void)setUIWithTitle:(NSString *)title
               message:(NSString *)message
          cancelButton:(NSString *)cancelButton
          otherButtons:(NSArray *)otherButtons
           otherColors:(NSArray *)otherColors
         alertViewType:(AlertViewType)alertViewType {
    _alertViewType = alertViewType;
    _otherButtons = [NSMutableArray arrayWithCapacity:0];
    _separateLines = [NSMutableArray arrayWithCapacity:0];
    _alertView = [[UIView alloc] init];
    _alertView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self addSubview:_alertView];
    // 标题
    if (![NSString isNull:title]) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = title;
        [_alertView addSubview:_titleLabel];
    }
    // 消息内容
    if (![NSString isNull:message]) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont systemFontOfSize:12];
        _messageLabel.textColor = [UIColor colorWithRed:0.482 green:0.482 blue:0.482 alpha:1.00];
        _messageLabel.text = message;
        [_alertView addSubview:_messageLabel];
    }
    // 取消按钮
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:cancelButton forState:UIControlStateNormal];
    _cancelButton.tag = 106070;
    _cancelButton.backgroundColor = [UIColor whiteColor];
    _cancelButton.titleLabel.font= [UIFont boldSystemFontOfSize:16];
    [_cancelButton setTitleColor:[UIColor colorWithRed:0.223 green:0.521 blue:1 alpha:1.00] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector (buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:_cancelButton];
    // 分割线
    _spanceView = [[UIView alloc] init];
    [_alertView addSubview:_spanceView];
    // 其他按钮
    if (otherButtons.count > 0) {
        for (NSUInteger i = 0; i < otherButtons.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            UIColor *otherColor;
            if (otherColors.count >= i + 1) {
                otherColor = otherColors[i];
            }
            [button setTitleColor:otherColor ? otherColor : [UIColor colorWithRed:0.223 green:0.521 blue:1 alpha:1.00] forState:UIControlStateNormal];
            [button setTitle:otherButtons[i] forState:UIControlStateNormal];
            button.tag = 106070 + i + 1;
            [button addTarget:self action:@selector (buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            [_alertView addSubview:button];
            [_otherButtons addObject:button];
            
            UIView* separateLine = [[UIView alloc] init];
            separateLine.backgroundColor = [UIColor colorWithRed:0.867 green:0.867 blue:0.867 alpha:1.00];
            [_alertView addSubview:separateLine];
            [_separateLines addObject:separateLine];
        }
    }
    // 计算标题和内容高度
    CGFloat titleHeight = 0;
    CGFloat titleWidth = self.width - 120 - 30;
    CGFloat messageHeight = 0;
    if (![NSString isNull:title]) {
        titleHeight = [DataHelper heightWithString:title font:kFontSize18 constrainedToWidth:titleWidth];
    }
    if (![NSString isNull:message]) {
        messageHeight = [DataHelper heightWithString:message font:kFontSize16 constrainedToWidth:titleWidth];
    }
    if (alertViewType == AlertViewSingle || alertViewType == AlertViewNormal) {
        // 系统正常中部弹出框只带单个 or 两个按钮
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 0;
        CGFloat viewHeight = titleHeight + messageHeight + 49 + 50;
        viewHeight = viewHeight > 150 ? viewHeight : 150;
        
        _alertView.layer.cornerRadius = 10;
        _alertView.clipsToBounds = YES;
        _alertView.size = CGSizeMake(self.width - 120, viewHeight);
        _alertView.center = self.center;
        _spanceView.frame = CGRectMake (0, _alertView.height - 49.5, _alertView.width, 0.5);
        _spanceView.backgroundColor = [UIColor colorWithRed:0.867 green:0.867 blue:0.867 alpha:1.00];
        if (alertViewType == AlertViewSingle) {
            _cancelButton.frame = CGRectMake (0, _alertView.height - 49, _alertView.width, 49);
        } else {
            for (int i = 0; i < _otherButtons.count; i ++) {
                UIButton *button = _otherButtons[i];
                button.frame = CGRectMake (_alertView.width / 2, _alertView.height - 49, _alertView.width / 2, 49);
                
                UIView *separateLine = _separateLines[i];
                separateLine.frame = CGRectMake (button.left, _spanceView.bottom, 0.5, button.height);
            }
            _cancelButton.frame = CGRectMake (0, _alertView.height - 49, _alertView.width / 2, 49);
        }
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.frame = CGRectMake (15, 20, titleWidth, [NSString isNull:message] ? _alertView.height - 49 - 40: titleHeight);
        _messageLabel.font = [UIFont systemFontOfSize:16];
        _messageLabel.frame = CGRectMake (15, _titleLabel.bottom + 10, titleWidth, [NSString isNull:title] ? _alertView.height - 49 - 40 : messageHeight);
    } else if (alertViewType == AlertViewSheet || alertViewType == AlertViewSheetFull) {
        // 系统正常底部弹出空边 or 满屏sheetView
        CGFloat viewHeight = 49.5 * otherButtons.count + 5 + 49;
        if (![NSString isNull:title] && ![NSString isNull:message]) {
            viewHeight += 60;
        }
        if (([NSString isNull:title] && ![NSString isNull:message]) || (![NSString isNull:title] && [NSString isNull:message])) {
            viewHeight += 49;
        }
        CGFloat actionSheetViewHeight = viewHeight - 49 - 5;
        if (alertViewType == AlertViewSheet) {
            _alertView.frame = CGRectMake (15, self.height - viewHeight, self.width - 30, actionSheetViewHeight);
            _alertView.layer.cornerRadius = 10;
            _alertView.clipsToBounds = YES;
            _cancelButton.frame = CGRectMake (_alertView.left, _alertView.bottom + 5, _alertView.width, 44);
            _cancelButton.layer.cornerRadius = 10;
            _cancelButton.clipsToBounds = YES;
            [self addSubview:_cancelButton];
        } else {
            _alertView.frame = CGRectMake (0, self.height - viewHeight, self.width, viewHeight);
            _cancelButton.frame = CGRectMake (0, _alertView.height - 49, _alertView.width, 49);
            _spanceView.frame = CGRectMake (0, _cancelButton.top - 5, _alertView.width, 5);
            _spanceView.backgroundColor = kColorNavBgFrist;
            [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        NSUInteger buttonY = alertViewType == AlertViewSheet ? _alertView.height - 49 : _cancelButton.top - 49 - 5;
        for (int i = 0; i < _otherButtons.count; i ++) {
            UIButton *button = _otherButtons[i];
            button.frame = CGRectMake (0, buttonY, _alertView.width, 49);
            UIView *separateLine = _separateLines[i];
            separateLine.frame = CGRectMake (0, button.top - 0.5, _alertView.width, 0.5);
            buttonY = separateLine.top - 49;
        }
        _titleLabel.frame = CGRectMake (0, 7.5, _alertView.width, [NSString isNull:message] ? 15 : 34);
        _messageLabel.frame = CGRectMake (0, _titleLabel.bottom, _alertView.width, [NSString isNull:title] ? 49 : 30);
        // 添加手势处理
        @weakify(self);
        [self addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            @strongify(self);
            CGPoint touchPoint = [gestureRecoginzer locationInView:self];
            if (!CGRectContainsPoint(self->_alertView.frame, touchPoint)) {
                // 手势点击的tag为-1
                [self buttonAction:nil];
            }
        }];
    } else if (alertViewType == AlertViewInputFeildCenter || alertViewType == AlertViewInputFeildBottom) {
        CGFloat viewHeight = titleHeight + messageHeight + 49 + 40 + 20 + 15 + 15;
        viewHeight += messageHeight ? 15 : 0;
        
        viewHeight = viewHeight > 160 ? viewHeight : 160;
        
        _alertView.layer.cornerRadius = 10;
        _alertView.clipsToBounds = YES;
        _alertView.size = CGSizeMake(self.width - 120, viewHeight);
        _alertView.center = self.center;
        
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.frame = CGRectMake (15, 20, titleWidth, titleHeight);
        _messageLabel.font = [UIFont systemFontOfSize:16];
        _messageLabel.frame = CGRectMake (15, titleHeight ? _titleLabel.bottom + 15 : _titleLabel.bottom, titleWidth, messageHeight);
        
        _inputField = [[UITextField alloc]initWithFrame:CGRectMake(20, _messageLabel ? _messageLabel.bottom + 15 : _titleLabel.bottom + 15, _alertView.width - 40, 40)];
        _inputField.leftViewMode = UITextFieldViewModeAlways;
        _inputField.secureTextEntry = YES;
        _inputField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, _inputField.height)];
        _inputField.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, _inputField.height)];
        _inputField.layer.borderWidth = 0.5;
        _inputField.layer.borderColor = kColorSeparateline.CGColor;
        _inputField.layer.cornerRadius = 5;
        [_alertView addSubview:_inputField];
        
        _spanceView.frame = CGRectMake (0, _alertView.height - 49.5, _alertView.width, 0.5);
        _spanceView.backgroundColor = [UIColor colorWithRed:0.867 green:0.867 blue:0.867 alpha:1.00];
        
        for (int i = 0; i < _otherButtons.count; i ++) {
            UIButton *button = _otherButtons[i];
            button.frame = CGRectMake (0, _alertView.height - 49, _alertView.width / 2, 49);
            
            UIView *separateLine = _separateLines[i];
            separateLine.frame = CGRectMake (button.right, _spanceView.bottom, 0.5, button.height);
        }
        _cancelButton.frame = CGRectMake (_alertView.width / 2, _alertView.height - 49, _alertView.width / 2, 49);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self show];
    });
}

- (void)show {
    CGRect oldFrame = _alertView.frame;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    @weakify(self);
    if (_alertViewType == AlertViewSingle || _alertViewType == AlertViewNormal || _alertViewType == AlertViewInputFeildCenter || _alertViewType == AlertViewInputFeildBottom) {
        CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        keyAnimation.values = @[@0.2,@1,@0.85,@1];
        keyAnimation.duration = 0.5f;
        keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [_alertView.layer addAnimation:keyAnimation forKey:nil];
        _alertView.transform = CGAffineTransformMakeScale(1, 1);
    } else {
        _alertView.frame = CGRectMake (0, self.bottom, self.width, self.height);
        if ([_cancelButton.superview isEqual:self]) {
            _cancelButton.top = self->_alertView.bottom + 5;
        }
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            self->_alertView.frame = oldFrame;
            if ([self->_cancelButton.superview isEqual:self]) {
                self->_cancelButton.top = self->_alertView.bottom + 5;
            }
        }];
    }
}

- (void)hide {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        if (_alertViewType == AlertViewSheet || _alertViewType == AlertViewSheetFull) {
            self-> _alertView.top = self.bottom;
            if ([self->_cancelButton.superview isEqual:self]) {
                self->_cancelButton.top = self->_alertView.bottom + 5;
            }
        } else {
            self.alpha = 0;
        }
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)buttonAction:(UIButton *)button {
    if (_completeBlock) {
        _completeBlock (button ? button.tag - 106070 : -1);
    }
    if (_inputCompleteBlock) {
        if (!_inputField.text.length) {
            return;
        }
        _inputCompleteBlock (button ? button.tag - 106070 : -1, _inputField.text);
    }
    [self hide];
}

@end

