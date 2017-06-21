//
//  ZYDatePickerAlertView.m
//  ZYDatePickerYMDHM
//
//  Created by yao on 2017/6/15.
//  Copyright © 2017年 yao. All rights reserved.
//

#import "ZYDatePickerAlertView.h"

#define RGBA(r, g, b, a) ([UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a])
#define RGB(r, g, b) RGBA(r,g,b,1)
#define kMinYear [[[NSDate dateWithMinutesFromNow:5] stringWithFormat:@"yyyy"] integerValue]
#define kMaxYear [[[[NSDate dateWithMinutesFromNow:5] dateByAddingYears:1] stringWithFormat:@"yyyy"] integerValue]
#define kThemeColor RGB(256, 254, 255)
#define kLineColor RGB(192, 192, 192)
#define kCancleColor RGB(170, 170, 170)
#define kCompleteColor RGB(15, 162, 246)
#define kDateTextColor RGB(100, 149, 237)

@interface ZYDatePickerAlertView()<UIPickerViewDelegate, UIPickerViewDataSource,UIGestureRecognizerDelegate> {
    
    NSString       *_title;
    NSString       *_dateFormatter;
    
    //日期存储数组
    NSMutableArray *_yearArray;
    NSMutableArray *_monthArray;
    NSMutableArray *_dayArray;
    NSMutableArray *_hourArray;
    NSMutableArray *_minuteArray;
    //记录位置
    NSInteger      yearIndex;
    NSInteger      monthIndex;
    NSInteger      dayIndex;
    NSInteger      hourIndex;
    NSInteger      minuteIndex;
    
    NSInteger      preRow;
    DisplayModel   _displayModel;
}

@property(nonatomic, strong)UILabel *titleLabel;

@property(nonatomic, strong)UIView *maskView;
@property(nonatomic, strong)UIView *bgView;
@property(nonatomic, strong)UIButton *cancleBtn;
@property(nonatomic, strong)UIButton *completeBtn;

/** 时间选择视图 */
@property(nonatomic, strong)UIPickerView *datePicker;
@end

@implementation ZYDatePickerAlertView

- (instancetype)initWithFrame:(CGRect)frame andTitleString:(NSString *)title withDisplayModel:(DisplayModel)displayModel {
    if ([super initWithFrame:frame]) {
        _title = title;
        _displayModel = displayModel;
        _dateFormatter = @"yyyy-MM-dd HH:mm";
        
        [self setupUI];
        [self defaultConfig];
    }
    return self;
}

- (void)setupUI {
    self.frame = CGRectMake(0, 0, self.width, self.height);
    [self addSubview:self.maskView];
    [self.maskView addSubview:self.bgView];
    /** 标题 */
    self.titleLabel.text = _title;
    [_bgView addSubview:_titleLabel];
    
    UILabel *lineLB = [[UILabel alloc] initWithFrame:CGRectMake(15, _titleLabel.bottom, _bgView.width - 30, 1)];
    lineLB.backgroundColor = kLineColor;
    [_bgView addSubview:lineLB];
    
    /** 时间选择器 */
    [_bgView addSubview:self.datePicker];
    
    /** 取消 */
    [_bgView addSubview:self.cancleBtn];
    
    /** 确定 */
    [_bgView addSubview:self.completeBtn];
    
    UILabel *lineLB1 = [[UILabel alloc] initWithFrame:CGRectMake(0, _datePicker.bottom, _bgView.width, 1)];
    lineLB1.backgroundColor = kLineColor;
    [_bgView addSubview:lineLB1];
    
    UILabel *lineLB2 = [[UILabel alloc] initWithFrame:CGRectMake(_cancleBtn.right, _datePicker.bottom, 1, 30)];
    lineLB2.backgroundColor = kLineColor;
    [_bgView addSubview:lineLB2];
}

