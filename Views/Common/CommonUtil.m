//
//  CommonUtil.m
//  GoodHappiness
//
//  Created by chaolong on 16/6/16.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil

/**
 *  参与进度百分比规则（1%~99%向下取整，0%~1%为1%，%0和100%取原值）
 *  @param numerator   分子
 *  @param denominator 分母
 */
+ (CGFloat)getPercentWithNumerator:(CGFloat)numerator denominator:(CGFloat)denominator {
    CGFloat percent = numerator / denominator;
    if (numerator == 0) {
        percent = 0;
    } else {
        if (numerator == denominator) {
            percent = 100;
        } else {
            percent = percent * 100;
            if (percent < 1) {
                percent = 1;
            } else {
                percent = floorf(percent);
            }
        }
    }
    return percent;
}

/**
 *  对字符串，textfield，textview字符进行长度限制(默认不包括中文限制)
 *  @param source    输入源
 *  @param maxLength 限制长度
 */
+ (BOOL)limitLengthWithInputSource:(id)source maxLength:(NSUInteger)maxLength {
    return [self limitLengthWithInputSource:source maxLength:maxLength isAll:NO];
}

/**
 *  限制字符长度
 *  @param source    输入源
 *  @param maxLength 最大长度
 *  @param isAll     是否包括中文，一个中文为两个字符
 */
+ (BOOL)limitLengthWithInputSource:(id)source maxLength:(NSUInteger)maxLength isAll:(BOOL)isAll {
    NSString *toBeString;
    NSInteger sourceType = 0;// 1字符串 2textField 3textView
    if ([source isKindOfClass:[NSString class]]){
        toBeString = source;
        sourceType = 1;
        return [self subStringIncludeChinese:source maxLength:maxLength];
    } else if ([source isKindOfClass:[UITextField class]]) {
        toBeString = ((UITextField *)source).text;
        sourceType = 2;
    } else if ([source isKindOfClass:[UITextView class]]) {
        toBeString = ((UITextView *)source).text;
        sourceType = 3;
    }
    NSUInteger length = [self unicodeLengthOfString:toBeString isAll:isAll];
    return length < maxLength;
}

/**
 *  对字符串，textfield，textview字符进行字符限制(默认不包括中文限制)
 *  @param source    输入源
 *  @param maxLength 限制长度
 */
+ (NSString *)limitTextWithInputSource:(id)source maxLength:(NSUInteger)maxLength {
    return [self limitTextWithInputSource:source maxLength:maxLength isAll:NO];
}

/**
 *  对字符串，textfield，textview字符进行长度限制
 *  @param source    输入源
 *  @param maxLength 限制长度
 *  @param isAll     是否包括中文，一个中文为两个字符
 */
+ (NSString *)limitTextWithInputSource:(id)source maxLength:(NSUInteger)maxLength isAll:(BOOL)isAll {
    NSString *toBeString;
    NSInteger sourceType = 0;// 1字符串 2textField 3textView
    if ([source isKindOfClass:[NSString class]]){
        toBeString = source;
        sourceType = 1;
        return [self subStringIncludeChinese:source maxLength:maxLength];
    } else if ([source isKindOfClass:[UITextField class]]) {
        toBeString = ((UITextField *)source).text;
        sourceType = 2;
    } else if ([source isKindOfClass:[UITextView class]]) {
        toBeString = ((UITextView *)source).text;
        sourceType = 3;
    }
    NSUInteger length = [self unicodeLengthOfString:toBeString isAll:isAll];
    if (length > maxLength) {
        UITextInputMode *currentInputMode;
        if (sourceType == 2) {
            currentInputMode = ((UITextField *)source).textInputMode;
        } else if (sourceType == 3) {
            currentInputMode = ((UITextView *)source).textInputMode;
        }
        
        if ([currentInputMode.primaryLanguage isEqualToString:@"zh-Hans"]) {
            // 简体中文输入，包括简体拼音，健体五笔，简体手写
            UITextRange *selectedRange;
            if (sourceType == 2) {
                selectedRange = [(UITextField *)source markedTextRange];
            } else if (sourceType == 3) {
                selectedRange = [(UITextView *)source markedTextRange];
            }
            //获取高亮部分
            UITextPosition *position = [(UITextView *)source positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position) {
                if (isAll) {
                    toBeString = [self subStringIncludeChinese:toBeString maxLength:maxLength];
                } else {
                    toBeString = [toBeString substringToIndex:maxLength];;
                }
            } else {
                // 有高亮选择的字符串，则暂不对文字进行统计和限制
            }
        } else{
            // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
            if (isAll) {
                toBeString = [self subStringIncludeChinese:toBeString maxLength:maxLength];
            } else {
                toBeString = [toBeString substringToIndex:maxLength];
            }
        }
    }
    
    if (sourceType == 2) {
        ((UITextField *)source).text = toBeString;
    } else if (sourceType == 3) {
        ((UITextView *)source).text = toBeString;
    }
    return toBeString;
}

// 字符串截到对应的长度包括中文 一个汉字算2个字符
+ (NSString *)subStringIncludeChinese:(NSString *)text maxLength:(NSUInteger)length {
    NSUInteger asciiLength = 0;
    NSUInteger location = 0;
    for(NSUInteger i = 0; i < text.length; i++) {
        unichar uc = [text characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;
        if (asciiLength == length) {
            location = i;
            break;
        }else if (asciiLength > length){
            location = i - 1;
            break;
        }
    }
    
    if (asciiLength < length) {
        //文字长度小于限制长度
        return text;
    } else {
        __block NSMutableString * finalStr = [NSMutableString stringWithString:text];
        [text enumerateSubstringsInRange:NSMakeRange(0, [text length]) options:NSStringEnumerationByComposedCharacterSequences|NSStringEnumerationReverse usingBlock:
         ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
             if (substringRange.location<=location+1) {
                 NSString *temp=[text substringToIndex:substringRange.location];
                 finalStr=[NSMutableString stringWithString:temp];
                 *stop=YES;
             }
         }];
        return finalStr;
    }
}

// 判断输入的字符长度 一个汉字算2个字符
+ (NSUInteger)unicodeLengthOfString:(NSString *)source isAll:(BOOL)isAll {
    NSUInteger asciiLength = 0;
    for(NSUInteger i = 0; i < source.length; i++) {
        unichar uc = [source characterAtIndex:i];
        if (isAll) {
            asciiLength += isascii(uc) ? 1 : 2;
        } else {
            asciiLength += 1;
        }
    }
    return asciiLength;
}

// 限制字符长度 ，不包括汉字
+ (NSString *)limitLengthWithSource:(NSString *)source maxLength:(NSUInteger)maxLength {
    if (source.length > maxLength) {
        source = [source substringToIndex:maxLength];
    }
    return source;
}

//是否是纯数字
+ (BOOL)isNumText:(NSString *)str {
    NSString * regex = @"(/^[0-9]*$/)";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (isMatch) {
        return YES;
    } else {
        return NO;
    }
}

//是否是纯数字
+ (BOOL)isPureInt:(NSString*)string {
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//保留2位小数
+ (double)getTwoDecimalsDoubleValue:(double)number {
    return round(number * 100.0) / 100.0;
}

@end
