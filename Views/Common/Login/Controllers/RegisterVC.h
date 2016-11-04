//
//  RegisterVC.h
//  GoodHappiness
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "SuperVC.h"

@interface RegisterVC : SuperScrollVC

@property (nonatomic, assign) BOOL isRegister;// YES新手注册 NO完善资料
@property (nonatomic, assign) BOOL isToRootVC;

@property (nonatomic, copy) void (^finishBlock)();

@end