- (void)defaultConfig {
    if (!_scrollToDate) {
        _scrollToDate = _minLimitDate;
    }
    
    //循环滚动时需要用到
    preRow = (self.scrollToDate.year - kMinYear) * 12 + self.scrollToDate.month - 1;
    
    //设置年月日时分数据
    _yearArray = [self setArray:_yearArray];
    _monthArray = [self setArray:_monthArray];
    _dayArray = [self setArray:_dayArray];
    _hourArray = [self setArray:_hourArray];
    _minuteArray = [self setArray:_minuteArray];
    
    switch (_displayModel) {
        case NotOptionalNotDisplay: {
            [_yearArray addObject:[NSString stringWithFormat:@"%02d", kMinYear]];
            [_yearArray addObject:[NSString stringWithFormat:@"%02d", kMaxYear]];
            
            [self configureMonthArray:kMinYear];
            [self daysFromYear:kMinYear andMonth:_minLimitDate.month];
            
            for (int i = 0; i < 60; i++) {
                NSString *num = [NSString stringWithFormat:@"%02d",i];
                if (0 < i && i <= 12)
                    [_monthArray addObject:num];
                if (i < 24)
                    [_hourArray addObject:num];
                [_minuteArray addObject:num];
            }
        }
            break;
        default: {
            for (NSInteger i = 0; i < 60; i++) {
                NSString *num = [NSString stringWithFormat:@"%02d",i];
                if (0 < i && i <= 12)
                    [_monthArray addObject:num];
                if (i < 24)
                    [_hourArray addObject:num];
                [_minuteArray addObject:num];
            }
            for (NSInteger i = kMinYear; i <= kMaxYear; i++) {
                NSString *num = [NSString stringWithFormat:@"%ld",(long)i];
                [_yearArray addObject:num];
            }
        }
            break;
    }
}

#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    [self addLabelWithName:@[@"年",@"月",@"日",@"时",@"分"]];
    return 5;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *numberArr = [self getNumberOfRowsInComponent];
    return [numberArr[component] integerValue];
}

