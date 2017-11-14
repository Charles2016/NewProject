//
//  HomeModel.h
//  CarMango
//
//  Created by Charles on 4/17/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeModel : BaseModel

@property (nonatomic, strong) NSMutableArray *Banner;
@property (nonatomic, strong) NSMutableArray *Button;
@property (nonatomic, strong) NSMutableArray *Recommend;
@property (nonatomic, strong) NSMutableArray *PanicBuying;
@property (nonatomic, strong) NSMutableArray *Value;

@property (nonatomic, assign) NSInteger Pages;
@property (nonatomic, assign) NSInteger Total;
@property (nonatomic, strong) NSMutableArray *Data;


/**
 *  首页数据接口
 */
+ (NSURLSessionDataTask *)getHomeDataWithNetworkHUD:(NetworkHUD)hud
                                             target:(id)target
                                            success:(NetResponseBlock)success;

/**
 *  获取广告列表
 */
+ (NSURLSessionDataTask *)getADListWithPages:(NSInteger)Pages
                                  networkHUD:(NetworkHUD)hud
                                      target:(id)target
                                     success:(NetResponseBlock)success;

/**
 *  获取大牌登场列表
 */
+ (NSURLSessionDataTask *)getBingProductListWithPages:(NSInteger)Pages
                                           networkHUD:(NetworkHUD)hud
                                               target:(id)target
                                              success:(NetResponseBlock)success;

@end

