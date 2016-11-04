//
//  CommonUtil.h
//  GoodHappiness
//  App内特有方法Util
//  Created by chaolong on 16/6/16.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject

/**
 *  参与进度百分比规则（1%~99%向下取整，0%~1%为1%，%0和100%取原值）
 *  @param numerator   分子
 *  @param denominator 分母
 */
+ (CGFloat)getPercentWithNumerator:(CGFloat)numerator denominator:(CGFloat)denominator;

/**
 *  对字符串，textfield，textview字符进行长度限制(默认不包括中文限制)
 *  @param source    输入源
 *  @param maxLength 限制长度
 */
+ (BOOL)limitLengthWithInputSource:(id)source maxLength:(NSUInteger)maxLength;

/**
 *  限制字符长度
 *  @param source    输入源
 *  @param maxLength 最大长度
 *  @param isAll     是否包括中文，一个中文为两个字符
 */
+ (BOOL)limitLengthWithInputSource:(id)source maxLength:(NSUInteger)maxLength isAll:(BOOL)isAll;

/**
 *  对字符串，textfield，textview字符进行长度限制
 *  @param source    输入源
 *  @param maxLength 限制长度
 *  @param isAll     是否包括中文，一个中文为两个字符
 */
+ (NSString *)limitTextWithInputSource:(id)source maxLength:(NSUInteger)maxLength;

/**
 *  对字符串，textfield，textview字符进行长度限制
 *  @param source    输入源
 *  @param maxLength 限制长度
 *  @param isAll     是否包括中文，一个中文为两个字符
 */
+ (NSString *)limitTextWithInputSource:(id)source maxLength:(NSUInteger)maxLength isAll:(BOOL)isAll;

// 判断输入的字符长度 一个汉字算2个字符
+ (NSUInteger)unicodeLengthOfString:(NSString *)source isAll:(BOOL)isAll;

// 判断是否为纯数字 不好用
+ (BOOL)isNumText:(NSString *)str;
// 是否是纯数字
+ (BOOL)isPureInt:(NSString*)string;
// 保留2位小数
+ (double)getTwoDecimalsDoubleValue:(double)number;

@end
