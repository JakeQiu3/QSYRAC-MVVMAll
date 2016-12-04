//
//  RequestViewModel.h
//  QSYPersonalRepositoryAll
//
//  Created by 邱少依 on 16/6/13.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import "AFHTTPRequestOperationManager.h"
#import "Book.h"
#import "SVProgressHUD.h"

@interface RequestViewModel : NSObject<UITableViewDataSource>
@property (nonatomic, strong, readonly) RACCommand *reuqesCommand;
@property (nonatomic, strong) NSArray *modelsArray;

@end
