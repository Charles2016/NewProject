//
//  AboutUsVC.m
//  GoodHappiness
//
//  Created by chaolong on 16/6/23.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "AboutUsVC.h"

@interface AboutUsVC () {
    NSInteger _tapCount;
}

@end

@implementation AboutUsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _tapCount = 0;
    
    self.view.backgroundColor = kColorBgWhite;
    self.navigationItem.title = @"关于我们";
    [self setUI];
}

- (void)setUI {
    UIImageView *imageView = InsertImageView(self.view, CGRectZero, [UIImage imageNamed:@"about_us_image"]);
    imageView.frame = CGRectMake((kScreenWidth - imageView.image.size.width) / 2, 69, imageView.image.size.width, imageView.image.size.height);
    
    // 测试环境下，点5下显示网络选择选项
    @weakify(self);
    [imageView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        self->_tapCount++;
        if (self->_tapCount >= 5) {
            self->_tapCount = 0;
            [self showNetWorkAlertView];
        }
    }];
    
    InsertLabel(self.view, CGRectMake(0, imageView.bottom, kScreenWidth, 54), NSTextAlignmentCenter, @"mypuduo.com", kFontSize14, kColorDarkgray, NO);
    
    NSString *versionStr = [NSString stringWithFormat:@"版本号：v%@", GetCurrentVersion];
    InsertLabel(self.view, CGRectMake(0, kBodyHeight - 55, kScreenWidth, 20), NSTextAlignmentCenter, versionStr, kFontSize9, kColorLightBlack, NO);
    InsertLabel(self.view, CGRectMake(0, kBodyHeight - 35, kScreenWidth, 20), NSTextAlignmentCenter, @"-深圳好幸福科技有限公司版权所有-", kFontSize10, kColorLightBlack, NO);
}

// 显示选择网络选项
- (void)showNetWorkAlertView {
    NSString *currentStr = [NetConfigure getCurrentNetwork];
    
    NSString *testStr = [NSString stringWithFormat:@"测试环境：%@", [NetConfigure getNetworkWithStyle:NetCfgTypeTest]];
    NSString *tureStr = [NSString stringWithFormat:@"正式环境：%@", [NetConfigure getNetworkWithStyle:NetCfgTypeTrue]];
    [HXFAlertView actionSheetWithTitle:@"确定要切换环境吗？" message: [NSString stringWithFormat:@"此功能为隐藏测试功能，请谨慎使用！不要对外人道也。如果被你发现了，说明你准备中奖了，欢迎加入测试。当前环境：%@" ,currentStr] cancelButton:@"取消" otherButtons:@[testStr, tureStr] otherColor:kColorLightRed alertViewType:AlertViewSheetFull complete:^(NSInteger buttonIndex) {
        if (buttonIndex == 1 || buttonIndex == 2) {
            [NetConfigure setNetCfgType:buttonIndex == 1 ? NetCfgTypeTest : NetCfgTypeTrue];
            [self exitAPP];
        }
    }];
}

// 退出APP
- (void)exitAPP {
    NSArray *userArray = [UserModel searchWithWhere:nil orderBy:nil offset:0 count:100];
    for (UserModel *userModel in userArray) {
        if (userModel.isLogin) {
            userModel.isLogin = NO;
            [userModel updateToDB];
            break;
        }
    }
    GetDataUserModel.isLogin = NO;
    kUserDefaults(@"kSid", @"");
    kUserDefaults(@"kUid", @(0));
    kUserDefaults(@"kCarNum", @"");
    kSynchronize;
    [self performAfter:5.0f block:^{
        exit(0);
    }];
}

@end
