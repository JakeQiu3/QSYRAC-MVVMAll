//
//  MVVMViewController.m
//  QSYPersonalRepositoryAll
//
//  Created by qsyMac on 16/6/5.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "MVVMViewController.h"
#import "ReactiveCocoa.h"
#import "TestView.h"
#import <ReactiveCocoa/RACReturnSignal.h>//测试bind使用
@interface MVVMViewController ()
//  ReactiveCocoa核心方法bind：把当前一步操作和下一步操作提前绑定好。
// 数据展示到控件上，之前都是重写控件的setModel方法；RAC中创建控件后，直接绑定数据。
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)RACCommand *command;
@property (nonatomic, strong)RACSubject *testSubject;

@end

@implementation MVVMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
# warning 少
    //    信号创建原则：1.若已经执行 subscribeNext，遇到sendNext 就会回跳到 subscribeNext并执行其内block方法。2. 若replaySubject则可先执行sendNext ，遇到subscribeNext就会立即执行和其中的block方法。
    //    创建信号 3种方式
    [self creatSignal];
    [self subject];
    [self replaySubject];
    //    遍历字典和转模型
    [self convertArrayAndDictionary];
    // 检测button点击方法网络请求和
    [self btnClickAndRequestNet];//exect
    //    避免订阅信号，重复发送信号
    [self avoidMultiSendNextSignal];
    //  替代OC，常用的消息
    [self commonMessage];
    //  常用的宏
    [self commonMacro];
    //  rac进阶使用
    [self superiorBindUse];
    [self superiorMapUse];
    [self superiorConcatUse];
    [self superiorThenUse];
    [self superiorMergeUse];
    [self superiorZipWithUse];
    [self superiorCombineLatestUse];
    [self superiorReduceUse];
    [self superiorFilterAndIgnoreAndDistinctUse];
    [self superiorTakeUse];
    //     ReactiveCocoa操作方法之秩序
    [self superiorDoNextUse];
    //    ReactiveCocoa操作方法之线程
    [self superiorDeliverOnUse];
    [self superiorTimeUse];
    [self superiorRepeatUse];
    // RACSignal使用步骤：
    // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
    // 2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 3.发送信号 - (void)sendNext:(id)value
    
    //RACSignal底层实现：
    // 1.创建信号，首先把didSubscribe保存到信号中，还不会触发。
    // 2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock
    // 2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
    // 2.1 subscribeNext内部会调用siganl的didSubscribe
    // 3.siganl的didSubscribe中调用[subscriber sendNext:@1];
    // 3.1 sendNext底层其实就是执行subscriber的nextBlock
    
    //4.  RACSubscriber：订阅者，用于sendNext，发送信号。这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据。
    //  5.  RACDisposable:用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。
    //  6. RACSubject ：信号提供者，自己可以充当信号，又能发送信号。
    //  7. RACTuple:元组类,类似NSArray,用来包装值.
    
    //  8. RACSequence:RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典。
    //    9. RACCommand:RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程
    //  10.  RACScheduler:RAC中的队列，用GCD封装的;
    //    RACUnit :表⽰stream不包含有意义的值,也就是看到这个，可以直接理解为nil;RACEvent: 把数据包装成信号事件(signal event)。它主要通过RACSignal的-materialize来使用，然并卵。
    
    
}

- (void)creatSignal {
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 当 subscribeNext 订阅信号，就会调用该 block
        [subscriber sendNext:@1];
        // 如果发送信号完成或者发送错误时，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            // 该block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            // 执行完Block后，当前信号就不ZAi被订阅了。
            NSLog(@"信号被销毁");
        }];
    }];
    // 3.subscribeNext订阅信号,才会激活信号：并跳转到 sendNext 发送信号： 再跳转到订阅信号subscribeNext 的block中
    [signal subscribeNext:^(id x) {
        //当 sendNext执行后，就会调用block.
        NSLog(@"接收到数据:%@",x);
    }];
}

