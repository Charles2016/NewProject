//
//  OpinionModel.m
//  RacingCarLottery
//
//  Created by dary on 2017/4/21.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import "OpinionModel.h"

@implementation OpinionModel

/**
 *  提交意见接口
 */
+ (NSURLSessionDataTask *)getOpinionWithText:(NSString *)text
                                  networkHUD:(NetworkHUD)hud
                                     success:(NetResponseBlock)success {
    
    CreateParamsDic;
    DicValueSet(text, @"Content");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"user/SubmitFeedback" params:ParamsDic networkHUD:hud success:success];
}

@end
