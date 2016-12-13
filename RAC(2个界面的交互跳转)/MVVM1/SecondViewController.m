//
//  SecondViewController.m
//  QSYPersonalRepositoryAll
//
//  Created by qsyMac on 16/6/9.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "SecondViewController.h"
@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBtn];
}

- (void)setBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(100, 64, 200, 100);
    [btn setTitle:@"第2个" forState:UIControlStateNormal];
    if ([_valueStr length]>0) {
         [btn setTitle:self.valueStr forState:UIControlStateNormal];
    }
    [btn addTarget:self action:@selector(notice:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)notice:(UIButton *)btn {
    // 通知第一个控制器，告诉它，按钮被点了
    // 判断代理信号是否有值
    if (self.delegateSignal) {
        // 有值，才需要通知
        [self.delegateSignal sendNext:@"随便传个值试试"];
    }
}

@end
