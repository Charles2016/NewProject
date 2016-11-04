//
//  UUID.m
//  GoodHappiness
//
//  Created by chaolong on 16/4/11.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "UUID.h"
#import "KeyChainStore.h"

@implementation UUID

+(NSString *)getUUID {
    NSString * strUUID = (NSString *)[KeyChainStore load:kUserName_Password];
    //首次执行该方法时，uuid为空
    if ([strUUID isEqualToString:@""] || !strUUID) {
        //生成一个uuid的方法
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        //将该uuid保存到keychain
        [KeyChainStore save:kUserName_Password data:strUUID];
    }
    return strUUID;
}



@end
