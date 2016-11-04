//
//  NetConfigure.m
//  PinMall
//
//  Created by YangXu on 14/12/29.
//  Copyright (c) 2014年 365sji. All rights reserved.
//

#import "NetConfigure.h"

/// 测试环境
#define NetworkTest @"http://apiv2.hxfapp.com"
#define kTestH5BaseURL  @"http://wx.hxfapp.com/"

/// 正式环境
#define NetworkTrue @"http://apiv2.mypuduo.com"
#define kTureH5BaseURL  @"http://wx.mypuduo.com/"

/// 与NetCfgType顺序一致
#define NetworkEnviroments      @[NetworkTest, NetworkTrue]
#define kH5BaseEnviroments      @[kTestH5BaseURL, kTureH5BaseURL]



@implementation NetConfigure

+ (void)initNetConfigure {
    // 如果app内有保留网络环境取之，若无则根据是否是发布环境来设置网络
    if (!kNetworkType) {
        [self setNetCfgType:isTrueEnvironment ? NetCfgTypeTrue : NetCfgTypeTest];
    }
}

/// 设置网络环境
+ (void)setNetCfgType:(NetCfgType)type {
    kUserDefaults(@"kNetworkType", @(type));
    kSynchronize;
}

/// 获取网络环境
+ (NetCfgType)getNetCfgType {
    NetCfgType defaultType = NetCfgTypeTest;
    if ([kNetworkType integerValue]) {
        defaultType = NetCfgTypeTrue;
    }
    return defaultType;
}

/// 获取当前网络环境
+ (NSString *)getCurrentNetwork {
    return NetworkEnviroments[[self getNetCfgType]];
}

/// 返回当前网络环境配置下的H5的URL
+ (NSString *)getCurrentH5BaseURLString {
    return kH5BaseEnviroments[[self getNetCfgType]];
}

/// 获取指定网络环境
+ (NSString *)getNetworkWithStyle:(NetCfgType)type {
    return NetworkEnviroments[type];
}


@end
