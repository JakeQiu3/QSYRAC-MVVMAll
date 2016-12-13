//
//  ViewController.m
//  Reactive Login
//
//  Created by 邱少依 on 16/9/2.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "ViewController.h"
#import "LoginRequestService.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *userName;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *passwordName;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (nonatomic, strong) RACDelegateProxy *proxy;// rac的代理 ：作用 ->取代系统或自定义的所有的代理。
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLoginSignal];
    [self setFirstResponser];
    [self loginBtnTouch];
}

- (void)setLoginSignal {
    // 1、当用户在名字和密码框均中输入内容，登陆才可点击；2、当名字或密码输入的长度都大于6时，输入框背景变色;
    id signals = @[[self.userName rac_textSignal],[self.passwordName rac_textSignal]];
    @weakify(self)
    //    combineLatest作用： 聚合多个信号为1个
    //    [[RACSignal combineLatest:signals] subscribeNext:^(RACTuple *x) {
    //        @strongify(self)
    //        NSString *userName = [x first];
    //        NSString *password = [x second];
    //        if ([userName length] > 0 && [password length] > 0) {
    //            self.loginBtn.enabled = YES;
    //        } else self.loginBtn.enabled = NO;
    //    } error:^(NSError *error) {
    //    }];
    
    //   图1 或者采用 signal -> filter -> subscribeNext ：filter作用 是过滤后的YES情况处理
    [[[RACSignal combineLatest:signals] filter:^BOOL(RACTuple *value) {
        @strongify(self)
        NSString *userName = [value first];
        NSString *password = [value second];
        BOOL userNameAndPassword = [userName length]>0 && [password length]>0;
        if (userNameAndPassword) {
            self.loginBtn.enabled = YES;
        } else self.loginBtn.enabled = NO;
        return  userNameAndPassword;
    }] subscribeNext:^(RACTuple *value) {
    } error:^(NSError *error) {
    }];
    //  图2 map作用: 类型转化  特点：创建一个和原来一模一样的信号，block中的返回值为下一个block的参数。
    //    [[[self.userName.rac_textSignal map:^id(NSString *value) {
    //        return @([value length]>6);
    //    }] map:^id(NSNumber *value) {
    //        return [value isEqualToNumber:@1] ?[UIColor clearColor] : [UIColor orangeColor];
    //    }] subscribeNext:^(id x) {
    //        self.userName.backgroundColor = x;
    //    }];
    [[[[RACSignal combineLatest:signals] map:^id(RACTuple *value) {
        NSString *name = [value first];
        NSString *password = [value second];
        id isCorrectArr = @[@([name length]>3),@([password length]>3)];
        return isCorrectArr;
    }] map:^id(NSArray *value) {
        NSNumber *firstNum = [value firstObject];
        NSNumber *secondNum = [value objectAtIndex:1];
        UIColor *colorFirst;
        UIColor *colorSecond;
        [firstNum isEqualToNumber:@1] ? (colorFirst =  [UIColor clearColor]):(colorFirst = [UIColor orangeColor]);
        [secondNum isEqualToNumber:@1] ? (colorSecond =  [UIColor clearColor]):(colorSecond = [UIColor orangeColor]);
        id numColorDic = @{@"userName":colorFirst,@"password":colorSecond};
        return numColorDic;
    }] subscribeNext:^(NSDictionary *value) {
        @strongify(self)
        self.userName.backgroundColor = [value objectForKey:@"userName"];
        self.passwordName.backgroundColor = [value objectForKey:@"password"];
    }];
}

- (void)setFirstResponser {
    @weakify(self)
    self.proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(UITextFieldDelegate)];
    [[self.proxy rac_signalForSelector:@selector(textFieldShouldReturn:)] subscribeNext:^(id x) {
        @strongify(self)
        [self.passwordName becomeFirstResponder];
    }];
    self.userName.delegate = (id<UITextFieldDelegate>)self.proxy;
}
//  doNext作用： 顺序执行
//  flattenMap作用：同级交换。直接生成了一个新的信号，这两个信号并没有先后顺序关系，属于同层次的平行关系。
- (void)loginBtnTouch {
    @weakify(self)
    [[[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        @strongify(self)
        [self.view endEditing:YES];
        self.loginBtn.enabled = NO;
    }] flattenMap:^id(id x) {
        @strongify(self)
        return [self creatLoginSignal];
    }] subscribeNext:^(NSNumber *logIn) {
        @strongify(self)
        self.loginBtn.enabled = YES;
        BOOL success =[logIn boolValue];
        if(success){
            @strongify(self)
            // 执行页面的跳转
            Class cls;
            cls = NSClassFromString(@"NextPageViewController");
            UIViewController *vc = [[cls alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        } else return;
    }];
}

- (RACSignal *)creatLoginSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [LoginRequestService logInWithUsername:self.userName.text password:self.passwordName.text complete:^(BOOL success) {
            [subscriber sendNext:@(success)];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
