//
//  GetVerificationVC.m
//  GoodHappiness
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "GetVerificationVC.h"
#import "SettingPasswordVC.h"

@interface GetVerificationVC ()<UITextFieldDelegate> {
    UILabel *_number;
    UITextField *_verificationCode;
    NSTimer *_timer;
    NSInteger _timeCount;// 倒计时时间
    UILabel *_resend;
    UIButton *_resendButton;
    NSString *_resendStr;
}

@end

@implementation GetVerificationVC

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_verificationCode becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self timerStop];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _isForgetStyle ? @"忘记密码" : @"快速注册";
    self.view.backgroundColor = kColorWhite;
    _timeCount = 120;
    [self setUI];
    [self timerStart];
}

- (void)setUI {
    _number = InsertLabel(self.view, CGRectMake(15, 0, kScreenWidth - 30, 48), NSTextAlignmentLeft, [NSString stringWithFormat:@"您的手机号：%@", _phoneNumber], kFontSize18, kColorBlack, NO);
    UILabel *tip = InsertLabel(self.view, CGRectMake(15, _number.bottom, _number.width, 11), NSTextAlignmentLeft, @"您会收到一条带有验证码的短信，请输入验证码。", kFontSize11, kColorLightRed, NO);
    
    
    _verificationCode = InsertTextFieldWithBorderAndCorRadius(self.view, self, CGRectMake(15, tip.bottom + 15, kScreenWidth - 30, AutoWHGetHeight(30)), @"请输入验证码", kFontSize13, NSTextAlignmentLeft, UIControlContentVerticalAlignmentCenter, 0.5, kColorLightBlack, kColorBlack, 5.0);
    _verificationCode.keyboardType = UIKeyboardTypeNumberPad;
    _verificationCode.leftViewMode = UITextFieldViewModeAlways;
    _verificationCode.leftView = InsertView(nil, CGRectMake(0, 0, 10, _number.height), kColorWhite);
    
    
    UIButton *commit = InsertButtonWithType(self.view, CGRectMake(_verificationCode.left, _verificationCode.bottom + 15, _verificationCode.width, _verificationCode.height), 104100, self, @selector(buttonAction:), UIButtonTypeCustom);
    [commit setTitle:@"提交验证码" forState:UIControlStateNormal];
    commit.titleLabel.font = kFontSize13;
    [commit setTitleColor:kColorBlack forState:UIControlStateNormal];
    [commit setBackgroundImage:kButtonImage(@"button_image_yellow") forState:UIControlStateNormal];

    NSString *str2 = kIntToStr(_timeCount);
    _resendStr = [NSString stringWithFormat:@"%@ 秒后重新发送", str2];
    CGFloat resendWidth = [DataHelper widthWithString:_resendStr font:kFontSize11];
    CGFloat left = (kScreenWidth - resendWidth) / 2;
    
    _resend = InsertLabel(self.view, CGRectMake(left, commit.bottom + 15, resendWidth, 22), NSTextAlignmentCenter, _resendStr, kFontSize11, kColorBlack, YES);
    _resend.attributedText = [DataHelper getColorsInLabel:_resendStr colorStrs:@[str2] colors:@[kColorLightBlue] fontSizes:@[@11]];
    // 重新发送按钮 此按钮添加在label上，只带有点击作用
    _resendButton = InsertButtonWithType(self.view, CGRectMake(_resend.left + 30, _resend.top - 5, 80, 32), 104101, self, @selector(buttonAction:), UIButtonTypeCustom);
    _resendButton.enabled = NO;
}

#pragma mark - loadData
/*- (void)getverificationCode {
    [UserModel getverificationCodeWithMobile:_phoneNumber imageCode:_imageCode networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
        UserModel *userModel = (UserModel *)response.data;
        if (response.code == 0) {
            DLog(@"验证码：%ld", userModel.code);
        } else {
            iToastText(response.msg);
        }
        [self loadingSuccess];
    }];
}*/

#pragma mark - privateMethod
- (void)buttonAction:(UIButton *)button {
    if (button.tag == 104100) {
        if (_verificationCode.text.length) {
            // 提交验证码
            SettingPasswordVC *VC = [[SettingPasswordVC alloc]init];
            VC.isForgetStyle = _isForgetStyle;
            VC.verificationCode = _verificationCode.text;
            VC.phoneNumeber = _phoneNumber;
            VC.finishBlock = _finishBlock;
            [self.navigationController pushViewController:VC animated:YES];
        } else {
            iToastText(@"请输入验证码");
        }
        
    } else {
        // 重新发送
        
        /*[self timerStart];
        [self getverificationCode];
        iToastText(@"已向您手机发送了验证码，请注意查收");*/
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)timerStart {
    _timeCount = 120;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countdownAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
}

- (void)timerStop {
    if (_timer) {
        _resendButton.enabled = YES;
        _resendStr = [NSString stringWithFormat:@"收到没？重新发送"];
        _resend.attributedText = [DataHelper getColorsInLabel:_resendStr colorStrs:@[@"重新发送"] colors:@[kColorLightBlue] fontSizes:@[@11]];
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)countdownAction {
    _timeCount -= 1;
    NSString *str = kIntToStr(_timeCount);
    _resendStr = [NSString stringWithFormat:@"%@ 秒后重新发送", str];
    _resend.attributedText = [DataHelper getColorsInLabel:_resendStr colorStrs:@[str] colors:@[kColorLightBlue] fontSizes:@[@11]];
    if (_timeCount == 0) {
        [self timerStop];
    }
    _resend.width = [DataHelper widthWithString:_resendStr font:kFontSize11];
    _resend.left = (kScreenWidth - _resend.width) / 2;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length) {
        // 验证码最大长度限制
        return [CommonUtil limitLengthWithInputSource:textField maxLength:kVerificationCodeLength];
    }
    return YES;
}

@end
