//
//  SecondViewController.h
//  QSYPersonalRepositoryAll
//
//  Created by qsyMac on 16/6/9.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"

@interface SecondViewController : UIViewController
@property (nonatomic, strong)RACSubject *delegateSignal;
@property (nonatomic, strong)NSString *valueStr;
@end
