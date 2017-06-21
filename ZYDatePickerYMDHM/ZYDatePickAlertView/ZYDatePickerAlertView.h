//
//  ZYDatePickerAlertView.h
//  ZYDatePickerYMDHM
//
//  Created by yao on 2017/6/15.
//  Copyright © 2017年 yao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Extension.h"
#import "NSDate+Extension.h"
typedef enum {
    NotOptionalDisplay = 0, //不可选数据显示
    NotOptionalNotDisplay
}DisplayModel;

typedef void(^DoneBlock)(NSDate *doneDate);

@interface ZYDatePickerAlertView : UIView
/**
 限制最小时间（默认当前5分钟）
 */
@property(nonatomic, strong)NSDate *minLimitDate;
/**
 限制最大时间（默认最小时间一年后）
 */
@property(nonatomic, strong)NSDate *maxLimitDate;
/** 
 滚到指定日期 
 */
@property(nonatomic, strong)NSDate *scrollToDate;
/** 
 确定回调 
 */
@property(nonatomic, strong)DoneBlock doneBlock;

- (instancetype)initWithFrame:(CGRect)frame andTitleString:(NSString *)title withDisplayModel:(DisplayModel)displayModel;

- (void)showWithFatherView:(UIView *)fatherView;
@end
