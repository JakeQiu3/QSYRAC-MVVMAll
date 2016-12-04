//
//  ViewController.m
//  RpFirst
//
//  Created by 邱少依 on 16/8/29.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Student.h"
#import <ReactiveCocoa/ReactiveCocoa.h>//ReactiveCocoa要求iOS最低版本是8.0,
#import <AFNetworking/AFNetworking.h>
@interface ViewController ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) Student *stu;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *testBtn;
@property (nonatomic, strong) RACDelegateProxy *proxy;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self firstExperience];
    [self secondExperience];
    [self thirdExperience];
    [self fourthExperience];
    [self fifthExperience];
     [self sixthExperience];
     [self seventhExperience];
}
//实现1： person.runBlock().studyBlock().runBlock();
//person.studyBlock().studyBlock().runBlock();
- (void)firstExperience {
    //    1.初级实现
    Person *person = [[Person alloc ] init];
    //    [person  run1];
    //    [person study1];
    //    2.最终实现:b 返回本对象; block实现()
    
    //    [[[person run2] study2] run2];
    //    [[[person study2] study2] run2];
    //  此行仅仅执行run和study  ->但未执行block [person runBlock]; [person studyBlock];
    //
    person.runBlock().studyBlock().runBlock();
    person.studyBlock().studyBlock().runBlock();
    
}
//实现2：监控Student name的属性变化:   在touchesBegan中改变name的值，并将变化体现在UILabel上，实现KVO的监控功能
- (void)secondExperience {
    [self.view addSubview:self.nameLabel];
    @weakify(self)
    [RACObserve(self.stu, name) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        self.nameLabel.text = x;// 首次即加载，需要信号()来触发
    }];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.stu.name = [NSString stringWithFormat:@"邱少 %d",arc4random_uniform(3000)];
    [self.stu testDelegate];//代理手动触发方法
}

//实现3：监控uitextfield text的属性变化: 将变化体现在UILabel上，实现实时的KVO的监控功能
- (void)thirdExperience {
    [self.view addSubview:self.nameTextField];
    @weakify(self)
    [[self.nameTextField rac_textSignal] subscribeNext:^(id x) {
        @strongify(self)
        self.nameLabel.text = x;
    } error:^(NSError *error) {
    }];
}
//实现4： 多文本框组合的处理
- (void)fourthExperience {
    [self.view addSubview:self.passwordTextField];
    id signals  = @[[self.nameTextField rac_textSignal],[self.passwordTextField rac_textSignal]];
    @weakify(self)
    [[RACSignal combineLatest:signals] subscribeNext:^(RACTuple *x) {// RACTuple rac的数组
        @strongify(self);
        NSString *name = [x first];
        NSString *pass = [x second];
        if (name.length > 0 && pass.length >0) {
            //  设置按钮可点击
            self.nameLabel.text = [NSString stringWithFormat:@"我是名:%@ 我是密码:%@",name,pass];
        } else {
            // 设置按钮不可点击
        }
    } error:^(NSError *error) {
    }];
}
// 实现5. UIbutton的监听:使namelabel的text变化
- (void)fifthExperience {
    [self.view addSubview:self.testBtn];
    @weakify(self)
    [[self.testBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        self.nameLabel.text = self.testBtn.titleLabel.text;
    } error:^(NSError *error) {
        
    }];
}

// 实现6：执行代理方法:nameTextField的输入字符时，输入回车或者点击键盘的回车键使passWordTextField变为第一响应者（即输入光标移动到passWordTextField处）
- (void)sixthExperience {
  @weakify(self)
    // 1. 定义协议
    self.proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(wojiushiceyiceDelegagte)];//或者系统代理UITextFieldDelegate
    // 2. 代理去注册文本框的监听方法
    [[self.proxy rac_signalForSelector:@selector(wojiuceyice)] subscribeNext:^(id x) {// 或者系统方法textFieldShouldReturn:的实现
        @strongify(self)
        NSLog(@"我就测一测代理是否执行了？");
//        if (self.nameTextField.hasText) {
//            [self.passwordTextField becomeFirstResponder];
//        }
    } error:^(NSError *error) {
    }];
    self.stu.delegate = (id<wojiushiceyiceDelegagte>)self.proxy;//或者自定义代理wojiushiceyiceDelegagte
}


// 实现7：点击textFile时，系统键盘会发送通知，打印出通知的内容
- (void)seventhExperience {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"notificationDemo : %@", x);
    } error:^(NSError *error) {
    }];
}
// getter
- (Student *)stu {
    if (!_stu) {
        _stu = [[Student alloc] init];
    }
    return _stu;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        _nameLabel.backgroundColor = [UIColor lightGrayColor];
        _nameLabel.center = self.view.center;
    }
    return _nameLabel;
}

- (UITextField *)nameTextField {
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc] init];
        _nameTextField.backgroundColor = [UIColor orangeColor];
        _nameTextField.frame = CGRectMake(100, 164, 150, 30);
    }
    return _nameTextField;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.backgroundColor = [UIColor orangeColor];
        _passwordTextField.frame = CGRectMake(100, 200, 150, 30);
    }
    return _passwordTextField;
}

- (UIButton *)testBtn {
    if (!_testBtn) {
        _testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _testBtn.frame = CGRectMake(100,CGRectGetMaxY(self.nameLabel.frame), 100, 30);
        [_testBtn setTitle:@"测试button" forState:UIControlStateNormal];
        [_testBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        _testBtn.showsTouchWhenHighlighted = YES;
    }
    return _testBtn;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
