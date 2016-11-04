//
//  PhoneCallViewController.h
//  打电话后返回程序
//  Created by Long on 14-7-22.
//  Copyright (c) 2014年 Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneCall : NSObject

+ (BOOL)callPhoneNumber:(NSString *)phoneNumber
                   call:(void(^)(NSTimeInterval duration))callBlock
                 cancel:(void(^)())cancelBlock;

@end