//- (void)test {
//    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@1];
//        [subscriber sendCompleted];
//        return [RACDisposable disposableWithBlock:^{
//            NSLog(@"取消订阅号");
//        }];
//    }];
//    [signal subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//}
// 场景：按顺序执行3个block
- (void)subject {
    // RACSubject使用步骤
    // 1.创建信号 :[RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.订阅信号 :- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 3.发送信号 :sendNext:(id)value
    
    // RACSubject底层实现：
    // 1.调用subscribeNext订阅信号，把所有订阅者保存起来，并且订阅者的nextBlock已经赋值了。
    // 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    
    RACSubject *subject = [RACSubject subject];
    
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者：%@",x);
    }];
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者：%@",x);
    }];
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第三个订阅者：%@",x);
    }];
    
#warning 少 常被用来写在另一个控制器中，来执行block：实现业务逻辑。
    [subject sendNext:@"我就是刚才订阅的信号"];
    [subject sendCompleted];
}

//- (void)testSubject {
//    RACSubject *subject = [RACSubject subject];
//    [subject subscribeNext:^(id x) {
//        NSLog(@"1:%@",x);
//    }];
//    [subject subscribeNext:^(id x) {
//        NSLog(@"2:%@",x);
//    }];
//    [subject subscribeNext:^(id x) {
//        NSLog(@"3:%@",x);
//    }];
//    [subject sendNext:@"我就是我"];
//    [subject sendCompleted];
//}

- (void)replaySubject {
    // RACReplaySubject使用步骤:
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
#warning 少  特殊的地方： 2.可以先订阅信号，也可以先发送信号。
    // 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 2.2 发送信号 sendNext:(id)value
    
    // RACReplaySubject:底层实现和RACSubject不一样。
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    // 也就是先保存值，在订阅值。
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    //    [replaySubject subscribeNext:^(id x) {
    //
    //        NSLog(@"第一个订阅者接收到的数据%@",x);
    //    }];
    //
    //    [replaySubject subscribeNext:^(id x) {
    //
    //        NSLog(@"第二个订阅者接收到的数据%@",x);
    //    }];
    
    [replaySubject sendNext:@1];
    [replaySubject sendNext:@2];
    
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第一个订阅者接收到的数据%@",x);
    }];
    
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第二个订阅者接收到的数据%@",x);
    }];
}
//
//- (void)play {
//    RACReplaySubject *play = [RACReplaySubject subject];
//    [play sendNext:@1];
//    [play sendNext:@2];
//    [play subscribeNext:^(id x) {
//        NSLog(@"1");
//    }];
//    [play subscribeNext:^(id x) {
//        NSLog(@"2");
//    }];
//}

- (void)convertArrayAndDictionary {
    NSArray *numbers = @[@1,@2,@3];
    NSDictionary *dic = @{@"a":@1,@"b":@2,@"c":@3};
    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    // 作用：遍历整个数组和字典
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"遍历整个数组%@",x);
    }];
    
    [dic.rac_keySequence.signal subscribeNext:^(id x) {
        NSLog(@"遍历整个字典的key：%@",x);
    }];
    [dic.rac_valueSequence.signal subscribeNext:^(id x) {
        NSLog(@"遍历整个字典的value：%@",x);
    }];
    [dic.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"遍历整个字典：%@",x);
    }];
    //  作用：  字典转模型
    
    // OC写法   NSString *filePath = [[NSBundle mainBundle]pathForResource:@"flags.plist" ofType:nil];
    //    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    //    NSMutableArray *itemsArray = [NSMutableArray array];
    //     _dataArray = itemsArray;
    //    for (NSDictionary *dic in array) {
    //        MOdel *model  = [Model modelWithDic:dic];
    //        [itemsArray addObject:model];
    //    }
    
    // RAC写法
    //    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"flags.plist" ofType:nil];
    //    NSArray *dataArray = [NSArray arrayWithContentsOfFile:filePath];
    //    NSMutableArray *itemsArray = [NSMutableArray array];
    //    _dataArray = itemsArray;
    //    [dataArray.rac_sequence.signal subscribeNext:^(id x) {
    //        SomeModel *model  = [SomeModel someModelWithDic:x];
    //        [itemsArray addObject:model];
    //    }];
    //    RAC 高级写法
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"flags.plist" ofType:nil];
    NSArray *dataArray = [NSArray arrayWithContentsOfFile:filePath];
    dataArray = @[@{@"a":@1,@"b":@2},@{@"c":@3,@"d":@4},];
    NSArray *itemsArray = [[dataArray.rac_sequence map:^id(id value) {
        return value;
        // 转模型： return [SomeModel someModelWithDic:value];
    }] array];
    NSLog(@"测试最终的模型数组：%@",itemsArray);
}

