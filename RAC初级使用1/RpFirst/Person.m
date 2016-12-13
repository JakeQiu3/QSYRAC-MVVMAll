//
//  Person.m
//  RpFirst
//
//  Created by 邱少依 on 16/8/29.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "Person.h"

@implementation Person
- (void)run1 {
    NSLog(@"我跑");
}

- (void)study1 {
     NSLog(@"我学习");
}

- (Person *)run2 {
    NSLog(@"我跑");
    return self;
}
- (Person *)study2 {
     NSLog(@"我学习");
     return self;
}

- (Person *(^)())runBlock {
    
    return ^(){
        NSLog(@"我跑");
        return self;
    };
    Person *(^block)() = ^(){
       NSLog(@"我跑");
        return self;
    };
    return block;
}
- (Person *(^)())studyBlock {
    return ^(){
        NSLog(@"我学习");
        return self;
    };
    
    Person *(^block)() = ^() {
       NSLog(@"我学习");
        return self;
    };
    return block;
}


- (void)addTest {
    
   void(^personTest)() = ^(){
        NSLog(@"我了个去");
    };
    
    if (self.test) {
        self.test(); //本身是调用 block 的回调方法
    }
}

@end
