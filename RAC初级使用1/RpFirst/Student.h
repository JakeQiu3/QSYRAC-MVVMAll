//
//  Student.h
//  RpFirst
//
//  Created by 邱少依 on 16/8/29.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol wojiushiceyiceDelegagte<NSObject>
- (void)wojiuceyice;
@end

@interface Student : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, weak) id<wojiushiceyiceDelegagte> delegate;
- (void)testDelegate;
@end
