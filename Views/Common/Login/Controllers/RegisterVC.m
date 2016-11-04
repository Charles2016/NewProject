//
//  RegisterVC.m
//  GoodHappiness
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "RegisterVC.h"
#import "LoginVC.h"

#import "UIButton+WebCache.h"
#import "VerifyButton.h"

@interface RegisterVC () {
    UITextField *_textField[5];
    VerifyButton *_getCode;
    UILabel *_agree;
    UILabel *_invite;
    UILabel *_login;
    UILabel *_codeTip;
    UIImageView *_imageView;
    UIButton *_register;
    UIButton *_arrow;
    UIButton *_imageCode;
}

@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _isRegister ? @"新手注册" : @"完善资料";
    UIImage *image = [UIImage imageNamed:@"register_bg"];
    self.view.layer.contents = (id) image.CGImage;
    [self setUI];
}

- (void)setUI {
    NSString *banners = kGetUserDefaults(@"banners");
    NSString *imageStr = @"";
    NSString *appStr = @"";
    if (banners.length) {
        DeviceModel *model = [DeviceModel mj_objectWithKeyValues:[banners mj_JSONObject]];
        BannersModel *bannersModel = model.banners.count ?  model.banners.firstObject : nil;
        imageStr = bannersModel.imgUrl;
        appStr = bannersModel.appUrl;
    };
    _imageView = InsertImageView(self.view, CGRectMake(0, 0, kScreenWidth, 187), nil);
    [_imageView sd_setImageWithURL:kURLWithString(imageStr) placeholderImage:[UIImage imageNamed:@"loading_default_image"]];
    _imageView.userInteractionEnabled = YES;
    @weakify(self);
    [_imageView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        // 点击活动页banner
        @strongify(self);
        [WebviewController pushToWebViewWithUrl:appStr fromVC:self];
    }];
    
    NSArray *dataArray = @[@"手机号码", @"登录密码", @"验证码", @"手机验证码", @"邀请码"];
    for (int i = 0; i < 5; i++) {
        _textField[i] = InsertTextFieldWithTextColor(self.view, self, CGRectMake(10, _imageView.bottom + 10 + i * (AutoWHGetHeight(38) + 10), kScreenWidth - 20, AutoWHGetHeight(38)), dataArray[i], kFontSize13 , NSTextAlignmentLeft, UIControlContentVerticalAlignmentCenter, kColorBlack);
        _textField[i].keyboardType = (i == 0 || i == 3) ? UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
        _textField[i].leftViewMode = UITextFieldViewModeAlways;
        _textField[i].secureTextEntry = i == 1 ? YES : NO;
        _textField[i].layer.cornerRadius = 10;
        _textField[i].layer.borderWidth = 1;
        _textField[i].clipsToBounds = YES;
        _textField[i].backgroundColor = kColorWhite;
        _textField[i].layer.borderColor = kColorLightgray.CGColor;
        _textField[i].leftView = InsertView(nil, CGRectMake(0, 0, 10, _textField[i].height), kColorWhite);
    }
    
    _textField[2].width = _textField[3].width = kScreenWidth - 20 - 10 - 80;
