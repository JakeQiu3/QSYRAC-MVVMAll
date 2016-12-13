//
//  LoginViewController.m
//  QSYPersonalRepositoryAll
//
//  Created by qsyMac on 16/6/12.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginModle.h"
#import "LoginViewModel.h"
#import "LoginSubViews.h"
#import "ReactiveCocoa.h"

@interface LoginViewController ()
@property (nonatomic, strong) LoginViewModel *loginViewModel;
@property (nonatomic, strong)LoginSubViews *loginSubviews;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//   加载子view
    [self setUpSubviews];
//  绑定model
    [self bindModel];
    // Do any additional setup after loading the view.
}

- (void)setUpSubviews {
    _loginSubviews = [[LoginSubViews alloc] init];
    _loginSubviews.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:_loginSubviews];
}

//懒加载 VM
- (LoginViewModel *)loginViewModel {
    if (!_loginViewModel) {
        _loginViewModel = [[LoginViewModel alloc] init];
    }
    return _loginViewModel;
}
// VM的model的属性信号 和 V中的控件属性 绑定
- (void)bindModel {
    // 给模型的属性绑定信号
    // 只要账号的文本框改变，就会给account赋值
    RAC(self.loginViewModel.loginModel,name) = _loginSubviews.accountField.rac_textSignal;
    
    RAC(self.loginViewModel.loginModel,password) = _loginSubviews.pwdField.rac_textSignal;
    
    RAC(self.loginViewModel.loginModel,confirmword) = _loginSubviews.confirmPwdField.rac_textSignal;
    
    // 绑定登录按和搜索的钮状态的信号
    RAC(_loginSubviews.loginBtn,enabled) = self.loginViewModel.enableLoginSignal;
  
     //  登录按钮的操作方法和网络请求
    [[_loginSubviews.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"点击登陆按钮");
        // 执行登录事件
        [self.loginViewModel.loginCommand execute:x];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
