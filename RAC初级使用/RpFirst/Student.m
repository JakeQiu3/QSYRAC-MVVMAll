//
//  Student.m
//  RpFirst
//
//  Created by 邱少依 on 16/8/29.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "Student.h"

@implementation Student
- (void)testDelegate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wojiuceyice)]) {
        [self.delegate wojiuceyice];
    }
}
@end
