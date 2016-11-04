//
//  OwnerView.h
//  GoodHappiness
//
//  Created by chaolong on 16/10/12.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OwnerView : UIView

/**
 *  中奖弹出框初始化
 *  @param goodsType    普通劵or超级劵
 *  @param goodsName    内容中奖名称
 *  @param complete     返回block
 */
+ (instancetype)initWithGoodsType:(NSInteger)goodsType
                        goodsName:(NSString *)goodsName
                         complete:(void (^)(NSInteger buttonIndex))complete;

@end
