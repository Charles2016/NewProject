//
//  DataManager.m
//  YueDian
//
//  Created by xiao on 15/3/6.
//  Copyright (c) 2015年 xiao. All rights reserved.
//

#import "DataManager.h"

@interface DataManager ()

@end

@implementation DataManager

+ (DataManager *)sharedManager{
    static DataManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[DataManager alloc] init];
        assert(sharedManager != nil);
    });
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
        NSArray *userArray = [UserModel searchWithWhere:[NSString stringWithFormat:@"sid = '%@'", kSid] orderBy:nil offset:0 count:100];
        for (UserModel *userModel in userArray) {
            if (userModel.isLogin) {
                self.userModel = userModel;
                break;
            }
        }
    }
    return self;
}

@end
