//
//  RegisterVC.m
//  RacingCarLottery
//
//  Created by Charles on 2017/7/15.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import "RegisterVC.h"

@interface RegisterVC () <UITextFieldDelegate>{
    UITextField *_textField[2];
    UIButton *_button[3];
    UIImageView *_logoView;
    NSTimer *_timer;
    NSInteger _count;
    NSString *_verifyStr;
}
@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"用户注册";
    self.view.backgroundColor = kColorWhite;
    // 倒计时秒数设置
    _count = 120;
    [self setUI];
}

- (void)setUI {
    _logoView = InsertImageView(self.view, CGRectZero, [UIImage imageNamed:@"login_logo"]);
    _logoView.layer.cornerRadius = 10;
    _logoView.layer.masksToBounds = YES;
    [_logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(25);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(70 * H_Unit);
        make.width.mas_equalTo(70 * W_Unit);
    }];
    
    for (int i = 0; i < 2; i++) {
        _textField[i] = InsertTextFieldWithTextColor(self.view, self, CGRectZero, i == 0 ? @"请输入手机号码" : @"请输入验证码", kFontSize13 , NSTextAlignmentLeft, UIControlContentVerticalAlignmentCenter, kColorBlack);
        [_textField[i] mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.top.equalTo(_logoView.mas_bottom).offset(25);
            } else {
                make.top.equalTo(_textField[0].mas_bottom).offset(1);
            }
            make.left.equalTo(self.view.mas_left).offset(25);
            make.width.equalTo(self.view.mas_width).offset(-50);
            make.height.mas_equalTo(47 * H_Unit);
        }];
        _textField[i].keyboardType = i == 0 ? UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
        _textField[i].leftViewMode = UITextFieldViewModeAlways;
        UIView *lefTView = InsertView(nil, CGRectMake(0, 0, 30, _textField[i].height), kColorWhite);
        UIImageView *imageView = InsertImageView(lefTView, CGRectZero, [UIImage imageNamed:i == 0 ? @"login_user_icon" : @"code_icon"]);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(lefTView);
            make.size.mas_equalTo(CGSizeMake(15 * W_Unit, 15 * H_Unit));
        }];
        _textField[i].leftView = lefTView;
        UIView *line = InsertView(self.view, CGRectZero , kColorSeparatorline);
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_textField[i].mas_bottom);
            make.left.equalTo(_textField[i].mas_left);
            make.width.equalTo(_textField[i].mas_width);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    UILabel *tip = InsertLabel(self.view, CGRectZero, NSTextAlignmentLeft, @"", kFontSize11, kColorLightBlack, NO);
    tip.attributedText = [DataHelper getColorsInLabel:@"已阅读或同意《多得彩用户服务协议》" colorStrs:@[@"《多得彩用户服务协议》"] colors:@[kColorNavBgFrist] fontSizes:@[@11]];;
    CGFloat tipWidth = [DataHelper widthWithString:tip.text font:kFontSize11];
    @weakify(self);
    tip.userInteractionEnabled = YES;
    [tip addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        // 跳转注册服务协议
        [SuperWebVC pushToWebViewWithUrl:kRegisterURL fromVC:self];
    }];
    
    NSArray *titleArray = @[@"获取验证码", @"立即注册", @""];
    for (int i = 0; i < titleArray.count; i++) {
        _button[i] = InsertButtonWithType(self.view, CGRectZero, 104190 + i, self, @selector(buttonAction:), UIButtonTypeCustom);
        [_button[i] setTitle:titleArray[i] forState:UIControlStateNormal];
        _button[i].titleLabel.font = kFontSize13;
        [_button[i] setTitleColor:i == 0 ? kColorRed: kColorWhite forState:UIControlStateNormal];
        [_button[i] mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.centerY.equalTo(_textField[0].mas_centerY);
                make.right.equalTo(_textField[0].mas_right).offset(-5);
                make.height.mas_equalTo(25 * H_Unit);
                make.width.mas_equalTo(78 * W_Unit);
            } else if (i == 1) {
                make.top.equalTo(_textField[1].mas_bottom).offset(40);
                make.centerX.equalTo(self.view.mas_centerX);
                make.height.mas_equalTo(40 * H_Unit);
                _button[i].titleLabel.font = kFontSize16;
                make.width.equalTo(_textField[1].mas_width);
            } else if (i == 2) {
                make.top.equalTo(_button[1].mas_bottom).offset(15);
                make.left.equalTo(_button[1].mas_left).offset(50 * W_Unit);
                make.size.mas_equalTo(CGSizeMake(12 * W_Unit, 12 * H_Unit));
            }
        }];
        if (i == 0) {
            _button[i].layer.cornerRadius = 25 * H_Unit / 2;
            _button[i].layer.borderColor = kColorRed.CGColor;
            _button[i].layer.borderWidth = 0.5;
        } else if (i == 1) {
            _button[i].layer.cornerRadius = 5;
            [_button[i] setBackgroundColor:kColorNavBgFrist];
        } else {
            _button[i].touchAreaInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            _button[i].selected = YES;
            [_button[i] setImage:kButtonImage(@"login_unchoose") forState:UIControlStateNormal];
            [_button[i] setImage:kButtonImage(@"login_choose") forState:UIControlStateSelected];
        }
    }
    
    [tip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_button[2].mas_right).offset(7);
        make.centerY.equalTo(_button[2].mas_centerY);
        make.size.mas_equalTo(CGSizeMake(tipWidth * W_Unit, 12 * H_Unit));
    }];
    
}