//- (void)TestconvertArrayAndDictionary {
//    NSArray *array = @[@1,@2,@3];
//    NSDictionary *dic = @{@"a":@1,@"b":@2};
//    [array.rac_sequence.signal subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    [dic.rac_sequence.signal subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    [dic.rac_keySequence.signal subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    [dic.rac_valueSequence.signal subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    //    转模型1
//    //    NSArray *dataArray = @[@{@"a":@1,@"b":@2},@{@"c":@3,@"d":@4}];
//    //    NSMutableArray *tempArray = @[].mutableCopy;
//    //    [dataArray.rac_sequence.signal subscribeNext:^(id x) {
//    //        SomeModel *model = [SomeModel someModelWithDic:x];
//    //        [tempArray addObject:model];
//    //  }];
//
//    //    转模型2
////    NSArray *dataArray = @[@{@"a":@1,@"b":@2},@{@"c":@3,@"d":@4}];
////    NSArray *itemsArray = [[dataArray.rac_sequence map:^id(id value) {
////        return [SomeModel someModelWithDic:value];
////    }] array];
//}

- (void)btnClickAndRequestNet {
    // 一、RACCommand使用步骤:
    // 1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
    // 2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
    // 3.执行命令 - (RACSignal *)execute:(id)input
    
    // 二、RACCommand使用注意:
    // 1.signalBlock必须要返回一个信号，不能传nil.
    // 2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
    // 3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
    // 4.RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的。
    
    // 三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
    // 1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
    // 2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。
    
    // 四、如何拿到RACCommand中返回信号发出的数据。
    // 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
    // 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
    
    // 五、监听当前命令是否正在执行executing
    
    // 六、使用场景,监听按钮点击，网络请求
    
    //按照打印结果，执行的顺序：执行命令->正在执行->请求数据->信号被取消->执行完成
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"执行命令%@",input);
        // 若无需信号，可创建空信号,必须返回信号，而不是nil，return [RACSignal empty];
        // 2.创建信号,用来传递数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"请求数据"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"信号被取消");
            }];
        }];
    }];
    // 强引用命令，不要被销毁，否则接收不到数据
    _command = command;
    // 3.初级用法：订阅RACCommand中的信号
//    [command.executionSignals subscribeNext:^(id x) {
//        [x subscribeNext:^(id x) {
//            NSLog(@"%@",x);
//        }];
//    }];
    
    //  3.RAC高级用法：订阅RACCommand中的信号
    // switchToLatest:用于signal of signals获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
        [command.executionSignals.switchToLatest subscribeNext:^(id x) {
            NSLog(@"最新的信号的数据%@",x);
        }];
    
    
    // 4.监听命令是否执行完毕,默认再会来一次，可以直接跳过，skip表示跳过第一次信号。
    [[command.executing skip:1] subscribeNext:^(id x) {
        NSLog(@"%@",x);
        if ([x boolValue] == YES) {
            NSLog(@"正在执行");
        } else {
            NSLog(@"执行完成");
        }
    }];
#warning 少 5.执行命令: 常被写在控制器中
    [_command execute:@1];
    
}

//- (void)testBtnClickAndRequestNet {
//    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//        NSLog(@"执行命令%@",input);
////        return [RACSignal empty];
//        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            [subscriber sendNext:@"请求数据"];
//            [subscriber sendCompleted];
//            return [RACDisposable disposableWithBlock:^{
//                NSLog(@"已取消订阅信号");
//            }];
//        }];
//    }];
//
//    _command = command;
//
////    [_command.executionSignals subscribeNext:^(id x) {
////        [x subscribeNext:^(id x) {
////            NSLog(@"%@",x);
////        }];
////    }];
//    [_command.executionSignals.switchToLatest subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//
//    [[_command.executing skip:1] subscribeNext:^(id x) {
//        if ([x boolValue] == YES) {
//            NSLog(@"正在执行");
//        } else {
//            NSLog(@"执行完成");
//        }
//    }];
//
//    [_command execute:@1];
//
//}

