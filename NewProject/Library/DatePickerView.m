//
//  DatePickerView.m
//  RacingCarLottery
//
//  Created by dary on 2017/6/7.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import "DatePickerView.h"

#define kMinYear 1970
#define kMaxYear 2017

@interface DatePickerView () <UIPickerViewDelegate, UIPickerViewDataSource> {
    UIView *_bgView;
    UIView *_contentView;
    UIView *_barView;
    UIPickerView *_pickerView;
    // 年月日数组
    NSMutableArray *_yearArray;
    NSMutableArray *_monthArray;
    NSMutableArray *_dayArray;
    // 当前年月日最大值
    NSInteger _maxYear;
    NSInteger _maxMonth;
    NSInteger _maxDay;
    // 选中年月日行数
    NSInteger _selectedYearRow;
    NSInteger _selectedMonthRow;
    NSInteger _selectedDayRow;
    // 返回年月日数据
    NSString *_dataStr;
}

@end

@implementation DatePickerView

+ (instancetype)initDatePickerViewWithComplete:(void (^)(NSString *dateStr))complete {
    DatePickerView *pickerView = [[DatePickerView alloc]initDatePickerViewWithComplete:complete];
    return pickerView;
}

- (instancetype)initDatePickerViewWithComplete:(void (^)(NSString *dateStr))complete {
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if (self) {
        _completeBlock = complete;
        [self setData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUI];
        });
    }
    return self;
}

- (void)setUI {
    _bgView = InsertView(self, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), UIColorHex_Alpha(0x000000, 0.4));
    @weakify(self);
    [_bgView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        [self hideAction];
    }];
    
    _contentView = InsertView(self, CGRectMake(0, self.frame.size.height, self.frame.size.width, 300), [UIColor whiteColor]);
    _barView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    [_contentView addSubview:_barView];
    InsertView(_barView, CGRectMake(0, _barView.height - 0.5, kScreenWidth, 0.5), kColorSeparateline);
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(80, 0, self.frame.size.width - 160, 40)];
    title.text = @"生日";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:14];
    title.textColor = [UIColor blackColor];
    [_barView addSubview:title];
    
    UIButton *cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:kColorNavBgFrist forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancel addTarget:self action:@selector(hideAction) forControlEvents:UIControlEventTouchUpInside];
    [_barView addSubview:cancel];
    
    UIButton *done = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 80, 0, 80, 40)];
    [done setTitle:@"完成" forState:UIControlStateNormal];
    [done setTitleColor:kColorNavBgFrist forState:UIControlStateNormal];
    done.titleLabel.font = [UIFont systemFontOfSize:14];
    [done addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_barView addSubview:done];
    
    //UIPickerView
    _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, _barView.bottom, kScreenWidth, _contentView.height - 40)];
    _pickerView.backgroundColor = [UIColor whiteColor];
    _pickerView.showsSelectionIndicator = YES;
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    [_contentView addSubview:_pickerView];
    // 默认选中的时间
    _selectedYearRow = _yearArray.count - 20;
    _selectedMonthRow = 0;
    _selectedDayRow = 0;
    [_pickerView selectRow:_selectedYearRow inComponent:0 animated:NO];
    [_pickerView reloadComponent:1];
    [_pickerView selectRow:_selectedMonthRow inComponent:1 animated:NO];
    [_pickerView reloadComponent:2];
    [_pickerView selectRow:_selectedDayRow inComponent:2 animated:NO];
    
    // 显示选择view
    [self showAction];
}

#pragma mark - privateMethod
- (void)buttonAction:(UIButton *)button {
    _dataStr = [NSString stringWithFormat:@"%@-%@-%@", _yearArray[_selectedYearRow], _monthArray[_selectedMonthRow], _dayArray[_selectedDayRow]];
    if (_completeBlock) {
        _completeBlock(_dataStr);
    }
    [self hideAction];
}

- (void)showAction {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        _contentView.top =  self.height - 300;
        [self setNeedsLayout];
    }];
}

- (void)hideAction {
    [UIView animateWithDuration:0.25 animations:^{
        _contentView.top = self.height - 300;
        [self setNeedsLayout];
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [_yearArray count];
            break;
        case 1:
            return [_monthArray count];
            break;
        case 2:
            return [_dayArray count];
            break;
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *pickerLabel = (UILabel *)view;
    
    if (pickerLabel == nil) {
        pickerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(pickerView.frame) / 4, 30.0f)];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.backgroundColor = [UIColor clearColor];
        pickerLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    
    switch (component) {
        case 0:
            pickerLabel.text = [NSString stringWithFormat:@"%@年", [_yearArray objectAtIndex:row]];
            break;
        case 1:
            pickerLabel.text = [NSString stringWithFormat:@"%@月", [_monthArray objectAtIndex:row]];
            break;
        case 2:
            pickerLabel.text = [NSString stringWithFormat:@"%@日", [_dayArray objectAtIndex:row]];
            break;
    }
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            _selectedYearRow = row;
            NSInteger selectedYear = [[_yearArray objectAtIndex:row] integerValue]; //获取选择的年份。
            [self resetMonthArrayWithYear:selectedYear]; //重置月份。
            NSInteger selectedMonth = [[_monthArray objectAtIndex:_selectedMonthRow] integerValue]; //获取选择的月份。
            [self resetDayArrayWithYear:selectedYear month:selectedMonth]; //重置天数。
            [pickerView reloadAllComponents];
        }
            break;
        case 1: {
            _selectedMonthRow = row;
            NSInteger selectedMonth = [[_monthArray objectAtIndex:row]integerValue];
            NSInteger selectedYear = [[_yearArray objectAtIndex:_selectedYearRow] intValue];
            [self resetDayArrayWithYear:selectedYear month:selectedMonth]; //重置天数
            [pickerView reloadAllComponents];
        }
            break;
        case 2: {
            _selectedDayRow = row;
            [pickerView reloadAllComponents];
        }
            break;
    }
}

