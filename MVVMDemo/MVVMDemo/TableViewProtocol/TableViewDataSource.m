//
//  TableViewDataSource.m
//  MVVMDemo
//
//  Created by qsy on 15/6/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "TableViewDataSource.h"
#import "CustomTableViewCell.h"

@implementation TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomTableViewCell"];
    if (!cell) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomTableViewCell"];
    }
    cell.titleLabel.text=((CustomModel *)[_array objectAtIndex:indexPath.row]).title;
    return cell;
}

@end
