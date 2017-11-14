//
//  TimeUtil.h
//  wq
//
//  Created by berwin on 13-7-20.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import <Foundation/Foundation.h>
///展示朋友圈的时间
#define ZHShowCircleDate(date) [TimeUtil getFriendsCircleDateFormat:date]
@interface TimeUtil : NSObject

+ (NSString*)getTimeStr:(long) createdAt;

+ (NSString*)getFullTimeStr:(long long)time;

+ (NSString*)getMDStr:(long long)time;

+(NSDateComponents*)getComponent:(long long)time;

// begin 张绍裕 20140625 添加获取NSDateComponents实例方法
/// 根据时间字符及其格式获取NSDateComponents实例
+ (NSDateComponents *)getDateComponentsWithTime:(NSString *)time formatter:(NSString *)format;

// end

+(NSString*) getTimeStrStyle1:(long long)time;

+(NSString*) getTimeStrStyle2:(long long)time;

+(NSString*) getTimeStrStyle3:(long long)time;

//dataFormat
+ (NSString*)getDate:(NSDate*)date withFormat:(NSString*)dataFormat;
+ (NSDate*)getDateWithDateString:(NSString*)date dateFormat:(NSString*)format;
//默认格式时间，聊天用
+ (NSString*)getDefaultDateFormat:(NSDate*)date;
//获取消息列表时间格式
+ (NSString*)getMessageDateFormat:(NSDate*)date;
//聊天时间格式
+ (NSString*)getChatDateFormat:(NSDate*)date;
//获取朋友圈时间格式
+ (NSString*)getFriendsCircleDateFormat:(NSDate*)date;
//
+ (NSString*)getTimeStrStyle4:(NSDate *)date;

+ (NSString*)getTimeStrStyle4:(NSDate *)date today:(NSDate*)today;

+ (NSString*)getTimeStrStyle5:(NSDate *)date;
+ (NSString*)getTimeStrStyle5:(NSDate *)date today:(NSDate*)today;

//时间格式 : 2014-01-01
+ (NSString*)getMonthAndDayAndHourAndMiniteTimeStr:(NSTimeInterval)timeInterval;

//时间格式 ：xx年xx月xx日
+ (NSString*)getMonthDayYearTimeStr:(NSTimeInterval)timeInterval;

//计算某件中的某月有多少天
+ (NSInteger)howManyDaysInThisMonth:(NSInteger)year month:(NSInteger)imonth;

///陈俞帆 时间精确到分
+ (NSString*)getTimeForStr:(long long)time;
///2015.9.17 时间精确到天
+ (NSString*)getTimeAccurateDayForStr:(long long)time;

@end
