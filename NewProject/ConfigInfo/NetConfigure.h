//
//  NetConfigure.h
//  PinMall
//
//  Created by YangXu on 14/12/29.
//  Copyright (c) 2014年 365sji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetConfigure : NSObject

/// 返回当前API网络
+ (NSString *)getCurrentNetwork;
/// 返回当前网络环境配置下的H5的URL
+ (NSString *)getCurrentH5BaseURLString;

@end