- (void)setData {
    //初始化最大值。
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *currentDateComponents = [calendar components:calendarUnit fromDate:currentDate];
    _maxYear = [currentDateComponents year];
    _maxMonth = [currentDateComponents month];
    _maxDay = [currentDateComponents day];
    
    //初始化当前时间。
    NSInteger currentYear = _maxYear;
    NSInteger currentMonth = _maxMonth;
    NSInteger currentDay = _maxDay;
    
    //初始化年份数组(范围自定义)。
    _yearArray = [[NSMutableArray alloc]init];
    for (NSInteger i = kMinYear; i <= currentYear; i ++) {
        [_yearArray addObject:[NSString stringWithFormat:@"%ld",i]];
    }
    _selectedYearRow = [_yearArray indexOfObject:[NSString stringWithFormat:@"%ld", currentYear]];
    
    //初始化月份数组(1-12)。
    _monthArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1; i <= currentMonth; i++) {
        [_monthArray addObject:[NSString stringWithFormat:@"%02ld",i]];
    }
    _selectedMonthRow = currentMonth - 1;
    
    //初始化天数数组(1-31)。
    _dayArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1; i <= currentDay; i++) {
        [_dayArray addObject:[NSString stringWithFormat:@"%02ld",i]];
    }
    _selectedDayRow = currentDay - 1;
}

#pragma mark 更新但前时间数组中的数据
- (void)updateCurrentDateArray {
    //获取当前选中时间。
    NSInteger currentYear = [[_yearArray objectAtIndex:_selectedYearRow] integerValue];
    NSInteger currentMonth = [[_monthArray objectAtIndex:_selectedMonthRow] integerValue];
    
    //更新时间数组中的数据。
    [self resetYearArray];
    [self resetMonthArrayWithYear:currentYear];
    [self resetDayArrayWithYear:currentYear month:currentMonth];
}

#pragma mark - 重置年份
- (void)resetYearArray {
    //先判断是否需要重置。
    NSInteger minYear = [_yearArray[0] integerValue];
    NSInteger maxYear = [_yearArray[_yearArray.count - 1] integerValue];
    if (kMinYear == minYear && _maxYear == maxYear) {
        return;
    }
    
    [_yearArray removeAllObjects];
    for (NSInteger i = kMinYear; i <= _maxYear; i++) {
        [_yearArray addObject:[NSString stringWithFormat:@"%ld",i]];
    }
    
    //重置年份选中行，防止越界。
    _selectedYearRow = _selectedYearRow > [_yearArray count] - 1 ? [_yearArray count] - 1 : _selectedYearRow;
}

#pragma mark - 重置月份
- (void)resetMonthArrayWithYear:(NSInteger)year {
    NSInteger totalMonth = 12;
    if (_maxYear == year) {
        totalMonth = _maxMonth;// 限制月份。
    }
    NSInteger lastMonth = [_monthArray[_monthArray.count - 1] integerValue];// 数组中最大月份。
    if (lastMonth < totalMonth) {
        while (++lastMonth <= totalMonth) {
            [_monthArray addObject:[NSString stringWithFormat:@"%ld",lastMonth]];
        }
    } else if (lastMonth > totalMonth) {
        while (lastMonth > totalMonth) {
            [_monthArray removeObject:[NSString stringWithFormat:@"%ld",lastMonth]];
            lastMonth--;
        }
    }
    
    //重置月份选中行，防止越界。
    _selectedMonthRow = _selectedMonthRow > [_monthArray count] - 1 ? [_monthArray count] - 1: _selectedMonthRow;
}

#pragma mark - 重置天数
- (void)resetDayArrayWithYear:(NSInteger)year month:(NSInteger)month {
    NSInteger totalDay = 0;
    if (_maxYear == year && _maxMonth == month) {
        totalDay = _maxDay; //限制最大天数。
    } else if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
        totalDay = 31;
    } else if(month == 2) {
        if (((year % 4 == 0 && year % 100 != 0 ))|| (year % 400 == 0)) {
            totalDay = 29;
        } else {
            totalDay = 28;
        }
    } else {
        totalDay = 30;
    }
    
    NSInteger lastDay = [_dayArray[_dayArray.count - 1] integerValue]; //数组中最大天数。
    if(lastDay < totalDay) {
        while (++lastDay <= totalDay) {
            [_dayArray addObject:[NSString stringWithFormat:@"%ld",lastDay]];
        }
    } else if (lastDay > totalDay) {
        while (lastDay > totalDay) {
            [_dayArray removeObject:[NSString stringWithFormat:@"%ld",lastDay]];
            lastDay--;
        }
    }
    // 重置天数选中行，防止越界。
    _selectedDayRow = _selectedDayRow > [_dayArray count] - 1 ? [_dayArray count] - 1 : _selectedDayRow;
}

@end
