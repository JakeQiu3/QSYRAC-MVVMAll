//
//  RequestNetViewController.m
//  QSYPersonalRepositoryAll
//
//  Created by 邱少依 on 16/6/13.
//  Copyright © 2016年 QSY. All rights reserved.
//

#import "RequestNetViewController.h"
#import "RequestViewModel.h"
#include "RequestDetailViewController.h"

@interface RequestNetViewController ()<UITableViewDelegate>
//V
@property (nonatomic, strong) UITableView *tableView;
//VM
@property (nonatomic, strong) RequestViewModel *requesViewModel;

@end

@implementation RequestNetViewController

- (RequestViewModel *)requesViewModel {
    if (!_requesViewModel) {
        _requesViewModel = [[RequestViewModel alloc] init];
    }
    return _requesViewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Reactcocoa请求";
    [self setUI];
    [self bindSignal];
    // Do any additional setup after loading the view.
}

- (void)setUI {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self.requesViewModel;
    _tableView.delegate = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    _tableView.rowHeight = 50;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:_tableView];
}

- (void)bindSignal {
    RACSignal *requestSignal = [self.requesViewModel.reuqesCommand execute:nil];
    [requestSignal subscribeNext:^(id x) {
        self.requesViewModel.modelsArray = x;
        [self.tableView reloadData];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RequestDetailViewController *detailVC = [[RequestDetailViewController alloc] init];
    [self.navigationController pushViewController:detailVC animated:YES];
}


@end
