//
//  LoginRequestService.h
//  Reactive Login
//
//  Created by qsyMac on 16/9/4.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
typedef void(^RpRequestInResponse)(BOOL);
@interface LoginRequestService : NSObject

+ (void)logInWithUsername:(NSString *)username
                 password:(NSString *)password
                 complete:(RpRequestInResponse)completeBlock;
@end