#pragma mark - privateMethod
- (void)buttonAction:(UIButton *)button {
    // 收回键盘
    [self.view endEditing:YES];
    if (button.tag == 104190 || button.tag == 104191) {
        if (!_textField[0].text.length) {
            iToastText(@"请输入手机号");
            return;
        }
        if (!_textField[1].text.length && button.tag == 104191) {
            iToastText(@"请输入验证码");
            return;
        }
        [HUDManager showHUDWithMessage:@"正在登陆..."];
        if (button.tag == 104190) {
            // 获取短信验证码
            [UserModel getVerificationCodeWithPhone:_textField[0].text networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
                if (response.Success) {
                    UserModel *model = response.Data;
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = kIntToStr(model.code);
                    // 倒计时开始
                    [self timerStart];
                } else {
                    iToastText(response.Msg);
                }
                [HUDManager hiddenHUD];
            }];
        } else {
            // 登录
            @weakify(self);
            [UserModel getLoginWithPhone:_textField[0].text code:_textField[1].text networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
                @strongify(self);
                if (response.Success) {
                    //改变登录状态并返回
                    [self loginSuccesswithUsermodel:response.Data];
                } else {
                    iToastText(response.Msg);
                }
//                [HUDManager hiddenHUD];
            }];
        }
        
    } else if (button.tag == 104192) {
        // 选择协议
        button.selected = !button.selected;
    }
}

///登录成功处理
- (void)loginSuccesswithUsermodel:(UserModel*)userModel {
    // 注册完成or完善个人资料完成更新状态
    userModel.isLogin = YES;
    userModel.uid = [NSString stringWithFormat:@"%ld", userModel.UserInfo.ID];
    NSArray *userArray = [UserModel searchWithWhere:[NSString stringWithFormat:@"uid = '%@'", userModel.uid] orderBy:nil offset:0 count:100];
    // 判断数据库中是否有此人登录信息
    if (userArray.count) {
        [userModel updateToDB];
    } else {
        [userModel saveToDB];
    }
    GetDataUserModel = userModel;
    // 改变登录状态并保存liv和uid
    kUserDefaults(@"kLIV", userModel.LIV);
    kUserDefaults(@"kUid", userModel.uid);
    kSynchronize;
    [self dismissViewControllerAnimated:YES completion:nil];
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[self class]]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if (_successBlock) {
        _successBlock();
    }
}

- (void)timerStart {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
        [_timer fire];
    }
    _button[0].enabled = NO;
}

- (void)timerAction {
    if (_count != 0) {
        _count--;
        _verifyStr = [NSString stringWithFormat:@"%ld秒后重试", _count];
        [_button[0] setTitle:_verifyStr forState:UIControlStateNormal];
    } else {
        _count = 120;
        [_timer invalidate];
        _timer = nil;
        _verifyStr = @"获取验证码";
        _button[0].enabled = YES;
    }
    [_button[0] setTitle:_verifyStr forState:UIControlStateNormal];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length) {
        if ([_textField[0] isFirstResponder]) {
            // 手机号码长度限制
            return [CommonUtil limitLengthWithInputSource:textField maxLength:kMaxAccountLength];
        }
        if ([_textField[1] isFirstResponder]) {
            // 验证码长度限制
            return [CommonUtil limitLengthWithInputSource:textField maxLength:kMaxCodeLength];
        }
    }
    return YES;
}

@end
