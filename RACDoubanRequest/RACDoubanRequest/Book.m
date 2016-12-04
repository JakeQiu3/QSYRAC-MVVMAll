//
//  Book.m
//  QSYPersonalRepositoryAll
//
//  Created by 邱少依 on 16/6/13.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "Book.h"

@implementation Book

- (Book *)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.title = dic[@"title"];
        self.subtitle = dic[@"subtitle"];
    }
    return self;
}

+ (Book *)bookWithDict:(NSDictionary *)dic {
    Book *book = [[Book alloc] initWithDic:dic];
    return book;
}

@end
