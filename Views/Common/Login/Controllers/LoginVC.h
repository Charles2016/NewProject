//
//  LoginVC.h
//  GoodHappiness
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "SuperVC.h"

@interface LoginVC : SuperScrollVC

@property (nonatomic, copy) void (^successBlock)();

@end
