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
#define GetDataUid [DataManager sharedManager].userModel.userInfo.uid
#define GetDataUserInfo [DataManager sharedManager].userModel.userInfo

@interface DataManager : NSObject

@property (nonatomic, copy) NSString *cartUrl;// 审核中购物车url
@property (nonatomic, assign) NSInteger browserOpen;// 1审核中 2审核后
@property (nonatomic, strong) UserModel *userModel;

+ (DataManager *)sharedManager;

@end




