//
//  LoginViewModel.h
//  QSYPersonalRepositoryAll
//
//  Created by qsyMac on 16/6/12.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import "SVProgressHUD.h"
#import "LoginModle.h"
@interface LoginViewModel : NSObject
@property (nonatomic, strong) LoginModle *loginModel;
// 是否允许登录的信号
@property (nonatomic, strong, readonly) RACSignal *enableLoginSignal;

@property (nonatomic, strong, readonly) RACCommand *loginCommand;
@end