- (void)avoidMultiSendNextSignal {
    //  RACMulticastConnection:用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理。
    // RACMulticastConnection使用步骤:
    // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
    // 2.创建连接 RACMulticastConnection *connect = [signal publish];
    // 3.订阅信号,注意：订阅的不在是之前的信号，而是连接的信号。 [connect.signal subscribeNext:nextBlock]
    // 4.连接 [connect connect]
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求");
        [subscriber sendNext:@"发送一次请求"];
        [subscriber sendCompleted];
        return nil;
    }];
    ////    订阅信号
    //    [signal subscribeNext:^(id x) {
    //        NSLog(@"接收数据%@",x);
    //    }];
    //
    ////    订阅信号
    //    [signal subscribeNext:^(id x) {
    //
    //        NSLog(@"再次接收数据%@",x);
    //
    //    }];
#warning 仅仅按照上面的执行，运行结果会执行两遍发送请求，也就是每次订阅都会发送一次请求
    
    RACMulticastConnection *connection = [signal publish];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"订阅者一信号");
    }];
    
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"订阅者二信号");
    }];
    
    // 4.连接,激活信号
    [connection connect];
    
}

//- (void)testAvoidMultiSendNextSignal {
//    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@"请求数据"];
//        [subscriber sendCompleted];
//        return nil;
//    }];
//    RACMulticastConnection *connection = [signal publish];
//
//    [connection.signal subscribeNext:^(id x) {
//        NSLog(@"sendNext后执行订阅1");
//    }];
//
//    [connection.signal subscribeNext:^(id x) {
//         NSLog(@"sendNext后执行订阅2");
//    }];
//
//    [connection connect];
//}

- (void)commonMessage {
    TestView *testView = [[TestView alloc]init];
    testView.frame = CGRectMake(100, 64, 200, 100);
    [self.view addSubview:testView];
// 见TestView 1.rac中代替代理:btn的只要调用@selector(btnClick:) 方法，就会执行  订阅信号，执行代理方法
    [[testView rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id x) {
        NSLog(@"代理方法执行:我点击按钮");
    }];
    
    //   2.代替KVO :
    [[testView rac_valuesAndChangesForKeyPath:@"center" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
        NSLog(@"观察属性的变化：%@",x);
    }];
    //  3. 监听button事件:
    UIButton *btn;
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"按钮被点击了");
    }];
    //  4.用于监听某个通知发出。
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"键盘弹出");
    }];
    //   5.监听文本框文字改变变:textField.rac_textSignal 信号
    UITextField *textField;
    [textField.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"文字改变了%@",x);
    }];
    
    // 6. 处理当界面有多次请求时，需要都获取到数据时，才能展示界面 : 当传入的Signals(信号数组)，每一个signal都至少sendNext过一次，就会去触发第一个selector参数的方法。
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"发送第1个请求"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"发送第2个请求"];
        [subscriber sendCompleted];
        return nil;
    }];
    // 使用注意：有几个信号，下面方法中参数1的方法就对应几个参数，每个参数对应信号发出的数据。
    [self rac_liftSelector:@selector(updateUIWithR1:R2:) withSignalsFromArray:@[signal1,signal2]];
    
}
// 更新UI
- (void)updateUIWithR1:(id)data R2:(id)data1
{
    NSLog(@"更新UI%@  %@",data,data1);
}

