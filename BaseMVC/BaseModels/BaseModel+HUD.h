//
//  BaseModel+HUD.h
//  HuiXin
//
//  Created by 文俊 on 15/11/6.
//  Copyright © 2015年 mypuduo. All rights reserved.
//

#import "BaseModel.h"

@interface BaseModel (HUD)

/**
 * 开始网络请求HUD处理
 * @param networkHUD HUD状态
 */
+ (void)startHUD:(NetworkHUD)networkHUD target:(id)target;

/**
 *  显示HUD状态
 *  @param response   response字典对象
 *  @param networkHUD HUD状态
 */
+ (void)handleResponse:(StatusModel *)statusModel
            networkHUD:(NetworkHUD)networkHUD;

@end
