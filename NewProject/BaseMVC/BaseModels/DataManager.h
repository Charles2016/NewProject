//
//  DataManager.h
//  YueDian
//
//  Created by xiao on 15/3/6.
//  Copyright (c) 2015年 xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define GetDataManager [DataManager sharedManager]
#define GetDataUserModel [DataManager sharedManager].userModel
#define GetDataUserInfo [DataManager sharedManager].userModel.UserInfo

@interface DataManager : NSObject

@property (nonatomic, strong) UserModel *userModel;

+ (DataManager *)sharedManager;

@end