- (NSArray *)getNumberOfRowsInComponent {
    NSInteger yearNum, monthNum, dayNum, hourNum, minuteNUm;
    switch (_displayModel) {
        case NotOptionalNotDisplay: {
            yearNum = _yearArray.count;
            
            [self configureMonthArray:[_yearArray[yearIndex] integerValue]];
            monthNum = _monthArray.count;
            
            [self daysFromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
            dayNum = _dayArray.count;
            
            [self configureHourArrayWithYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue] andDay:[_dayArray[dayIndex] integerValue]];
            hourNum = _hourArray.count;
            
            [self configureMinuteArrayWithYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue] day:[_dayArray[dayIndex] integerValue] hour:[_hourArray[hourIndex] integerValue]];
            minuteNUm = _minuteArray.count;
            
        }
            break;
        default: {
            yearNum = _yearArray.count;
            monthNum = _monthArray.count;
            dayNum = [self daysFromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
            hourNum = _hourArray.count;
            minuteNUm = _minuteArray.count;
        }
            break;
    }
    
    return @[@(yearNum),@(monthNum),@(dayNum),@(hourNum),@(minuteNUm)];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel) {
        customLabel = [[UILabel alloc] init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        [customLabel setFont:[UIFont systemFontOfSize:17]];
    }
    NSString *title;
    
    if (component == 0) {
        title = _yearArray[row];
    }
    if (component == 1) {
        title = _monthArray[row];
    }
    if (component == 2) {
        title = _dayArray[row];
    }
    if (component == 3) {
        title = _hourArray[row];
    }
    if (component == 4) {
        title = _minuteArray[row];
    }
    
    customLabel.text = title;
    customLabel.textColor = kDateTextColor;
    return customLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 0) {
        yearIndex = row;
        if (_displayModel) {
            [self configureMonthArray:[_yearArray[yearIndex] integerValue]];
            if (_monthArray.count-1 < monthIndex) {
                monthIndex = _monthArray.count-1;
            }
            
            [self daysFromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
            if (_dayArray.count-1 < dayIndex) {
                dayIndex = _dayArray.count-1;
            }
            
            [self configureHourArrayWithYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue] andDay:[_dayArray[dayIndex] integerValue]];
            if (_hourArray.count-1 < hourIndex) {
                hourIndex = _hourArray.count-1;
            }
            
            [self configureMinuteArrayWithYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue] day:[_dayArray[dayIndex] integerValue] hour:[_hourArray[hourIndex] integerValue]];
            if (_minuteArray.count-1 < minuteIndex) {
                minuteIndex = _minuteArray.count-1;
            }
        }
    }
    if (component == 1) {
        monthIndex = row;
        if (_displayModel) {
            [self daysFromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
            if (_dayArray.count-1 < dayIndex) {
                dayIndex = _dayArray.count-1;
            }
            
            [self configureHourArrayWithYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue] andDay:[_dayArray[dayIndex] integerValue]];
            if (_hourArray.count-1 < hourIndex) {
                hourIndex = _hourArray.count-1;
            }
            
            [self configureMinuteArrayWithYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue] day:[_dayArray[dayIndex] integerValue] hour:[_hourArray[hourIndex] integerValue]];
            if (_minuteArray.count-1 < minuteIndex) {
                minuteIndex = _minuteArray.count-1;
            }
            
        }
    }
    if (component == 2) {
        dayIndex = row;
        if (_displayModel) {
            [self configureHourArrayWithYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue] andDay:[_dayArray[dayIndex] integerValue]];
            if (_hourArray.count-1 < hourIndex) {
                hourIndex = _hourArray.count-1;
            }
            
            [self configureMinuteArrayWithYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue] day:[_dayArray[dayIndex] integerValue] hour:[_hourArray[hourIndex] integerValue]];
            if (_minuteArray.count-1 < minuteIndex) {
                minuteIndex = _minuteArray.count-1;
            }
            
        }
    }
    if (component == 3) {
        hourIndex = row;
        if (_displayModel) {
            [self configureMinuteArrayWithYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue] day:[_dayArray[dayIndex] integerValue] hour:[_hourArray[hourIndex] integerValue]];
            if (_minuteArray.count-1 < minuteIndex) {
                minuteIndex = _minuteArray.count-1;
            }
            
        }
    }
    if (component == 4) {
        minuteIndex = row;
    }
    if (component == 0 || component == 1){
        [self daysFromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
        if (_dayArray.count - 1 < dayIndex) {
            dayIndex = _dayArray.count - 1;
        }
    }
    
    [pickerView reloadAllComponents];
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", _yearArray[yearIndex], _monthArray[monthIndex], _dayArray[dayIndex], _hourArray[hourIndex], _minuteArray[minuteIndex]];
    
    self.scrollToDate = [NSDate date:dateStr withFormat:@"yyyy-MM-dd HH:mm"];
    
    if ([self.scrollToDate compare:self.minLimitDate] == NSOrderedAscending) {
        self.scrollToDate = self.minLimitDate;
        [self getNowDate:self.scrollToDate animated:YES];
    } else if ([self.scrollToDate compare:self.maxLimitDate] == NSOrderedDescending){
        self.scrollToDate = self.maxLimitDate;
        [self getNowDate:self.maxLimitDate animated:YES];
    }
}

#pragma mark privateAction
//滚条标题设置
- (void)addLabelWithName:(NSArray *)nameArr {
    for (id subView in self.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            [subView removeFromSuperview];
        }
    }
    for (int i = 0; i < nameArr.count; i++) {
        CGFloat labelX = _datePicker.width / (nameArr.count * 2) + 4.5 + _datePicker.width / nameArr.count * i;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, _titleLabel.bottom + 5, 15, 15)];
        label.text = nameArr[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = kLineColor;
        [_bgView addSubview:label];
    }
    //分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, _titleLabel.bottom + 25, _bgView.width - 30, 1)];
    lineView.backgroundColor = kLineColor;
    [_bgView addSubview:lineView];
}

//年份变化
- (void)yearChange:(NSInteger)row {
    monthIndex = row % 12;
    //年份状态变化
    if (row - preRow < 12 && row - preRow > 0 && [_monthArray[monthIndex] integerValue] < [_monthArray[preRow % 12] integerValue]) {
        yearIndex++;
    } else if(preRow - row < 12 && preRow - row > 0 && [_monthArray[monthIndex] integerValue] > [_monthArray[preRow % 12] integerValue]) {
        yearIndex--;
    }else {
        NSInteger interval = (row - preRow) / 12;
        yearIndex += interval;
    }
    preRow = row;
}

