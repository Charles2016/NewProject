//
//  NSString+Judge.m
//  CarShop
//
//  Created by Charles on 3/25/16.
//  Copyright © 2016 Charles. All rights reserved.
//

#import "NSString+Judge.h"

@implementation NSString (Judge)

- (BOOL)isChinese {
    return [self getResultWithStr:@"(^[\u4e00-\u9fa5]+$)"];
}

- (BOOL)includeChinese {
    for(int i=0; i< [self length];i++) {
        int a =[self characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

/// 是否为有效的url
- (BOOL)isValidURL {
    return [self getResultWithStr:@"^((([hH][tT][tT][pP][sS]?|[fF][tT][pP])\\:\\/\\/)?([\\w\\.\\-]+(\\:[\\w\\.\\&%\\$\\-]+)*@)?((([^\\s\\(\\)\\<\\>\\\\\\\"\\.\\[\\]\\,@;:]+)(\\.[^\\s\\(\\)\\<\\>\\\\\\\"\\.\\[\\]\\,@;:]+)*(\\.[a-zA-Z]{2,4}))|((([01]?\\d{1,2}|2[0-4]\\d|25[0-5])\\.){3}([01]?\\d{1,2}|2[0-4]\\d|25[0-5])))(\\b\\:(6553[0-5]|655[0-2]\\d|65[0-4]\\d{2}|6[0-4]\\d{3}|[1-5]\\d{4}|[1-9]\\d{0,3}|0)\\b)?((\\/[^\\/][\\w\\.\\,\\?\\\'\\\\\\/\\+&%\\$#\\=~_\\-@]*)*[^\\.\\,\\?\\\"\\\'\\(\\)\\[\\]!;<>{}\\s\\x7F-\\xFF])?)$"];
}

// 判断手机号
- (BOOL)isMobile {
    return [self getResultWithStr:@"^(13[0-9]|14[0-9]|15[0-9]|17[0-9]|18[0-9])\\d{8}$"];
}

// 邮编
- (BOOL)isPostcode {
    return [self getResultWithStr:@"[1-9]{1}(\\d+){5}"];
}

// mail
- (BOOL)isMail {
    return [self getResultWithStr:@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"];
}

// 空格
- (BOOL)isContainSpace {
    return [self getResultWithStr:@"\\s"];
}

// 电话
- (BOOL)isTel {
    return [self getResultWithStr:@"^[^1]\\d{9,11}$"];
}

// 必须以字母开头，可以使用6-20个字母、数字、下划线和减号，长度为最长20位，最少6位
- (BOOL)isHXAccount {
    return ([self getResultWithStr:@"^[a-zA-Z]+"] && [self getResultWithStr:@"^[0-9a-zA-Z_\\-]{6,20}$"]);
}

/// 有效的昵称，只包含中文，英文，数字，下划线
- (BOOL)isLegalNickname {
    return [self getResultWithStr:@"^[\\u4e00-\\u9fa5\\w]*$"];
}

// 字母/数字/特殊字符组成，6-12位,必须由字母、数字、特殊字符中任意两组组成
- (BOOL)isHxPassword {
    if ([self getResultWithStr:@"^\\S{6,12}$"]) {
        int flagCount = 0;
        if ([self getResultWithStr:@"\\d+"]) {
            flagCount++;
        }
        if ([self getResultWithStr:@"[a-zA-Z]+"]) {
            flagCount++;
        }
        if ([self getResultWithStr:@"[^0-9a-zA-Z]"]) {
            flagCount++;
        }
        return (flagCount >= 2);
    }
    return NO;
}

// null或者@""都返回yes
+ (BOOL)isNull:(NSString *)string {
    if (!string || [string isEqualToString:@""] || [string isEqualToString:@" "] ||
        [string isEqualToString:@"  "]) {
        return YES;
    }
    return NO;
}

//去空格
+ (NSString *)stringBySpaceTrim:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (BOOL)isEmptyAfterSpaceTrim:(NSString *)string {
    NSString *str = [self stringBySpaceTrim:string];
    if (str.length == 0) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)isHxBankCardNumber {
    return [self getResultWithStr:@"^[0-9]{12,19}$"];
}

-(BOOL)isHxMoney {
    return [self getResultWithStr:@"^(([1-9]\\d{0,100})|0)(\\.\\d{1,2})?$"];
}

// 匹配身份证号码
-(BOOL)isHxIdentityCard {
    // 判断位数
    if ([self length] != 15 && [self length] != 18) {
        return NO;
    }
    
    NSString *carid = self;
    long lSumQT  =0;
    // 加权因子
    int R[] ={7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 };
    // 校验码
    unsigned char sChecker[11]={'1','0','X', '9', '8', '7', '6', '5', '4', '3', '2'};
    // 将15位身份证号转换成18位
    NSMutableString *mString = [NSMutableString stringWithString:self];
    if ([self length] == 15) {
        [mString insertString:@"19" atIndex:6];
        long p = 0;
        const char *pid = [mString UTF8String];
        for (int i=0; i<=16; i++)
        {
            p += (pid[i]-48) * R[i];
        }
        int o = p%11;
        NSString *string_content = [NSString stringWithFormat:@"%c",sChecker[o]];
        [mString insertString:string_content atIndex:[mString length]];
        carid = mString;
    }
    // 判断地区码
    NSString * sProvince = [carid substringToIndex:2];
    if (![self areaCode:sProvince]) {
        return NO;
    }
    // 判断年月日是否有效
    // 年份
    int strYear = [[carid substringWithRange:NSMakeRange(6,4)] intValue];
    // 月份
    int strMonth = [[carid substringWithRange:NSMakeRange(10,2)] intValue];
    // 日
    int strDay = [[carid substringWithRange:NSMakeRange(12,2)] intValue];
    
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeZone:localZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[dateFormatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d 12:01:01",strYear,strMonth,strDay]];
    if (date == nil) {
        return NO;
    }
    const char *PaperId  = [carid UTF8String];
    // 检验长度
    if( 18 != strlen(PaperId)) return -1;
    // 校验数字
    for (int i=0; i<18; i++) {
        if ( !isdigit(PaperId[i]) && !(('X' == PaperId[i] || 'x' == PaperId[i]) && 17 == i) )
        {
            return NO;
        }
    }
    // 验证最末的校验码
    for (int i=0; i<=16; i++) {
        lSumQT += (PaperId[i]-48) * R[i];
    }
    if (sChecker[lSumQT%11] != PaperId[17] ) {
        return NO;
    }
    return YES;
}

-(BOOL)areaCode:(NSString *)code {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"北京" forKey:@"11"];
    [dic setObject:@"天津" forKey:@"12"];
    [dic setObject:@"河北" forKey:@"13"];
    [dic setObject:@"山西" forKey:@"14"];
    [dic setObject:@"内蒙古" forKey:@"15"];
    [dic setObject:@"辽宁" forKey:@"21"];
    [dic setObject:@"吉林" forKey:@"22"];
    [dic setObject:@"黑龙江" forKey:@"23"];
    [dic setObject:@"上海" forKey:@"31"];
    [dic setObject:@"江苏" forKey:@"32"];
    [dic setObject:@"浙江" forKey:@"33"];
    [dic setObject:@"安徽" forKey:@"34"];
    [dic setObject:@"福建" forKey:@"35"];
    [dic setObject:@"江西" forKey:@"36"];
    [dic setObject:@"山东" forKey:@"37"];
    [dic setObject:@"河南" forKey:@"41"];
    [dic setObject:@"湖北" forKey:@"42"];
    [dic setObject:@"湖南" forKey:@"43"];
    [dic setObject:@"广东" forKey:@"44"];
    [dic setObject:@"广西" forKey:@"45"];
    [dic setObject:@"海南" forKey:@"46"];
    [dic setObject:@"重庆" forKey:@"50"];
    [dic setObject:@"四川" forKey:@"51"];
    [dic setObject:@"贵州" forKey:@"52"];
    [dic setObject:@"云南" forKey:@"53"];
    [dic setObject:@"西藏" forKey:@"54"];
    [dic setObject:@"陕西" forKey:@"61"];
    [dic setObject:@"甘肃" forKey:@"62"];
    [dic setObject:@"青海" forKey:@"63"];
    [dic setObject:@"宁夏" forKey:@"64"];
    [dic setObject:@"新疆" forKey:@"65"];
    [dic setObject:@"台湾" forKey:@"71"];
    [dic setObject:@"香港" forKey:@"81"];
    [dic setObject:@"澳门" forKey:@"82"];
    [dic setObject:@"国外" forKey:@"91"];
    if ([dic objectForKey:code] == nil) {
        return NO;
    }
    return YES;
}

// 是否是合法的密码组成字符
- (BOOL)isLegalHXPasswordCharacter {
    return [self getResultWithStr:@"[0-9a-zA-Z]"];
}

// 是否是合法的支付密码组成字符
- (BOOL)isLegalHXPayPasswordCharacter {
    return [self getResultWithStr:@"[0-9a-zA-Z]"];
}

// 是否是合法的帐号组成字符
- (BOOL)isLegalHXAccountCharacter {
    return [self getResultWithStr:@"[0-9a-zA-Z_@]"];
}

// 合法身份证账号组成字符
- (BOOL)isLegalIDCardCharacter {
    return [self getResultWithStr:@"[0-9xX]"];
}

/// 变更账户注册格式规则（数字+字母（大写自动转小写））
- (BOOL)isLegalHXAccountCharacterRegister {
    return [self getResultWithStr:@"[0-9a-zA-Z]"];
}

/// 只输入数字 +字母 + _@.
- (BOOL)isLegalHKDemailCharacterRegister {
    return [self getResultWithStr:@"[0-9a-zA-Z_.@]"];
}

- (BOOL)isLegalCharacter:(NSString *)limitString {
    return [self getResultWithStr:limitString];
}

- (BOOL)isLegalDigitCharacterChineseAndUnderline {
    return [self getResultWithStr:@"^[a-zA-Z0-9@_\u4e00-\u9fa5]+$"];
}

// 传入正则表达式，返回是否符合正则表达式的结果，YES符合 NO不符合
- (BOOL)getResultWithStr:(NSString *)regexStr {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexStr];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

@end
