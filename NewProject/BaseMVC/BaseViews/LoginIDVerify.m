//
//  LoginIDVerify.m
//  GameTerrace
//
//  Created by Charles on 2017/12/13.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import "LoginIDVerify.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation LoginIDVerify

- (void)verify {
    //初始化上下文对象
    LAContext *context = [[LAContext alloc] init];
    //localizedFallbackTitle＝@“”,不会出现“输入密码”按钮
    context.localizedFallbackTitle = @"输入密码";
    //错误对象
    NSError *error = nil;
    NSString *result = @"验证信息";
    
    //判断是否支持密码验证
    /**
     *LAPolicyDeviceOwnerAuthentication 手机密码的验证方式
     *LAPolicyDeviceOwnerAuthenticationWithBiometrics 指纹的验证方式
     */
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:result
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    NSLog(@"success to evaluate");
                                    //do your work
                                }
                                if (error) {
                                    NSLog(@"---failed to evaluate---error: %@---", error.description);
                                    //do your error handle
                                }
                            }];
    } else {
        NSLog(@"==========Not support :%@", error.description);
        //do your error handle
    }
}

@end
