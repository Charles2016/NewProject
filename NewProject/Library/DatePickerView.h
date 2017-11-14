//
//  DatePickerView.h
//  RacingCarLottery
//
//  Created by dary on 2017/6/7.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerView : UIView

@property (nonatomic, copy) void (^completeBlock)(NSString *dateStr);

+ (instancetype)initDatePickerViewWithComplete:(void (^)(NSString *dateStr))complete;

@end
