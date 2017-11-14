//
//  iToast+Category.m
//  HKIMDemo
//
//  Created by Charles on 15/10/19.
//  Copyright © 2015年 HuiKaSJi. All rights reserved.
//

#import "iToast+Category.h"

static iToast *staticIToast; // 定义表态变量 

@implementation iToast (Category)

// 实例化iToast
+ (iToast *)alertWithTitle:(NSString *)title
{
    if (!title.length) {
        return nil;
    }
    staticIToast = [iToast makeText:title];
//    [iToastSettings getSharedSettings].postition = CGPointMake(kScreenWidth, 120);
//    [staticIToast setGravity:iToastGravityTop
//                  offsetLeft:0
//                   offsetTop:120];
    [staticIToast show];
    return staticIToast;
}

+ (iToast *)alertWithTitleCenter:(NSString *)title {
    if (!title.length) {
        return nil;
    }
    staticIToast = [iToast makeText:title ];
    [iToastSettings getSharedSettings].postition = CGPointMake(kScreenWidth, 120);
    [staticIToast setGravity:iToastGravityCenter
                  offsetLeft:0
                   offsetTop:120];
    [staticIToast show];
    return staticIToast;
    
    
}

+ (iToast *)alertWithTitleBottom:(NSString *)title {
    staticIToast = [iToast makeText:title ];
    [iToastSettings getSharedSettings].postition = CGPointMake(kScreenWidth, 0);
    [staticIToast setGravity:iToastGravityBottom
                  offsetLeft:0
                   offsetTop:0];
    [staticIToast show];
    return staticIToast;
}

//显示iToast自定义位置和时间
+ (iToast *)alertWithTitle:(NSString *)title gravity:(iToastGravity)gravity duration:(NSInteger)duration {
    if (!title.length) {
        return nil;
    }
    staticIToast = [iToast makeText:title];
    [iToastSettings getSharedSettings].postition = CGPointMake(kScreenWidth, 120);
    [staticIToast setGravity:gravity
                  offsetLeft:0
                   offsetTop:120];
    [staticIToast setDuration:duration];
    [staticIToast show];
    return staticIToast;
}

@end