//通过年月得到正确天数
- (NSInteger)daysFromYear:(NSInteger)year andMonth:(NSInteger)month {
    NSInteger yearNum = year;
    NSInteger monthNum = month;
    BOOL isLeapYear = yearNum % 4 == 0 ? (yearNum % 100 == 0 ? (yearNum % 400 == 0 ?YES : NO) : YES) : NO;
    switch (monthNum) {
        case 1:case 3:case 5:case 7:case 8:case 10:case 12:{
            [self configureDaysArray:31 withYear:yearNum andMonth:monthNum];
            return 31;
        }
        case 4:case 6:case 9:case 11:{
            [self configureDaysArray:30 withYear:yearNum andMonth:monthNum];
            return 30;
        }
        case 2:{
            if (isLeapYear) {
                [self configureDaysArray:29 withYear:yearNum andMonth:monthNum];
                return 29;
            }else{
                [self configureDaysArray:28 withYear:yearNum andMonth:monthNum];
                return 28;
            }
        }
        default:
            break;
    }
    return 0;
}

//设置年份对应月份数组
- (void)configureMonthArray:(NSInteger)year {
    [_monthArray removeAllObjects];
    if (year == kMinYear) {
        for (NSInteger i = 1; i <= 12; i++) {
            if (i >= _minLimitDate.month) {
                [_monthArray addObject:[NSString stringWithFormat:@"%02d", i]];
            }
        }
    } else if (year == kMaxYear) {
        for (NSInteger i = 1; i <= 12; i++) {
            if (i <= _maxLimitDate.month) {
                [_monthArray addObject:[NSString stringWithFormat:@"%02d", i]];
            }
        }
    }
}

//设置月份对应日子数组
- (void)configureDaysArray:(NSInteger)days withYear:(NSInteger)year andMonth:(NSInteger)month {
    [_dayArray removeAllObjects];
    switch (_displayModel) {
        case NotOptionalNotDisplay: {
            if (year == kMinYear && month == _minLimitDate.month) {
                for (NSInteger i = 1; i <= days; i++) {
                    if (i >= _minLimitDate.day) {
                        [_dayArray addObject:[NSString stringWithFormat:@"%02d", i]];
                    }
                }
            } else if (year == kMaxYear && month == _maxLimitDate.month) {
                for (NSInteger i = 1; i <= days; i++) {
                    if (i <= _maxLimitDate.day) {
                        [_dayArray addObject:[NSString stringWithFormat:@"%02d", i]];
                    }
                }
            } else {
                for (NSInteger i = 1; i <= days; i++) {
                    [_dayArray addObject:[NSString stringWithFormat:@"%02d", i]];
                }
            }
        }
            break;
        default: {
            for (NSInteger i = 1; i <= days; i++) {
                [_dayArray addObject:[NSString stringWithFormat:@"%02d",i]];
            }
        }
            break;
    }
}

//设置日子对应小时数组
- (void)configureHourArrayWithYear:(NSInteger)year andMonth:(NSInteger)month andDay:(NSInteger)day {
    [_hourArray removeAllObjects];
    if (year == kMinYear && month == _minLimitDate.month && day == _minLimitDate.day) {
        for (NSInteger i = 0; i < 24; i++) {
            if (i >= _minLimitDate.hour) {
                [_hourArray addObject:[NSString stringWithFormat:@"%02d", i]];
            }
        }
    } else if (year == kMaxYear && month == _maxLimitDate.month && day == _maxLimitDate.day) {
        for (NSInteger i = 0; i < 24; i++) {
            if (i <= _maxLimitDate.hour) {
                [_hourArray addObject:[NSString stringWithFormat:@"%02d", i]];
            }
        }
    } else {
        for (NSInteger i = 0; i < 24; i++) {
            [_hourArray addObject:[NSString stringWithFormat:@"%02d", i]];
        }
    }
}

//设置小时对应分钟数组
- (void)configureMinuteArrayWithYear:(NSInteger)year andMonth:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour {
    [_minuteArray removeAllObjects];
    if (year == kMinYear && month == _minLimitDate.month && day == _minLimitDate.day && hour == _minLimitDate.hour) {
        for (NSInteger i = 0; i < 60; i++) {
            if (i >= _minLimitDate.minute) {
                [_minuteArray addObject:[NSString stringWithFormat:@"%02d", i]];
            }
        }
    } else if (year == kMaxYear && month == _maxLimitDate.month && day == _maxLimitDate.day && hour == _maxLimitDate.hour) {
        for (NSInteger i = 0; i < 60; i++) {
            if (i <= _maxLimitDate.minute) {
                [_minuteArray addObject:[NSString stringWithFormat:@"%02d", i]];
            }
        }
    } else {
        for (NSInteger i = 0; i < 60; i++) {
            [_minuteArray addObject:[NSString stringWithFormat:@"%02d", i]];
        }
    }
}

