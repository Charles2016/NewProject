//
//  NetConfigure.h
//  PinMall
//
//  Created by YangXu on 14/12/29.
//  Copyright (c) 2014年 365sji. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NetCfgType) {
    NetCfgTypeTest = 0,    // 测试
    NetCfgTypeTrue,    // 正式
};

@interface NetConfigure : NSObject

/// 初始化网络环境，需在程序启动前调用
+(void)initNetConfigure;
/// 设置网络环境
+ (void)setNetCfgType:(NetCfgType)type;
/// 获取当前网络环境设置
+ (NSString *)getCurrentNetwork;
/// 返回当前网络环境配置下的H5的URL
+ (NSString *)getCurrentH5BaseURLString;
/// 获取指定网络环境
+ (NSString *)getNetworkWithStyle:(NetCfgType)type;

@end
