//
//  TableViewModel.m
//  MVVMDemo
//
//  Created by qsy on 15/6/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "TableViewModel.h"
#import "CustomModel.h"
@interface TableViewModel ()

@end

@implementation TableViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)headerRefreshRequestWithCallback:(callback)callback {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *arr=[NSMutableArray array];
                for (int i=0; i<16; i++) {
                    int x = arc4random() % 100;
                    // 暂时写的死数据，也可以网络请求来执行
                    NSString *string=[NSString stringWithFormat:@" (随机数%d)爱你在口心难开！",x];
                    CustomModel *model=[[CustomModel alloc] init];
                    model.title=string;
                    [arr addObject:model];
                }
                callback(arr);
            });
        });
}

- (void )footerRefreshRequestWithCallback:(callback)callback {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *arr=[NSMutableArray array];
                for (int i=0; i<16; i++) {
                    int x = arc4random() % 100;
                    NSString *string=[NSString stringWithFormat:@" (随机数%d)爱你在口心难开！",x];
                    CustomModel *model=[[CustomModel alloc] init];
                    model.title=string;
                    [arr addObject:model];
                }
                callback(arr);
            });
        });
}

@end
