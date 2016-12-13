
//
//  LoginViewModel.m
//  QSYPersonalRepositoryAll
//
//  Created by qsyMac on 16/6/12.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "LoginViewModel.h"

@implementation LoginViewModel

- (LoginModle *)loginModel {
    if (!_loginModel) {
        _loginModel = [[LoginModle alloc] init];
    }
    return _loginModel;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialBind];
    }
    return self;
}

//初始化绑定
- (void)initialBind {
    
    // 监听登录的 enabled 属性改变，组合成一个信号再聚合数据
    _enableLoginSignal = [RACSignal combineLatest:@[RACObserve(self.loginModel, name),RACObserve(self.loginModel, password),RACObserve(self.loginModel, confirmword)] reduce:^id(NSString *name,NSString *password,NSString *confirmPassword){
        //  button的可点击要求是：name必须 6到16位，密码6到16位数，确认密码和密码相同
        if ([name length] >= 6 && [name length] <= 16) {
            if (password.length >= 6 && password.length <= 16) {
                if ([confirmPassword isEqualToString:password]) {
                    return @(YES);
                }
            }
        }
        return @(NO);
    }];
    
    //   处理登录按钮业务逻辑
    _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"点击了登录");
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            //            网络加载
            // 模仿网络延迟
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [subscriber sendNext:@"登录成功"];
                [subscriber sendCompleted];
            });
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"取消订阅信号");
            }];
        }];
    }];
    //    获取到订阅RACCommand中的信号 最新发送的数据
    [_loginCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        //        执行完52行代码后执行该block
        NSLog(@"最新的信号的数据%@",x);
    }];
    // 监听命令是否执行完毕,默认再会来一次，可以直接跳过，skip表示跳过第一次信号。
    [[_loginCommand.executing skip:1] subscribeNext:^(id x) {
        if ([x isEqualToNumber:@(YES)]) {
            // 正在登录ing...
            // 用蒙版提示
            NSLog(@"正在登录...");
            [SVProgressHUD showWithStatus:@"正在登录..."];
            
        } else {
            // 登录成功
            // 隐藏蒙版
            NSLog(@"登录成功");
            [SVProgressHUD dismiss];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"登录成功"];
            });
        }
    }];
}

- (RACSignal *)searchWithKeyword:(NSString *)keyword {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 模拟网络请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [subscriber sendNext:keyword];
            [subscriber sendCompleted];
        });
        
        return nil;
    }];
}

@end
