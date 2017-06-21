//
//  ViewController.m
//  ZYDatePickerYMDHM
//
//  Created by yao on 2017/6/15.
//  Copyright © 2017年 yao. All rights reserved.
//

#import "ViewController.h"
#import "ZYDatePickerAlertView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)handleShowAlertView:(UIButton *)sender {
    ZYDatePickerAlertView *zyAlertView = [[ZYDatePickerAlertView alloc] initWithFrame:self.view.frame andTitleString:@"时间选择" withDisplayModel:0];
    zyAlertView.minLimitDate = [NSDate dateWithMinutesFromNow:10];
    zyAlertView.maxLimitDate = [[NSDate dateWithMinutesFromNow:10] dateByAddingYears:1];
    zyAlertView.doneBlock = ^(NSDate *doneDate) {
        self.dateLabel.text = [doneDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
    };
    zyAlertView.scrollToDate = self.dateLabel.text ? [NSDate date:_dateLabel.text withFormat:@"yyyy-MM-dd HH:mm"] : zyAlertView.minLimitDate;
    [zyAlertView showWithFatherView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
