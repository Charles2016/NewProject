//
//  NetConfigure.m
//  PinMall
//
//  Created by YangXu on 14/12/29.
//  Copyright (c) 2014年 365sji. All rights reserved.
//

#import "NetConfigure.h"

static NSString *const keyNetwork = @"NetworkType";

/// 测试环境
#define NetworkTest @"http://192.168.0.158:155/api/"
#define kTestH5BaseURL @"http://yctc.anhefeng.com/api/"

/// 正式环境
#define NetworkTrue @"http://yctc.anhefeng.com/api/"
#define kTureH5BaseURL @"http://wx.CarMango.com/"

@implementation NetConfigure

/// 获取当前网络环境
+ (NSString *)getCurrentNetwork {
    return 1 ? NetworkTrue : NetworkTest;
}

/// 返回当前网络环境配置下的H5的URL
+ (NSString *)getCurrentH5BaseURLString {
    return isTrueEnvironment ? kTestH5BaseURL : kTureH5BaseURL;
}

@end
