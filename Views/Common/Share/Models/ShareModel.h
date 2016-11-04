//
//  ShareModel.h
//  GoodHappiness
//
//  Created by chaolong on 16/6/16.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "BaseModel.h"

@interface ShareModel : BaseModel

@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *shareUrl;
@property (nonatomic, copy) NSString *shareTxt;
@property (nonatomic, copy) NSString *shareImg;

/**
 *  分享接口请求
 *  @param action  feed:朋友圈 shop:商城 period:礼券 exchange:兑换记录 award:中奖记录
 *  @param shareId 对应Id
 */
+ (NSURLSessionDataTask *)getShareInfoWithAction:(NSString *)action
                                         shareId:(NSInteger)shareId
                                      networkHUD:(NetworkHUD)hud
                                          target:(id)target
                                         success:(NetResponseBlock)success;

/**
 *  举报接口
 *  @param reason  原因
 *  @param postId  评论or回复Id
 *  @param type    评论or回复类型
 */
+ (NSURLSessionDataTask *)getReportWithReason:(NSString *)reason
                                       postId:(NSInteger)postId
                                         type:(NSString *)type
                                   networkHUD:(NetworkHUD)hud
                                       target:(id)target
                                      success:(NetResponseBlock)success;

@end