- (void)commonMacro {
    UITextField *field;
    
    //  RAC(<#TARGET, ...#>)
    //  作用：用于给某个对象的某个属性绑定，例如：只要文本框文字改变，就会修改label的文字
    RAC(field,text) = field.rac_textSignal;
    
    //    RACObserve(<#TARGET#>, <#KEYPATH#>):
    //  作用：  监听某个对象的某个属性,返回的是信号。
    [RACObserve(field, center) subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //  若引用和强引用:等效于下面2种
    //    @weakify(self);
    //
    //    @strongify(self);
    __weak __typeof(self)weakSelf = self;
    __strong __typeof(weakSelf)strongSelf = weakSelf;
   
    //  RACTuplePack(<#...#>)：把数据包装成RACTuple（元组类）
    RACTuple *tuple = RACTuplePack(@"测试",@20);
    //  RACTupleUnpack(<#...#>):把RACTuple（元组类）解包成对应的数据。
    RACTupleUnpack(NSString *name,NSNumber *number) = tuple;
    
}

- (void)superiorBindUse {
    UITextField *field;
    [field.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    // 等效于下面的bind底层实现的方法
    // bind方法使用步骤:
    // 1.传入一个返回值RACStreamBindBlock的block。
    // 2.描述一个RACStreamBindBlock类型的bindBlock作为block的返回值。
    // 3.描述一个返回结果的信号，作为bindBlock的返回值。
    // 注意：在bindBlock中做信号结果的处理。
    [[field.rac_textSignal bind:^RACStreamBindBlock{
        return ^RACStream *(id value,BOOL *stop) {
            //      当信号有新的值发出，就会来到这个block
            return [RACReturnSignal return:[NSString stringWithFormat:@"输出:%@",value]];
        };
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

- (void)superiorMapUse {
    //   flattenMap，Map: 于把源信号内容映射成新的内容
    //    FlatternMap和Map的区别:block的返回值不同。 1.FlatternMap中的Block返回信号; map 返回id。 2.开发中，如果信号发出的值不是信号，映射一般使用Map；如果信号发出的值是信号，映射一般使用FlatternMap。
    UITextField *field;
    [[field.rac_textSignal flattenMap:^RACStream *(id value) {
        //        // block什么时候 : 源信号发出的时候，就会调用这个block。
        return [RACReturnSignal return:[NSString stringWithFormat:@"输出%@",value]];
    }] subscribeNext:^(id x) {
        // 订阅绑定信号，每当flattenMap返回信号发出内容，做完处理，就会调用这个block。
        NSLog(@"%@",x);
    }];
    
    [[field.rac_textSignal map:^id(id value) {
        // 当源信号发出，就会调用这个block，修改源信号的内容
        // 返回值：就是处理完源信号的内容。
        return [NSString stringWithFormat:@"输出:%@",value];
    }] subscribeNext:^(id x) {
        //        每当map返回信号发出内容
        NSLog(@"%@",x);
        
        
    }];
#warning 少  信号的信号的使用
    RACSubject *subject1 = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    [[subject1 flattenMap:^RACStream *(id value) {
        // 当subject1的signal发出信号才会调用
        return value;
    }] subscribeNext:^(id x) {
        // 也就是flattenMap返回的信号发出内容，才会调用。
        NSLog(@"%@",x);
    }];
    //    信号的信号发出
    [subject1 sendNext:subject2];
    //    信号发送的内容
    [subject2 sendNext:@1];
    [subject2 sendCompleted];
    
    
}

- (void)superiorConcatUse {
    //  concat:按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号。
    //    执行顺序： 1，2，3，4，5，6
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"6.信号A已经被取消订阅");
        }];
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"2"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"5.信号B已经被取消订阅");
        }];
    }];
    RACSignal *signalC = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"3"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"4.信号B已经被取消订阅");
        }];
    }];
    //    B在A后执行,C在B后执行
    RACSignal *concatSignal = [signalA concat:[signalB concat:signalC]];
    
    [concatSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

- (void)superiorThenUse {
    //    then:用于连接两个信号，当第1个信号完成，才会连接then返回的信号。
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1=="];
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"2==="];
            [subscriber sendCompleted];
            return nil;
        }];
    }]
     subscribeNext:^(id x) {
         // 只能接收到第二个信号的值，也就是then返回信号的值,才会执行block
         NSLog(@"%@",x);
     }];
}

- (void)superiorMergeUse {
    //    merge:把多个信号合并为一个信号，按照合并的顺序，逐个任何一个信号有新值的时候，就会调用
    //    x执行顺序： 1，2，3
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@2];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signalC = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@3];
        [subscriber sendCompleted];
        return nil;
    }];
    // 合并信号,任何一个信号发送数据，都能监听到.
    RACSignal *mergeSignal = [signalA merge:[signalB merge:signalC]];
    [mergeSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

- (void)superiorZipWithUse {
    //    zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容后，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@2];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *zipSignal = [signalA zipWith:signalB];
    [zipSignal subscribeNext:^(id x) {
        // 此时的x为元祖，可理解成数组->  [1,2]
        NSLog(@"%@",x);
    }];
}

- (void)superiorCombineLatestUse {
    //    combineLatest:将多个信号合并起来，并且拿到第1个信号发送的最新的值,和接下来的信号的值，必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号。
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@2];
        [subscriber sendNext:@3];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *combineSignal = [signalA combineLatestWith:signalB];
    [combineSignal subscribeNext:^(id x) {
        // 此时的x为元祖，可理解成数组->  按照上面的操作结果是[1,2]，然后是 [1,3]
        NSLog(@"%@",x);
    }];
}

