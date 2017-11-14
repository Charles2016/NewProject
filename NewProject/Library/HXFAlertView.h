//
//  HXFAlertView.h
//  RacingCarLottery
//
//  Created by chaolong on 16/6/7.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, AlertViewType) {
    AlertViewSingle,
    AlertViewNormal,
    AlertViewSheet,
    AlertViewSheetFull,/// 仿照微信的做的
    AlertViewInputFeildCenter,
    AlertViewInputFeildBottom,
};

@interface HXFAlertView : UIView

@property (nonatomic, copy) void (^completeBlock)(NSInteger buttonIndex);
@property (nonatomic, copy) void (^inputCompleteBlock)(NSInteger buttonIndex, NSString *inputStr);

/**
 *  alertView单个按钮样式
 *  @param title        标题
 *  @param message      消息
 *  @param cancelButton 对应按钮
 */
+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message
                  cancelButton:(NSString *)cancelButton
                      complete:(void (^)(NSInteger buttonIndex))complete;

/**
 *  alertView两个按钮样式
 *  @param title        标题
 *  @param message      消息
 *  @param cancelButton 取消按钮
 *  @param otherButton  其他按钮
 */
+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message
                  cancelButton:(NSString *)cancelButton
                   otherButton:(NSString *)otherButton
                      complete:(void (^)(NSInteger buttonIndex))complete;

/**
 *  alertView两个按钮带输入栏样式
 *  @param title         标题
 *  @param message       消息
 *  @param alertViewType 输入栏样式
 *  @param cancelButton  取消按钮
 *  @param otherButton   其他按钮
 */
+ (instancetype)alertInputFeildWithTitle:(NSString *)title
                                 message:(NSString *)message
                           alertViewType:(AlertViewType)alertViewType
                            cancelButton:(NSString *)cancelButton
                             otherButton:(NSString *)otherButton
                                complete:(void (^)(NSInteger buttonIndex, NSString *inputStr))complete;

/**
 * actionSheet系统默认样式(按钮字体默认蓝色)
 * @param title        标题
 * @param message      消息
 * @param cancelButton 取消按钮
 * @param otherButtons 其他按钮
 */
+ (instancetype)actionSheetWithTitle:(NSString *)title
                             message:(NSString *)message
                        cancelButton:(NSString *)cancelButton
                        otherButtons:(NSArray *)otherButtons
                            complete:(void (^)(NSInteger buttonIndex))complete;
/**
 *  actionSheet可设置按钮字体颜色样式(按钮字体默认蓝色)
 *  @param title        标题
 *  @param message      消息
 *  @param cancelButton 取消按钮
 *  @param otherButtons 其他按钮数组
 *  @param otherColor   设置按钮颜色
 */
+ (instancetype)actionSheetWithTitle:(NSString *)title
                             message:(NSString *)message
                        cancelButton:(NSString *)cancelButton
                        otherButtons:(NSArray *)otherButtons
                         otherColors:(NSArray *)otherColors
                       alertViewType:(AlertViewType)alertViewType
                            complete:(void (^)(NSInteger buttonIndex))complete;

@end
