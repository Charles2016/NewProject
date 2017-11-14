//
//  NickNameVC.m
//  CarMango
//
//  Created by chaolong on 16/4/13.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "NickNameVC.h"

@interface NickNameVC ()<UITextFieldDelegate> {
    UITextField *_nickname;
}

@end

@implementation NickNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"昵称";
    self.navigationItem.rightBarButtonItem.customView.hidden = YES;
    self.view.backgroundColor = kColorViewBg;
    [self setUI];
}

- (void)setUI {
    _nickname = InsertTextField(self.view, self, CGRectMake(0, 0, kScreenWidth, 50), @"", kFontSize13, NSTextAlignmentLeft, UIControlContentVerticalAlignmentCenter);
    _nickname.leftView = InsertView(nil, CGRectMake(0, 0, 10, _nickname.height), kColorWhite);
    _nickname.leftViewMode = UITextFieldViewModeAlways;
    _nickname.clearButtonMode = UITextFieldViewModeAlways;
    _nickname.textColor = kColorBlack;
    _nickname.placeholder = @"请输入您的昵称";
    if (GetDataUserInfo.Nickname.length) {
        _nickname.text = GetDataUserInfo.Nickname;
    }
    _nickname.backgroundColor = kColorWhite;
    
    UIButton *save = InsertButtonWithType(self.view, CGRectZero, 104213, self, @selector(saveAction:), UIButtonTypeCustom);
    [save setTitle:@"保存" forState:UIControlStateNormal];
    [save setBackgroundColor:kColorNavBgFrist];
    save.layer.cornerRadius = 5;
    [save mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nickname.mas_bottom).offset(80);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view).offset(-40);
        make.height.mas_equalTo(40 * H_Unit);
    }];
    
    // 监控输入栏长度通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange) name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma - mark praviteMethod
- (void)saveAction:(UIButton *)button {
    NSInteger length = [CommonUtil unicodeLengthOfString:_nickname.text isAll:YES];
    if (length < kMinNicknameLength) {
        iToastText(@"昵称最小长度为4个字符哦");
        return;
    }
    button.userInteractionEnabled = NO;
    if ([GetDataUserInfo.Nickname isEqual:_nickname.text]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    @weakify(self);
    [UserInfoModel changeUserInfoWithKey:@"NickName" value:_nickname.text networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
        @strongify(self);
        if (response.Success) {
            GetDataUserInfo.Nickname = self->_nickname.text;
            [GetDataUserInfo updateToDB];
            [self backToSuperView];
        } else {
            iToastText(response.Msg);
        }
        button.userInteractionEnabled = YES;
    }];
}

- (void)textFieldChange {
    self.navigationItem.rightBarButtonItem.customView.hidden = (_nickname.text.length > 0 && ![_nickname.text isEqualToString:@""])? NO : YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (string.length) {
        if ([_nickname isFirstResponder]) {
            // 手机号码长度限制
            return [CommonUtil limitLengthWithInputSource:textField maxLength:kMaxNicknameLength];
        }
    }
    return YES;
}

@end