- (void)superiorReduceUse {
    //   reduce聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@2];
        [subscriber sendCompleted];
        return nil;
    }];
    //    先组合信号再聚合
    RACSignal *reduceSignal = [RACSignal combineLatest:@[signalA,signalB] reduce:^id (NSNumber *num1,NSNumber *num2){
        return [NSString stringWithFormat:@"%@%@",num1,num2];
    }];
    
    [reduceSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

- (void)superiorFilterAndIgnoreAndDistinctUse {
    //    filter:过滤信号，使用它可以获取满足条件的信号; ignore:忽略完某些值的信号；distinctUntilChanged:当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
    UITextField *field = [[UITextField alloc] init];
    field.backgroundColor = [UIColor grayColor];
    field.placeholder = @"请输入内容";
    field.frame = CGRectMake(100, 264, 100, 30);
    field.textColor = [UIColor greenColor];
    [self.view addSubview:field];
    
    //  每次信号发出，会先执行过滤条件判断,当为yes时继续向下执行; 忽略某些值的信号；distinctUntilChanged 刷新UI经常使用，只有两次数据不一样才需要刷新
    [[[[field.rac_textSignal filter:^BOOL(NSString *value) {
        return [value length];
    }] ignore:@"1"] distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

- (void)superiorTakeUse {
    
    RACSubject *subject = [RACSubject subject];
    // take:从开始一共取N次的信号：取决sendNext 发送信号的次数n
    
    [[subject take:5] subscribeNext:^(id x) {
        //        返回结果：1 ，2
        NSLog(@"%@",x);
    }];
    //  takeLast:取最后N次的信号,前提条件：订阅者必须调用完成，因为只有完成，就知道总共有多少信号
    [[subject takeLast:1] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendCompleted];
    
    UITextField *field;
    //    takeUntil:(RACSignal *):获取信号直到某个信号执行完成
    [field.rac_textSignal takeUntil:field.rac_willDeallocSignal];
    //  skip表示输入第一次，不会被监听到，跳过第一次发出的信号
    [[field.rac_textSignal skip:1] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //  switchToLatest:只能用于signalOfSignals（信号的信号），有时候信号也会发出信号，会在signalOfSignals中，获取signalOfSignals发送的最新信号。
    RACSubject *signalOfSignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    // 获取信号中信号最近发出信号，订阅最近发出的信号。
    [signalOfSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [signalOfSignals sendNext:signal];
    [signal sendNext:@1];
    
}

- (void)superiorDoNextUse {
    //doNext: 执行Next之前，会先执行这个Block
    //doCompleted: 执行sendCompleted之前，会先执行这个Block
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];//调用前，执行NSLog(@"doNext");调用后，再执行 NSLog(@"%@",x);
        [subscriber sendCompleted];//调用前，执行NSLog(@"doCompleted");
        return nil;
    }] doNext:^(id x) {
        NSLog(@"doNext");
    }] doCompleted:^{
        NSLog(@"doCompleted");
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

-  (void)superiorDeliverOnUse {
    //deliverOn: 内容传递切换到制定线程中，副作用在原来线程中,把在创建信号时block中的代码称之为副作用。
    //
    //subscribeOn: 内容传递和副作用都会切换到制定线程中。
}

- (void)superiorTimeUse {
// timeout：超时，可以让一个信号在一定的时间后，自动报错--用于网络请求超时时的提示
    
   [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       [subscriber sendNext:@3];
       [subscriber sendCompleted];
        return nil;
    }] timeout:1 onScheduler:[RACScheduler currentScheduler]] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    } error:^(NSError *error) {
        // 1秒后会自动调用
        NSLog(@"%@",error);
    }];
    
// interval 定时：每隔一段时间发出信号 --- 计时器 ----
    [[RACSignal interval:1 onScheduler:[RACScheduler currentScheduler] withLeeway:5] subscribeNext:^(id x) {
        NSLog(@"%@",x);//年月日时分秒
    }];
    
//    delay 延迟发送next。
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@8];
        [subscriber sendCompleted];
        return nil;
    }] delay:2] subscribeNext:^(id x) {
         NSLog(@"%@",x);
    }];
}

