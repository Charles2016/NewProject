//
//  SettingPasswordVC.m
//  GoodHappiness
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "SettingPasswordVC.h"

@interface SettingPasswordVC () <UITextFieldDelegate> {
    UITextField *_password1;
    UITextField *_password2;
}

@end

@implementation SettingPasswordVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_password1 becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _isForgetStyle ? @"忘记密码" : @"快速注册";
    self.view.backgroundColor = kColorWhite;
    [self setUI];
}

- (void)setUI {
    UITextField *password[2];
    CGFloat textFieldBottom = 0;
    for (int i = 0; _isForgetStyle ? i < 2 : i < 1; i++) {
        UILabel *tip = InsertLabel(self.view, CGRectMake(15, i * 71, kScreenWidth - 30, 41), NSTextAlignmentLeft, _isForgetStyle ? @"设置新密码" : @"设置密码：", kFontSize11, kColorBlack, NO);
        
        password[i] = InsertTextFieldWithBorderAndCorRadius(self.view, self, CGRectMake(15, tip.bottom, kScreenWidth - 30, AutoWHGetHeight(30)), @"6到16个字符，区分大小写", kFontSize13, NSTextAlignmentLeft, UIControlContentVerticalAlignmentCenter, 0.5, kColorLightBlack, kColorBlack, 5.0);
        password[i].leftViewMode = UITextFieldViewModeAlways;
        password[i].secureTextEntry = YES;
        password[i].leftView = InsertView(nil, CGRectMake(0, 0, 10, tip.height), kColorWhite);
        if (i == 0) {
            _password1 = password[i];
        } else {
            tip.text = @"确认新密码";
            _password2 = password[i];
        }
        textFieldBottom = password[i].bottom;
    }
    
    // 重新发送按钮 此按钮添加在label上，只带有点击作用
    UIButton *showPassword = InsertButtonWithType(self.view, CGRectMake(_password1.right - 28, textFieldBottom + 10, 18, 10.5), 104102, self, @selector(buttonAction:), UIButtonTypeCustom);
    [showPassword setImage:[UIImage imageNamed:@"registerpassword_show"] forState:UIControlStateNormal];
    showPassword.touchAreaInsets = UIEdgeInsetsMake(10, 0, 10, 10);
    
    UIButton *commit = InsertButtonWithType(self.view, CGRectMake(_password1.left, textFieldBottom + 15, _password1.width, _password1.height), 104103, self, @selector(buttonAction:), UIButtonTypeCustom);
    [commit setTitle:_isForgetStyle ? @"完成修改" : @"完成注册" forState:UIControlStateNormal];
    commit.titleLabel.font = kFontSize13;
    [commit setTitleColor:kColorBlack forState:UIControlStateNormal];
    [commit setBackgroundImage:kButtonImage(@"button_image_yellow") forState:UIControlStateNormal];
}

#pragma mark - privateMethod
- (void)buttonAction:(UIButton *)button {
    [self.view endEditing:YES];
    if (button.tag == 104102) {
        // 查看密码按钮
        button.selected = !button.selected;
        [button setImage:[UIImage imageNamed:button.selected ? @"registerpassword_hide" : @"registerpassword_show"] forState:UIControlStateNormal];
        _password1.secureTextEntry = _password2.secureTextEntry = button.selected;
    } else {
        if (_password1.text.length < kMinPasswordLength ||  (_password2 && _password2.text.length < kMinPasswordLength)) {
            iToastText(@"密码长度应大于6个字符！");
            return;
        }
        if (!_password1.text.length) {
            iToastText(@"请输入您的密码！");
            return;
        }
        if (_isForgetStyle) {
            // 完成密码修改
            if (!_password2.text.length) {
                iToastText(@"请再次输入您的密码！");
                return;
            }
            if (![_password1.text isEqualToString:_password2.text]) {
                iToastText(@"两次密码输入不一致！");
                return;
            }
            [self loadingStartBgClear];
            [UserModel getForgetWithMobile:_phoneNumeber password:_password1.text code:_verificationCode networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
                [self registerOrChangePassWordFinishWithModel:response isRegister:NO];
            }];
           
        } else {
            /*// 完成注册
            [self loadingStartBgClear];
            @weakify(self);
            [UserModel getRegisterWithMobile:_phoneNumeber password:_password1.text code:_verificationCode networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
                @strongify(self);
                [self registerOrChangePassWordFinishWithModel:response isRegister:YES];
            }];*/
        }
    }
}

- (void)registerOrChangePassWordFinishWithModel:(StatusModel *)response isRegister:(BOOL)isRegister {
    if (response.code == 0) {
        UserModel *userModel = (UserModel *)response.data;
        // 注册完成才会去改变登录状态和保存用户信息，修改密码不做处理
        if (isRegister) {
            userModel.isLogin = YES;
            NSArray *userArray = [UserModel searchWithWhere:[NSString stringWithFormat:@"sid = '%@'", userModel.sid] orderBy:nil offset:0 count:100];
            // 判断数据库中是否有此人登录信息
            if (userArray.count) {
                [userModel updateToDB];
            } else {
                [userModel saveToDB];
            }
            GetDataUserModel = userModel;
            // 改变登录状态并保存sid和uid
            kUserDefaults(@"kSid", userModel.sid);
            kUserDefaults(@"kUid", @(userModel.userInfo.uid));
            kSynchronize;
            // 注册成功当做是登录成功并发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kLogin object:@{@"chatToken" : userModel.chatToken}];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
        if (_finishBlock) {
            _finishBlock();
        }
    } else {
        iToastText(response.msg);
    }
    [self loadingSuccess];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length) {
        // 密码长度限制
        return [CommonUtil limitLengthWithInputSource:textField maxLength:kMaxPasswordLength];
    }
    return YES;
}

@end
