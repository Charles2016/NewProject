//
//  HomeModel.m
//  CarMango
//
//  Created by Charles on 4/17/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "HomeModel.h"

@implementation HomeModel

+ (NSDictionary *)objectClassInArray {
    return @{@"PanicBuying" : @"ButtonModel",
             @"Banner" : @"ButtonModel",
             @"Button" : @"ButtonModel",
             @"Value" : @"ButtonModel",
             @"Data" : @"ButtonModel",
             @"Recommend" : @"RecommendModel"};
}

/**
 *  首页数据接口
 */
+ (NSURLSessionDataTask *)getHomeDataWithNetworkHUD:(NetworkHUD)hud
                                             target:(id)target
                                            success:(NetResponseBlock)success {
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"Home/QueryIndexInfo" params:nil networkHUD:hud target:target success:success];
}

/**
 *  获取广告列表
 */
+ (NSURLSessionDataTask *)getADListWithPages:(NSInteger)Pages
                                  networkHUD:(NetworkHUD)hud
                                        target:(id)target
                                        success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(@(Pages), @"PageIndex");
    DicValueSet(@(kPageSize), @"PageSize");
     return [[self class] dataTaskMethod:HTTPMethodPOST path:@"Home/QueryIndexBottom" params:ParamsDic networkHUD:hud target:target success:success];
}

/**
 *  获取大牌登场列表
 */
+ (NSURLSessionDataTask *)getBingProductListWithPages:(NSInteger)Pages
                                           networkHUD:(NetworkHUD)hud
                                               target:(id)target
                                              success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(@(Pages), @"PageIndex");
    DicValueSet(@(kPageSize), @"PageSize");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"Home/QueryBigBrand" params:ParamsDic networkHUD:hud target:target success:success];
}

@end