- (void)superiorRepeatUse {
//    retry重试 ：只要失败，就会重新执行创建信号中的block,直到业务逻辑成功.
    __block NSInteger i = 0;
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (i == 10) {
            [subscriber sendNext:@10];
        } else {
              NSLog(@"接收到错误");
            [subscriber sendError:nil];
        }
        i++;
        return nil;
    }] retry] subscribeNext:^(id x) {
        NSLog(@"%@",x);

    } error:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
//  replay重放：当一个信号被多次订阅,反复播放内容
    
  RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        return nil;
    }] replay];
//    订阅信号后，执行2次
    [signal subscribeNext:^(id x) {
         NSLog(@"第一个订阅者%@",x);
    }];
//    订阅信号后，执行2次
    [signal subscribeNext:^(id x) {
         NSLog(@"第二个订阅者%@",x);
    }];
   
// throttle节流:当某个信号发送比较频繁时，可以使用节流，在某一段时间不发送信号内容，过了一段时间获取信号的 最新内容发出。
    RACSubject *subject =[RACSubject subject];
    _testSubject = subject;
    [[_testSubject throttle:1] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

//- (void)testSuperiorRepeatUse {
//    __block NSInteger i =0;
//    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        if (i==10) {
//            [subscriber sendNext:@1];
//        } else {
//            NSLog(@"打印数据出错");
//            [subscriber sendError:nil];
//        }
//        i++;
//        return nil;
//    }] retry] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//   
//  RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@1];
//        [subscriber sendNext:@2];
//        return nil;
//    }] replay];
//    [signal subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    [signal subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    
//    RACSubject *subject = [RACSubject subject];
//    _testSubject  = subject;
//    [[_testSubject throttle:1] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    
//}
//
//- (void)testSuperiorTimeUse {
//    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@1];
//        [subscriber sendCompleted];
//        return nil;
//    }] timeout:1 onScheduler:[RACScheduler currentScheduler]] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    } error:^(NSError *error) {
//        NSLog(@"%@",error);
//    }];
//    
//    [[RACSignal interval:1 onScheduler:[RACScheduler currentScheduler] withLeeway:3] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    
//    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@2];
//        [subscriber sendCompleted];
//        return nil;
//    }] delay:2] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//}

//- (void)testSuperiorDoNextUse {
//    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@1];
//        [subscriber sendCompleted];
//        return nil;
//    }] doNext:^(id x) {
//        NSLog(@"doNext");
//    }] doCompleted:^{
//        NSLog(@"doCompleted");
//    }] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//}

//- (void)testSuperiorTakeUse {
//    RACSubject *subject  =[RACSubject subject];
//    [[[[[subject take:3] takeLast:2] skip:1] takeUntil:subject.rac_willDeallocSignal] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    [subject sendNext:@1];
//    [subject sendNext:@2];
//    [subject sendCompleted];
//
//    RACSubject *subject1 = [RACSubject subject];
//    RACSubject *subject2 = [RACSubject subject];
//    [subject1.switchToLatest subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//
//    [subject1 sendNext:subject2];
//    [subject2 sendNext:@3];
//
//}
//- (void)testSuperiorFilterAndIgnoreAndDistinctUse {
//    UITextField *field = [[UITextField alloc] init];
//    field.backgroundColor = [UIColor grayColor];
//    field.placeholder = @"请输入内容";
//    field.frame = CGRectMake(100, 264, 100, 30);
//    field.textColor = [UIColor greenColor];
//    [self.view addSubview:field];
//
//    [[[[field.rac_textSignal filter:^BOOL(id value) {
//        return [(NSString *)value length];
//    }] ignore:@1] distinctUntilChanged] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//}
//-  (void)testSuperiorReduceUse {
//    [[RACSignal combineLatest:@[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@1];
//        [subscriber sendCompleted];
//        return nil;
//    }],[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@2];
//        [subscriber sendCompleted];
//        return nil;
//    }]] reduce:^id(NSNumber *num1,NSNumber *num2){
//        return [NSString stringWithFormat:@"%@ %@",num1,num2];
//    }] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//}
//- (void)testSuperiorCombineLatestUse {
//    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@1];
//        [subscriber sendNext:@2];
//        [subscriber sendNext:@3];
//        [subscriber sendCompleted];
//        return [RACDisposable disposableWithBlock:^{
//            return ;
//        }];
//    }] combineLatestWith:[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@4];
//        [subscriber sendNext:@5];
//        [subscriber sendNext:@6];
//        [subscriber sendCompleted];
//        return [RACDisposable disposableWithBlock:^{
//            return ;
//        }];
//    }]] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//}
//- (void)testSuperiorZipWithUse {
//    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@1];
//        [subscriber sendCompleted];
//        return nil;
//    }];
//
//    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@1];
//        [subscriber sendCompleted];
//        return nil;
//    }];
//
//    RACSignal *signalC = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@1];
//        [subscriber sendCompleted];
//        return nil;
//    }];
//
//    [[signalA zipWith:[signalB zipWith:signalC]] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//
//}
//- (void)testSuperiorMergeUse {
//    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@"1"];
//        [subscriber sendCompleted];
//        return nil;
//    }];
//    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@"2"];
//        [subscriber sendCompleted];
//        return nil;
//    }];
//    RACSignal *signalC = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@"3"];
//        [subscriber sendCompleted];
//        return nil;
//    }];
//
//    RACSignal *mergeSignal = [signalA merge:[signalB merge:signalC]];
//    [mergeSignal subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//}


//- (void)testSuperiorThenUse {
//    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@"1"];
//        [subscriber sendCompleted];
//        return [RACDisposable disposableWithBlock:^{
//            NSLog(@"取消信号");
//        }];
//    }] then:^RACSignal *{
//        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            [subscriber sendNext:@"2"];
//            [subscriber sendCompleted];
//            return [RACDisposable disposableWithBlock:^{
//                NSLog(@"该取消信号");
//            }];
//        }];
//    }] subscribeNext:^(id x) {
//        NSLog(@"测试下第二个信号%@",x);
//    }];
//}
//- (void)testSuperiorConcatUse {
//    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@"1"];
//        [subscriber sendCompleted];
//        return [RACDisposable disposableWithBlock:^{
//              NSLog(@"4.信号A已经被取消订阅");
//        }];
//    }];
//    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@"1"];
//        [subscriber sendCompleted];
//        return [RACDisposable disposableWithBlock:^{
//            NSLog(@"3.信号A已经被取消订阅");
//        }];
//    }];
//    RACSignal *concatSignal = [signalA concat:signalB];
//    [concatSignal subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//
//}
//- (void)testSuperiorMapUse {
//    UITextField *field ;
//    [[field.rac_textSignal map:^id(id value) {
//        return [NSString stringWithFormat:@"输出%@",value];
//    }] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//
//    [[field.rac_textSignal flattenMap:^RACStream *(id value) {
//        return [RACReturnSignal return:[NSString stringWithFormat:@"输出%@",value]];
//    }] subscribeNext:^(id x) {
//          NSLog(@"%@",x);
//    }];
//
//    RACSubject *subject1 = [RACSubject subject];
//    RACSubject *subject2 = [RACSubject subject];
//    [[subject1 flattenMap:^RACStream *(id value) {
//        return value;
//    }] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//
//    [subject1 sendNext:subject2];
//    [subject2 sendNext:@1];
//    [subject2 sendCompleted];
//}

//- (void)testSuperiorBindUse {
//     UITextField *field;
//    [field.rac_textSignal subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//
//    [[field.rac_textSignal bind:^RACStreamBindBlock{
//        return ^RACStream * (id value,BOOL *stop) {
//            return [RACReturnSignal return:[NSString stringWithFormat:@"输出:%@",value]];
//        };
//    }] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//}



@end