//滚动到指定的时间位置
- (void)getNowDate:(NSDate *)date animated:(BOOL)animated {
    [self daysFromYear:date.year andMonth:date.month];
    
    if (!_displayModel) {
        yearIndex = date.year - kMinYear;
        monthIndex = date.month-1;
        dayIndex = date.day-1;
        hourIndex = date.hour;
        minuteIndex = date.minute;
    }
    
    //循环滚动时需要用到
    preRow = (self.scrollToDate.year - kMinYear) * 12 + self.scrollToDate.month - 1;
    
    NSArray *indexArray = @[@(yearIndex), @(monthIndex), @(dayIndex), @(hourIndex), @(minuteIndex)];
    
    [self.datePicker reloadAllComponents];
    
    for (NSInteger i = 0; i < indexArray.count; i++) {
        [self.datePicker selectRow:[indexArray[i] integerValue] inComponent:i animated:animated];
    }
}

#pragma mark publicAction
//显示视图
- (void)showWithFatherView:(UIView *)fatherView {
    [fatherView addSubview:self];
    self.center = fatherView.center;
    self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    
    __weak typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        if (_displayModel) {
            _scrollToDate = _minLimitDate;
        }
        weakSelf.maskView.alpha = 1.f;
        weakSelf.alpha = 1.f;
        weakSelf.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
}

//释放视图
- (void)dismiss {
    __weak typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.alpha = 0.f;
        weakSelf.maskView.alpha = 0.f;
        weakSelf.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        [weakSelf.maskView removeFromSuperview];
    }];
}

//遮盖图手势响应
- (void)handleDismiss:(UITapGestureRecognizer *)sender {
    [self dismiss];
}

//取消按钮响应
- (void)cancle:(UIButton *)sender {
    [self dismiss];
}

//确定按钮响应
- (void)complete:(UIButton *)sender {
    self.doneBlock(self.scrollToDate ? _scrollToDate : _minLimitDate);
    [self dismiss];
}

#pragma mark 懒加载
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.frame];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismiss:)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width-60, 248)];
        _bgView.center = self.center;
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width-60, 30)];
        _titleLabel.userInteractionEnabled = NO;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = kLineColor;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    }
    return _titleLabel;
}

- (UIPickerView *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(15, _titleLabel.bottom+21, self.width-90, 120)];
        _datePicker.showsSelectionIndicator = YES;
        _datePicker.delegate = self;
        _datePicker.dataSource = self;
    }
    return _datePicker;
}

- (UIButton *)completeBtn {
    if (!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _completeBtn.frame = CGRectMake(_cancleBtn.right+1, _datePicker.bottom+1, _bgView.width / 2-0.5, 30);
        [_completeBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_completeBtn setTitleColor:kCompleteColor forState:UIControlStateNormal];
        [_completeBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_completeBtn addTarget:self action:@selector(complete:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}

- (UIButton *)cancleBtn {
    if (!_cancleBtn) {
        _cancleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _cancleBtn.frame = CGRectMake(0, _datePicker.bottom+1, _bgView.width / 2-0.5, 30);
        [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:kCancleColor forState:UIControlStateNormal];
        [_cancleBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_cancleBtn addTarget:self action:@selector(cancle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleBtn;
}

- (NSMutableArray *)setArray:(id)mutableArray {
    if (mutableArray) {
        [mutableArray removeAllObjects];
    } else {
        mutableArray = [NSMutableArray array];
    }
    return mutableArray;
}


#pragma mark getter / setter
- (void)setScrollToDate:(NSDate *)scrollToDate {
    _scrollToDate = scrollToDate ? scrollToDate : [NSDate dateWithMinutesFromNow:5];
    [self getNowDate:_scrollToDate animated:YES];
}

@end
