//
//  PayModel.h
//  GoodHappiness
//
//  Created by chaolong on 16/4/14.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "BaseModel.h"

@interface PayModel : BaseModel
// 微信支付参数
@property (nonatomic, copy) NSString *sign;
@property (nonatomic, copy) NSString *partnerid;
@property (nonatomic, copy) NSString *package;
@property (nonatomic, copy) NSString *noncestr;
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, copy) NSString *appid;
@property (nonatomic, copy) NSString *prepayid;

// 支付宝支付参数
@property (nonatomic, copy) NSString *alipay;

@end
