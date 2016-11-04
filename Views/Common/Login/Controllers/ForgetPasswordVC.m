//
//  ForgetPasswordVC.m
//  GoodHappiness
//
//  Created by Charles on 4/11/16.
//  Copyright © 2016 Charles. All rights reserved.
//

#import "ForgetPasswordVC.h"
#import "GetVerificationVC.h"

#import "UIButton+WebCache.h"

@interface ForgetPasswordVC () {
    UITextField *_number;
    UITextField *_imageCode;
    UIButton *_imageButton;
    BOOL _isNeedRefresh;// 进入下一页面后刷新图片验证码
}

@end

@implementation ForgetPasswordVC

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_number becomeFirstResponder];
    if (_isNeedRefresh) {
        _isNeedRefresh = NO;
        _imageCode.text = nil;
        [self buttonAction:_imageButton];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"忘记密码";
    self.view.backgroundColor = kColorWhite;
    [self setUI];
}

- (void)setUI {
    _number = InsertTextFieldWithBorderAndCorRadius(self.view, self, CGRectMake(15, 15, kScreenWidth - 30, AutoWHGetHeight(30)), @"请输入手机号码", kFontSize13, NSTextAlignmentLeft, UIControlContentVerticalAlignmentCenter, 0.5, kColorLightBlack, kColorBlack, 5.0);
    _number.keyboardType = UIKeyboardTypeNumberPad;
    _number.leftViewMode = UITextFieldViewModeAlways;
    _number.leftView = InsertView(nil, CGRectMake(0, 0, 10, _number.height), kColorWhite);
    
    _imageCode = InsertTextFieldWithBorderAndCorRadius(self.view, self, CGRectMake(15, _number.bottom + (AutoWHGetHeight(38) + 10 - _number.height) / 2, _number.width - 90, _number.height), @"请输入图片验证码", kFontSize13, NSTextAlignmentLeft, UIControlContentVerticalAlignmentCenter, 0.5, kColorLightBlack, kColorBlack, 5.0);
    _imageCode.leftViewMode = UITextFieldViewModeAlways;
    _imageCode.leftView = InsertView(nil, CGRectMake(0, 0, 10, _number.height), kColorWhite);
    
    // 注册需要图形验证码
    _imageButton = InsertImageButton(self.view, CGRectMake(_imageCode.right + 10, _number.bottom + 5, 80,  AutoWHGetHeight(38)), 110180, nil, nil, self, @selector(buttonAction:));
    NSDate *date = [NSDate date];
    NSString *dateStr = [TimeUtil getDate:date withFormat:@"yyyyMMddHHmmssSSS"];
    dateStr = [NSString stringWithFormat:@"%@/v2/user/getImgCode?deviceIdentifier=%@&timestamp=%@", kServerHost,kDeviceIdentifier, dateStr];
    [_imageButton sd_setImageWithURL:kURLWithString(dateStr) forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loading_default_image"] options:SDWebImageRefreshCached];
    
    UIButton *getCode = InsertButtonWithType(self.view, CGRectMake(_number.left, _imageButton.bottom + 15, _number.width, _number.height), 1095, self, @selector(buttonAction:), UIButtonTypeCustom);
    [getCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    getCode.titleLabel.font = kFontSize13;
    [getCode setTitleColor:kColorBlack forState:UIControlStateNormal];
    [getCode setBackgroundImage:kButtonImage(@"button_image_yellow") forState:UIControlStateNormal];
}

#pragma mark - privateMethod
- (void)buttonAction:(UIButton *)button {
    if (button.tag == 110180) {
            NSDate *date = [NSDate date];
            NSString *dateStr = [TimeUtil getDate:date withFormat:@"yyyyMMddHHmmssSSS"];
            dateStr = [NSString stringWithFormat:@"%@/v2/user/getImgCode?deviceIdentifier=%@&timestamp=%@", kServerHost,kDeviceIdentifier, dateStr];
            [_imageButton sd_setImageWithURL:kURLWithString(dateStr) forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loading_default_image"] options:SDWebImageRefreshCached];
    } else {
        if (!_number.text.length) {
            iToastText(@"请输入手机号");
            return;
        }
        if (!_imageCode.text.length) {
            iToastText(@"请输入图片验证码");
            return;
        }
        [self.view endEditing:YES];
        [self loadingStartBgClear];
        [UserModel getverificationCodeWithMobile:_number.text imageCode:_imageCode.text networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
            UserModel *userModel = (UserModel *)response.data;
            if (response.code == 0) {
                DLog(@"验证码：%ld", userModel.code);
                [self pushToGetVerificationVCWithCode:kIntToStr(userModel.code)];
            } else {
                iToastText(response.msg);
            }
            [self loadingSuccess];
        }];
    }
}

#pragma mark - loadData
- (void)pushToGetVerificationVCWithCode:(NSString *)code {
    _isNeedRefresh = YES;
    GetVerificationVC *VC = [[GetVerificationVC alloc]init];
    VC.phoneNumber = _number.text;
    VC.code = code;
    VC.isForgetStyle = YES;
    VC.finishBlock = _finishBlock;
    [self.navigationController pushViewController:VC  animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length) {
        // 手机号码长度限制
        return [CommonUtil limitLengthWithInputSource:textField maxLength:kMaxAccountLength];
    }
    return YES;
}

@end