//    if (_isRegister) {
        // 注册需要图形验证码
        _imageCode = InsertImageButton(self.view, CGRectMake(_textField[2].right + 10, _textField[2].top, 80,  _textField[2].height), 110110, nil, nil, self, @selector(buttonAction:));
        NSDate *date = [NSDate date];
        NSString *dateStr = [TimeUtil getDate:date withFormat:@"yyyyMMddHHmmssSSS"];
        dateStr = [NSString stringWithFormat:@"%@/v2/user/getImgCode?deviceIdentifier=%@&timestamp=%@", kServerHost,kDeviceIdentifier, dateStr];
        [_imageCode sd_setImageWithURL:kURLWithString(dateStr) forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loading_default_image"] options:SDWebImageRefreshCached];
        
        NSString *codeTipStr = @"看不清？点击图片刷新验证码";
        _codeTip = InsertLabel(self.view, CGRectMake(15, _imageCode.bottom, [DataHelper widthWithString:codeTipStr font:kFontSize11], 40), NSTextAlignmentLeft, codeTipStr, kFontSize11, kColorWhite, NO);
        _textField[3].top = _codeTip.bottom;
//    } else {
//       // 完善资料隐藏图形验证码相关信息
//        _textField[2].hidden = YES;
//        _textField[3].top = _textField[2].top;
//    }
    
    _getCode = [[VerifyButton alloc]initWithFrame:CGRectMake(_textField[3].right + 10, _textField[3].top, 80,  _textField[3].height)];
    _getCode.tag = 108241;
    [_getCode addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_getCode];
    
     NSString *inviteStr = @"添加邀请码，帮助好友赚取收益";
    _invite = InsertLabel(self.view, CGRectMake(15, _textField[3].bottom, [DataHelper widthWithString:inviteStr font:kFontSize11], 40), NSTextAlignmentLeft, inviteStr, kFontSize11, kColorWhite, NO);
    _textField[4].top = _invite.bottom;
    
    UIImage *image = [UIImage imageNamed:@"register_arrow_down"];
    _arrow = InsertButtonWithType(self.view,  CGRectMake(_invite.right + 2, 0, image.size.width,  image.size.height), 108240, self, @selector(buttonAction:), UIButtonTypeCustom);
    [_arrow setBackgroundImage:image forState:UIControlStateNormal];
    [_arrow setBackgroundImage:[UIImage imageNamed:@"register_arrow_up"] forState:UIControlStateSelected];
    _arrow.touchAreaInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    _arrow.centerY = _invite.centerY;
    
    NSString *agreeColorStr = @"扑多协议";
    NSString *agreeStr = [NSString stringWithFormat:@"已经阅读并同意《%@》", agreeColorStr];
    _agree = InsertLabel(self.view, CGRectMake(_invite.left, _textField[4].bottom, [DataHelper widthWithString:inviteStr font:kFontSize11], 40), NSTextAlignmentLeft, agreeStr, kFontSize11, kColorWhite, NO);
    _agree.attributedText = [DataHelper getColorsInLabel:agreeStr colorStrs:@[agreeColorStr] colors:@[UIColorHex(0xb8d6ff)] fontSizes:@[@11]];
    _agree.userInteractionEnabled = YES;
    [_agree addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        // 点击服务协议按钮
        @strongify(self);
        [WebviewController pushToWebViewWithUrl:[NSString stringWithFormat:@"%@v1/login/serveclause", kH5HostURL] fromVC:self];
    }];
    
    if (_isRegister) {
        NSString *loginColorStr = @"立即登录";
        NSString *loginStr = [NSString stringWithFormat:@"已注册，%@", loginColorStr];
        CGFloat width = [DataHelper widthWithString:inviteStr font:kFontSize11];
        _login = InsertLabel(self.view, CGRectMake(kScreenWidth - 15 - width, _agree.top, width, 40), NSTextAlignmentRight, loginStr, kFontSize11, kColorWhite, NO);
        _login.attributedText = [DataHelper getColorsInLabel:loginStr colorStrs:@[loginColorStr] colors:@[UIColorHex(0xf3ee64)] fontSizes:@[@11]];
        _login.userInteractionEnabled = YES;
        [_login addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            @strongify(self);
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController isKindOfClass:[LoginVC class]]) {
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
            }
            LoginVC *VC = [[LoginVC alloc]init];
            [self.navigationController pushViewController:VC animated:YES];
        }];
    }
    
    _register = InsertButtonWithType(self.view,  CGRectMake(15, _agree.bottom + 5, kScreenWidth - 30, AutoWHGetHeight(40)), 108242, self, @selector(buttonAction:), UIButtonTypeCustom);
    _register.titleLabel.font = kFontSize20;
    _register.layer.cornerRadius = 8;
    _register.layer.borderWidth = 3;
    _register.clipsToBounds = YES;
    _register.layer.borderColor = kColorBlack.CGColor;
    [_register setTitle:_isRegister ? @"立即注册领取红包" : @"完善资料领取红包" forState:UIControlStateNormal];
    [_register setTitleColor:kColorBlack forState:UIControlStateNormal];
    [_register setBackgroundColor:kColorNavBground forState:UIControlStateNormal];
}

