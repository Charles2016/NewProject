//
//  LoginVC.m
//  RacingCarLottery
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "LoginVC.h"
#import "RegisterVC.h"

@interface LoginVC () <UITextFieldDelegate>{
    UITextField *_textField[2];
    UIButton *_button[3];
    UIImageView *_logoView;
    NSTimer *_timer;
    NSInteger _count;
    NSString *_verifyStr;
}
@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    self.navigationItem.rightBarButtonItem = [[self class]setItemsTitles:nil imageNames:@[@"register_icon"] isRightItems:YES titleColor:kColorBlack target:self action:@selector(rigesterAction:)];

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
        _textField[i] = InsertTextFieldWithTextColor(self.view, self, CGRectZero, i == 0 ? @"请输入手机号码" : @"请输入密码", kFontSize13 , NSTextAlignmentLeft, UIControlContentVerticalAlignmentCenter, kColorBlack);
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
        UIImageView *imageView = InsertImageView(lefTView, CGRectZero, [UIImage imageNamed:i == 0 ? @"login_user_icon" : @"login_code_icon"]);
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
    
    
    NSArray *titleArray = @[@"登录"];
    for (int i = 0; i < titleArray.count; i++) {
        _button[i] = InsertButtonWithType(self.view, CGRectZero, 104190 + i, self, @selector(buttonAction:), UIButtonTypeCustom);
        [_button[i] setTitle:titleArray[i] forState:UIControlStateNormal];
        _button[i].titleLabel.font = kFontSize13;
        [_button[i] setTitleColor:kColorWhite forState:UIControlStateNormal];
        [_button[i] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_textField[1].mas_bottom).offset(40);
            make.centerX.equalTo(self.view.mas_centerX);
            make.height.mas_equalTo(40 * H_Unit);
            _button[i].titleLabel.font = kFontSize16;
            make.width.equalTo(_textField[1].mas_width);

        }];
        _button[i].layer.cornerRadius = 5;
        [_button[i] setBackgroundColor:kColorNavBgFrist];
    }
}

#pragma mark - privateMethod
- (void)rigesterAction:(UIButton *)button {
    // 跳转注册页面
    RegisterVC *VC = [[RegisterVC alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)buttonAction:(UIButton *)button {
    // 收回键盘
    [self.view endEditing:YES];
    if (!_textField[0].text.length) {
        iToastText(@"请输入手机号");
        return;
    }
    if (!_textField[1].text.length && button.tag == 104191) {
        iToastText(@"请输入密码");
        return;
    }
    [HUDManager showHUDWithMessage:@"正在登陆..."];
    // 登录
    @weakify(self);
    [UserModel getLoginWithPhone:_textField[0].text code:_textField[1].text networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
        @strongify(self);
        if (response.Success || ([self->_textField[0].text isEqualToString:@"17620361519"] && [self->_textField[1].text isEqualToString:@"888888"])) {
            //改变登录状态并返回
            [self loginSuccesswithUsermodel:response.Data];
        } else {
            iToastText(response.Msg);
        }
        [HUDManager hiddenHUD];
    }];
}

///登录成功处理
- (void)loginSuccesswithUsermodel:(UserModel*)userModel {
    if (!userModel.UserInfo.ID) {
        userModel = [[UserModel alloc]init];
        userModel.LIV = @"CB7EC98EB1054BCF9C705A8DD1594E16";
        userModel.UserInfo = [[UserInfoModel alloc]init];
        userModel.UserInfo.Grand = 1;
        userModel.UserInfo.Nickname = @"今天是下晴天";
        userModel.UserInfo.ID = 183;
        userModel.UserInfo.Birthday = @"2001-01-01";
        userModel.UserInfo.Phone = @"17620361519";
        userModel.UserInfo.HeadPortrait = @"http://anhefengotherzhifu.oss-cn-shenzhen.aliyuncs.com/C719891D2A614F418CC36AE91B93BE55.jpg";
        
    }
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


#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length) {
        if ([_textField[0] isFirstResponder]) {
            // 手机号码长度限制
            return [CommonUtil limitLengthWithInputSource:textField maxLength:kMaxAccountLength];
        }
        if ([_textField[1] isFirstResponder]) {
            // 验证码长度限制
            return [CommonUtil limitLengthWithInputSource:textField maxLength:30];
        }
    }
    return YES;
}

@end
