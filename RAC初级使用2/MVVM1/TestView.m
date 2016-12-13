
//
//  TestView.m
//  QSYPersonalRepositoryAll
//
//  Created by qsyMac on 16/6/10.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "TestView.h"
#import "ReactiveCocoa.h"
@implementation TestView
- (instancetype)init {
    self = [super init];
    if (self) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(0, 0, 200, 100);
        [btn setTitle:@"监听按钮的点击" forState:UIControlStateNormal];
        
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {//x 是btn
            [self btnClick:x];
        }];
        
        [self addSubview:btn];
    }
    return self;
}

@end
