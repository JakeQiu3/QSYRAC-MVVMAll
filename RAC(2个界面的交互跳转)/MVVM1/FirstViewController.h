//
//  FirstViewController.h
//  QSYPersonalRepositoryAll
//
//  Created by qsyMac on 16/6/9.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"
@interface FirstViewController : UIViewController
@property (nonatomic, strong)RACSignal *passValueSignal;
@end
