//
//  Person.h
//  RpFirst
//
//  Created by 邱少依 on 16/8/29.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Person;
typedef Person *(^personBlock)();
@interface Person : NSObject

- (void)run1;
- (void)study1;
// 增加一个本对象的返回值
- (Person *)run2;
- (Person *)study2;

// 增加一个本对象 的block的返回值
- (Person* (^)())runBlock;
- (Person* (^)())studyBlock;


//VS
@property (nonatomic, copy) personBlock test;

@end
