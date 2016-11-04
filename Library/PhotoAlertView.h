//
//  PhotoAlertView.h
//  GoodHappiness
//
//  Created by chaolong on 16/5/5.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, PhotoAlertType) {
    PhotoAlertNormal,       /// 默认黑色背景
    PhotoAlertViewSingle,   /// 白色背景
    PhotoAlertViewSingleBlack,/// 拉黑取消按钮黑色样式
    PhotoAlertInputStyle,   /// 带输入栏
};

@interface PhotoAlertView : UIView

@property (nonatomic, copy) void (^chooseBlock)(NSInteger buttonIndex);
@property (nonatomic, copy) void (^inputChooseBlock)(NSInteger buttonIndex, NSString *inputStr);

/**
 *  椭圆形警告框
 *  @param title        标题
 *  @param message      内容
 *  @param buttonTitles 按钮标题
 *  @param alertType    警告框样式
 *  @param complete     返回block
 */
+ (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                 buttonTitles:(NSArray *)buttonTitles
                    alertType:(PhotoAlertType)alertType
                     complete:(void (^)(NSInteger buttonIndex))complete;

/**
 *  椭圆带输入栏警告框
 *  @param title        标题
 *  @param message      内容
 *  @param buttonTitles 按钮标题
 *  @param complete     返回block
 */
+ (instancetype)initInputFeildWithTitle:(NSString *)title
                                message:(NSString *)message
                           buttonTitles:(NSArray *)buttonTitles
                               complete:(void (^)(NSInteger buttonIndex, NSString *inputStr))complete;


@end
