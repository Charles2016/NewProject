//
//  AppDelegate+LibraryConfig.m
//  GameTerrace
//
//  Created by Charles on 4/18/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "AppDelegate+LibraryConfig.h"

@implementation AppDelegate (LibraryConfig)

- (void)setupLibraryConfigWith:(UIApplication *)application options:(NSDictionary *)launchOptions {
    // app引导页
    if (@available(iOS 11, *)) {
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    // 监控网络变化
    [self getNetworkInfo];
    
    // 版本更新
}


#pragma mark - privateMethod
- (void)getNetworkInfo {
    // 监控网络变化block status-1未知网络 0无网络 1蜂窝网络 2WiFi网络
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSString *tipStr;
        switch (status) {
            case -1:
                tipStr = @"未知网络";
                break;
            case 0:
                tipStr = @"无网络";
                break;
            case 1:
                tipStr = @"蜂窝网络";
                break;
            case 2:
                tipStr = @"WiFi";
                break;
        }
        DLog(@"手机网络发生变化：%@", tipStr);
    }];
}

@end

