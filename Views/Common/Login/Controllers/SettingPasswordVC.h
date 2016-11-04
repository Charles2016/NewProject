//
//  SettingPasswordVC.h
//  GoodHappiness
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "SuperVC.h"

@interface SettingPasswordVC : SuperVC

// 因为找回密码和注册的设置密码页面都差不多，所以公用，标志区分
@property (nonatomic, assign) BOOL isForgetStyle;
@property (nonatomic, copy) NSString *phoneNumeber;
@property (nonatomic, copy) NSString *verificationCode;
@property (nonatomic, copy) void (^finishBlock)();

@end
