//
//  GetVerificationVC.h
//  GoodHappiness
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "SuperVC.h"

@interface GetVerificationVC : SuperScrollVC

// 因为登录和忘记密码获取验证码页面都一样，所以公用，标志区分
@property (nonatomic, assign) BOOL isForgetStyle;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *code;// 验证码
@property (nonatomic, copy) void (^finishBlock)();

@end
