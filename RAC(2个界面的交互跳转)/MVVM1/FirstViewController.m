//
//  FirstViewController.m
//  QSYPersonalRepositoryAll
//
//  Created by qsyMac on 16/6/9.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "FirstViewController.h"
#import "SecondViewController.h"
@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBtn];
    // Do any additional setup after loading the view.
}

- (void)setBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(0, 64, 100, 100);
    [btn setTitle:@"第1个跳转" forState:UIControlStateNormal];
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
//        点击按钮执行的方法
        SecondViewController *secondVC = [[SecondViewController alloc] init];
        secondVC.modalPresentationStyle = UIModalPresentationPageSheet;
        //  设置代理信号: 由第2个控制器创建，订阅和发送信号
        secondVC.delegateSignal = [RACSubject subject];
        [secondVC.delegateSignal subscribeNext:^(id x) {
            NSLog(@"点击了通知按钮,顺便看看传的啥值:%@",x);
        }];
        
        
//  =================传值给下一个控制器=========================
        self.passValueSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"我是第一个控制器的值，我要传给下一个控制器"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"信号已经被取消订阅");
            }];
        }];
        
        [self.passValueSignal subscribeNext:^(id x) {
            secondVC.valueStr = x;
            NSLog(@"%@",secondVC.valueStr);
        }];
//   ==========================================================
        
        [self presentViewController:secondVC animated:YES completion:^{
            
        }];
    }];
    [self.view addSubview:btn];
    
}

@end
