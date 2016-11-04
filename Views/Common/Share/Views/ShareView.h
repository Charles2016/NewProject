//
//  ShareView.h
//  GoodHappiness
//
//  Created by chaolong on 16/5/17.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, ShareFromType) {
    ShareFromTypeNormal,// 分享正常样式不请求接口，不显示举报和删除
    ShareFromTypeFriendCircleNormal,// 朋友圈分享正常样式，只显示举报
    ShareFromTypeFriendCircleWithDelete,// 自己发布的只显示删除，隐藏举报功能
    ShareFromTypeLottery,// 中奖部分分享样式请求接口，不显示举报和删除
    ShareFromTypeOther// 其他样式待定
};

@interface ShareView : UIView

@property (nonatomic, copy) void (^completeBlock)(NSInteger);
@property (nonatomic, assign) ShareFromType shareFromType;

/**
 *  带参数分享
 *  @param shareTitle 标题
 *  @param shareUrl   分享链接
 *  @param shareTxt  分享内容
 *  @param shareImg 分享图片
 */
+ (instancetype)initWithShareTitle:(NSString *)shareTitle
                          shareUrl:(NSString *)shareUrl
                          shareTxt:(NSString *)shareTxt
                          shareImg:(NSString *)shareImg
                          complete:(void (^)(NSInteger buttonIndex))complete;

/**
 *  直接弹出shareView样式（参数之后请求接口所得）
 *  不带参数分享初始化方法
 *  @param shareFromType 分享View样式
 *  @param action 分享入口
 *  @param shareId 对应Id
 */
+ (instancetype)initWithShareFromType:(ShareFromType)shareFromType
                               action:(NSString *)action
                              shareId:(NSInteger)shareId
                             complete:(void (^)(NSInteger buttonIndex))complete;


@end
