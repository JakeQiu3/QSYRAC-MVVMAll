
//
//  LoginSubViews.m
//  QSYPersonalRepositoryAll
//
//  Created by qsyMac on 16/6/12.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "LoginSubViews.h"
#import "ReactiveCocoa.h"
@implementation LoginSubViews
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        //  账号
        _accountField = [[UITextField alloc] initWithFrame:CGRectNull];
        _accountField.frame = CGRectMake(50, 164, 200, 30);
        _accountField.backgroundColor = [UIColor grayColor];
        _accountField.placeholder = @"请输入6到16位账号";
        [self addSubview:_accountField];
        //  密码
        _pwdField = [[UITextField alloc] initWithFrame:CGRectNull];
        _pwdField.frame = CGRectMake(50, 214, 200, 30);
        _pwdField.secureTextEntry = YES;
        _pwdField.backgroundColor = [UIColor grayColor];
        _pwdField.placeholder = @"请输入6到16位密码";
        [self addSubview:_pwdField];
        //  确认密码
        _confirmPwdField = [[UITextField alloc] initWithFrame:CGRectNull];
        _confirmPwdField.frame = CGRectMake(50, 264, 200, 30);
        _confirmPwdField.secureTextEntry = YES;
        _confirmPwdField.backgroundColor = [UIColor grayColor];
        _confirmPwdField.placeholder = @"请确认密码";
        [self addSubview:_confirmPwdField];
        
        _loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _loginBtn.frame = CGRectMake(40, 314, 200, 30);
        [_loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
        [self addSubview:_loginBtn];
    }
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
 
}

@end
