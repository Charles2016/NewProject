//
//  StatusModel.h
//  HKMember
//
//  Created by 文俊 on 14-3-20.
//  Copyright (c) 2014年 mypuduo. All rights reserved.
//
#import "BaseModel.h"

@interface StatusModel : BaseModel

@property (nonatomic, copy) NSString *msg;    // 请求结果提示信息
@property (nonatomic, copy) NSString *status;   // 状态信息
@property (nonatomic, assign) NSInteger code;   // 状态码,0代表成功，其他代表失败
@property (nonatomic, assign) BOOL isFromDB;
@property (nonatomic, strong) id data;

// 提示结果返回
- (id)initWithCode:(NSInteger)code msg:(NSString *)msg;
- (id)initWithError:(NSError*)error;

@end
