//
//  FavoritesTableViewController.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/24.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "Constants.h"
#import "MyWebViewController.h"
#import "FavoritesViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
static NSString * const kFavoritesTableViewCell = @"FavoritesTableViewCell";
@interface FavoritesTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) FavoritesViewModel *viewModel;
@end

@implementation FavoritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Favorites";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFavoritesTableViewCell];
    self.tableView.rowHeight = 44.0;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
    
    self.viewModel = [[FavoritesViewModel alloc] init];
    self.viewModel.tableView = self.tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel loadContent];
}

#pragma mark - Tableview data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataSetEmpty ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataSetEmpty ? 0 : self.viewModel.favorites.count;
}

#pragma mark - TableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFavoritesTableViewCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFavoritesTableViewCell];
    }
    Session *session = [self.viewModel.favorites objectAtIndex:indexPath.row];
    cell.textLabel.text = session.title;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Session *session = [self.viewModel.favorites objectAtIndex:indexPath.row];
    NSURL *requestURL = [NSURL URLWithString:session.urlString relativeToURL:[NSURL URLWithString:kASCIIWWDCHomepageURLString]];
    
    MyWebViewController *webViewController = [[MyWebViewController alloc] init];
    webViewController.requestURL = requestURL;
    webViewController.session = session;
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *str = @"空空如也，请先阅读某些内容~";
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName:[UIColor blackColor]
                                 };
    return [[NSAttributedString alloc] initWithString:str attributes:attributes];
}


#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return self.viewModel.dataSetEmpty;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return NO;
}

- (BOOL) shouldAutorotate {
    return NO;
}
@end
