//
//  LoginVC.m
//  GoodHappiness
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "LoginVC.h"
#import "RegisterVC.h"
#import "ForgetPasswordVC.h"

@interface LoginVC () <UITextFieldDelegate>{
    UITextField *_textField[2];
    UIButton *_button[3];
    UIButton *_thirdbutton[2];
}
@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    self.view.backgroundColor = kColorWhite;
    [self setUI];
}

- (void)setUI {
    for (int i = 0; i < 2; i++) {
        _textField[i] = InsertTextFieldWithTextColor(self.view, self, CGRectMake(0, i * AutoWHGetHeight(40.5), kScreenWidth, AutoWHGetHeight(40)), i == 0 ? @"手机号码" : @"账号密码", kFontSize13 , NSTextAlignmentLeft, UIControlContentVerticalAlignmentCenter, kColorBlack);
        _textField[i].keyboardType = i == 0 ? UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
        _textField[i].leftViewMode = UITextFieldViewModeAlways;
        _textField[i].secureTextEntry = i == 1 ? YES : NO;
        _textField[i].leftView = InsertView(nil, CGRectMake(0, 0, 38, _textField[i].height), kColorWhite);
        InsertView(self.view, CGRectMake(10, _textField[i].bottom, kScreenWidth - 20, 0.5) , kColorSeparatorline);
        InsertImageView(self.view, CGRectMake(10, AutoWHGetHeight(11 + i * 40.5), 18, 18), [UIImage imageNamed:i == 0 ? @"login_account_icon" : @"login_password_icon"]);
    }
    
    NSArray *titleArray = @[@"登录", @"通过手机号注册", @"忘记密码？"];
    NSArray *imageArray = @[@"button_image_yellow", @"button_image_black", @""];
    for (int i = 0; i < 3; i++) {
        _button[i] = InsertButtonWithType(self.view, CGRectMake(10, _textField[1].bottom + AutoWHGetHeight(20) + i * AutoWHGetHeight(40), kScreenWidth - 20, AutoWHGetHeight(30)), 104104 + i, self, @selector(buttonAction:), UIButtonTypeCustom);
        [_button[i] setTitle:titleArray[i] forState:UIControlStateNormal];
        _button[i].titleLabel.font = kFontSize13;
        [_button[i] setTitleColor:i == 2 ? kColorDarkgray: kColorBlack forState:UIControlStateNormal];
        if (i != 2) {
            [_button[i] setBackgroundImage:kButtonImage(imageArray[i]) forState:UIControlStateNormal];
        } else {
            // 忘记密码按钮
            CGFloat forgetWidth = [DataHelper widthWithString:titleArray[2] font:kFontSize13];
            _button[i].frame = CGRectMake(_textField[1].right - forgetWidth - 20, _textField[1].top, forgetWidth, _textField[1].height);
        }
    }
    
    CGFloat lineW = (kScreenWidth - 100 - 4 - 30) / 2.0;
    UIView *line1 = InsertView(self.view, CGRectMake(15, _button[1].bottom + 50, lineW, 2), kColorBlack);
    UILabel *label = InsertLabel(self.view, CGRectMake(line1.right + 2,_button[1].bottom + 42, 100, 20) , NSTextAlignmentCenter, @"其他登录方式", kFontSize12, kColorBlack, NO) ;
    InsertView(self.view,CGRectMake(label.right + 2, _button[1].bottom + 50, lineW, 2), kColorBlack);
    
    //三方登录按钮
    NSArray *imageStrs = @[@"share_qq", @"share_wechat"];
    NSArray *titles = @[@"QQ", @"微信"];
    for (int i = 0; i < 2; i++) {
        CGFloat width = (kScreenWidth - 100) / 2;
        _thirdbutton[i] = InsertButtonWithType(self.view, CGRectMake(i == 0 ? 50 : (50 + width), _button[1].bottom + 80, width, 80), 208230 + i, self, @selector(ThirdLoginButtonClicked:), UIButtonTypeCustom);
        [_thirdbutton[i] setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 20, 0)];
        [_thirdbutton [i] setImage:[UIImage imageNamed:imageStrs[i]] forState:UIControlStateNormal];
        InsertLabel(_thirdbutton[i], CGRectMake(0, 60, width, 20), NSTextAlignmentCenter, titles[i], kFontSize11, kColorBlack, NO);
        _thirdbutton[i].contentMode = UIViewContentModeScaleAspectFit;
    }
}

