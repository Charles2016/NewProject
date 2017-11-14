//
//  StatusModel.h
//  HKMember
//
//  Created by 文俊 on 14-3-20.
//  Copyright (c) 2014年 CarMango. All rights reserved.
//
#import "BaseModel.h"

@interface StatusModel : BaseModel

@property (nonatomic, copy) NSString *Msg;    // 请求结果提示信息
@property (nonatomic, assign) NSInteger State;   // 状态信息
@property (nonatomic, assign) NSInteger Success;   // 状态码,1代表成功，其他代表失败
@property (nonatomic, assign) BOOL isFromDB;
@property (nonatomic, strong) id Data;

// 提示结果返回
- (id)initWithCode:(NSInteger)code msg:(NSString *)msg;
- (id)initWithError:(NSError*)error;

@end
