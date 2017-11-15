//
//  OpinionModel.h
//  RacingCarLottery
//
//  Created by dary on 2017/4/21.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import "BaseModel.h"

@interface OpinionModel : BaseModel

/**
 *  提交意见接口
 */
+ (NSURLSessionDataTask *)getOpinionWithText:(NSString *)text
                                  networkHUD:(NetworkHUD)hud
                                     success:(NetResponseBlock)success;

@end