///三方按钮点击登录
- (void)ThirdLoginButtonClicked:(UIButton *)sender {
    NSUInteger index = sender.tag - 208230;
    NSString *UmengShareType ;
    NSString *action ;
    switch (index) {
        case 0:
            UmengShareType = UMShareToQQ;
            action = @"qq";
            break;
        case 1:
            UmengShareType = UMShareToWechatSession;
            action = @"wx";
            break;
        default:
            break;
            }
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UmengShareType];
    snsPlatform.loginClickHandler(self, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity *response) {
    //获取用户名 ID、token等
    if (response.responseCode == UMSResponseCodeSuccess) {
        UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:snsPlatform.platformName];
         //三方登录接口请求
        @weakify(self);
        [UserModel getThirdLoginWithAction:action openid:snsAccount.unionId ? snsAccount.unionId : snsAccount.openId acessToken:snsAccount.accessToken userName:snsAccount.userName iconURL:snsAccount.iconURL networkHUD:NetworkHUDMsg target:self sucess:^(StatusModel *response) {
            if (response.code == 0) {
                @strongify(self);
                [self changeLoginStatewithUsermodel:response.data];
            } else {
                iToastText(response.msg);
            }
            [self loadingSuccess];
        }];
        } else {
            DLog(@"====================响应失败");
        }
    });
}

#pragma mark - privateMethod
- (void)buttonAction:(UIButton *)button {
    [self.view endEditing:YES];
    if (button.tag == 104104) {
        if (!_textField[0].text.length) {
            iToastText(@"请输入手机号");
            return;
        }
        if (!_textField[1].text.length) {
            iToastText(@"请输入密码");
            return;
        }
        [self loadingStartBgClear];
        // 登录
        @weakify(self);
        [UserModel getLoginWithMobile:_textField[0].text password:_textField[1].text networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
            @strongify(self);
            if (response.code == 0) {
                //改变登录状态并返回
                [self changeLoginStatewithUsermodel:response.data];
            } else {
                iToastText(response.msg);
            }
            [self loadingSuccess];
        }];
    } else if (button.tag == 104105) {
        // 注册
        @weakify(self);
        RegisterVC *VC = [[RegisterVC alloc]init];
        VC.isRegister = YES;
        VC.isToRootVC = YES;
        VC.finishBlock = ^() {
            @strongify(self);
            // 此处添加线程等待，是为了防止pop过快tabBar点击不了
            [self performBlock:^{
                @strongify(self);
                // 完成注册后跳转到App页面
                [self dismissViewControllerAnimated:YES completion:nil];
            } afterDelay:0.2f];
        };
        [self.navigationController pushViewController:VC animated:YES];
    } else {
        // 忘记密码
        ForgetPasswordVC *VC = [[ForgetPasswordVC alloc]init];
        @weakify(self);
        VC.finishBlock = ^() {
            @strongify(self);
            // 此处添加线程等待，是为了防止pop过快tabBar点击不了
            [self performBlock:^{
                @strongify(self);
                // 完成注册后跳转到App页面
                [self dismissViewControllerAnimated:YES completion:nil];
            } afterDelay:0.2f];
        };
        [self.navigationController pushViewController:VC animated:YES];
    }
}

///登录确认并跳回个人中心
- (void)changeLoginStatewithUsermodel:(UserModel*)userModel {
    userModel.isLogin = YES;
    NSArray *userArray = [UserModel searchWithWhere:[NSString stringWithFormat:@"sid = '%@'", userModel.sid] orderBy:nil offset:0 count:100];
    // 判断数据库中是否有此人登录信息
    if (userArray.count) {
        [userModel updateToDB];
    } else {
        [userModel saveToDB];
    }
    GetDataUserModel = userModel;
    DLog(@"GetDataUserModel:%@", GetDataUserModel);
    // 改变登录状态并保存sid和uid
    kUserDefaults(@"kSid", userModel.sid);
    kUserDefaults(@"kUid", @(userModel.userInfo.uid));
    kSynchronize;
    // 登录成功通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogin object:@{@"chatToken" : userModel.chatToken}];
    [self dismissViewControllerAnimated:YES completion:self.successBlock];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length) {
        if ([_textField[0] isFirstResponder]) {
            // 手机号码长度限制
            return [CommonUtil limitLengthWithInputSource:textField maxLength:kMaxAccountLength];
        }
        if ([_textField[1] isFirstResponder]) {
            // 密码长度限制
            return [CommonUtil limitLengthWithInputSource:textField maxLength:kMaxPasswordLength];
        }
    }
    return YES;
}

@end
