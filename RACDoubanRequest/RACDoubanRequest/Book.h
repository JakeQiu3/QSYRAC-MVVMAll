//
//  Book.h
//  QSYPersonalRepositoryAll
//
//  Created by 邱少依 on 16/6/13.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (Book *)initWithDic:(NSDictionary *)dic;
+ (Book *)bookWithDict:(NSDictionary *)dic;

@end