#pragma mark - privateMethod
- (void)buttonAction:(UIButton *)button {
    [self.view endEditing:YES];
    if (button.tag == 108240) {
        button.selected = !button.selected;
        [UIView animateWithDuration:0.5 animations:^{
            if (button.selected) {
                _textField[4].hidden = YES;
                _textField[4].height = 0;
                _login.top = _agree.top = _invite.bottom - 20;
                _register.top = _agree.bottom + 5;
            } else {
                _textField[4].hidden = NO;
                _textField[4].height = _textField[0].height;
                _login.top = _agree.top = _textField[4].bottom;
                _register.top = _agree.bottom + 5;
            }
            // 刷新界面滑动高度
            [self.scrollTableView reloadData];
        }];
    } else if (button.tag == 108241 || button.tag == 108242) {
        NSString *mobile = _textField[0].text;
        NSString *password= _textField[1].text;
        NSString *imageCode = _textField[2].text;
        NSString *code = _textField[3].text;
        NSString *inviteCode = _textField[4].text;
        if (!mobile.length) {
            iToastText(@"请输入手机号码");
            return;
        }
        if (!imageCode.length) {
            iToastText(@"请输入图片验证码");
            return;
        }
        @weakify(self);
        if (button.tag == 108241) {
            // 开启计时器
            [_getCode timerStart];
            [self loadingStartBgClear];
            [UserModel getverificationCodeWithMobile:mobile imageCode:imageCode networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
                UserModel *userModel = (UserModel *)response.data;
                if (response.code == 0) {
                    DLog(@"验证码：%ld", userModel.code);
                } else {
                    iToastText(response.msg);
                }
                @strongify(self);
                [self loadingSuccess];
            }];
        } else {
            if (!password.length) {
                iToastText(@"请输入登录密码");
            }
            if (!code.length) {
                iToastText(@"请输入手机短信验证码");
                return;
            }
            // 完成注册
            [self loadingStartBgClear];
            [UserModel getRegisterWithMobile:mobile password:password code:code inviteCode:inviteCode isRegister:_isRegister networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
                @strongify(self);
                [self registerOrChangePassWordFinishWithModel:response isRegister:YES];
            }];
        }
    } else if (button.tag == 110110) {
        NSDate *date = [NSDate date];
        NSString *dateStr = [TimeUtil getDate:date withFormat:@"yyyyMMddHHmmssSSS"];
        dateStr = [NSString stringWithFormat:@"%@/v2/user/getImgCode?deviceIdentifier=%@&timestamp=%@", kServerHost,kDeviceIdentifier, dateStr];
         [_imageCode sd_setImageWithURL:kURLWithString(dateStr) forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loading_default_image"] options:SDWebImageRefreshCached];
    }
}

- (void)registerOrChangePassWordFinishWithModel:(StatusModel *)response isRegister:(BOOL)isRegister {
    if (response.code == 0) {
        UserModel *userModel = (UserModel *)response.data;
        // 注册完成or完善个人资料完成更新状态
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
        [self dismissViewControllerAnimated:YES completion:nil];
        for (UIViewController *viewController in self.navigationController.viewControllers) {
            if ([viewController isKindOfClass:[self class]]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
//        if (_isToRootVC) {
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        } else {
//            for (UIViewController *viewController in self.navigationController.viewControllers) {
//                if ([viewController isKindOfClass:[LoginVC class]]) {
//                    [self.navigationController popViewControllerAnimated:YES];
//                }
//            }
//        }
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
    if ([_textField[0] isFirstResponder]) {
        if (string.length) {
            // 手机号码长度限制
            return [CommonUtil limitLengthWithInputSource:textField maxLength:kMaxAccountLength];
        }
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _register.bottom + 15 > kBodyHeight ? _register.bottom + 15 : 0;
}

@end
