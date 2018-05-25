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
#import "DBManager.h"
#import "MyWebViewController.h"
static NSString * const kFavoritesTableViewCell = @"FavoritesTableViewCell";
@interface FavoritesTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic, copy) NSArray *favorites;
@property (nonatomic, assign) BOOL dataSetEmpty;
@end

@implementation FavoritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Favorites";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFavoritesTableViewCell];
    self.tableView.rowHeight = 44.0;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadContents];
}

- (void) loadContents {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE FAVORED = 1;", [Session tableName]];
        
        self.favorites = [[DBManager sharedManager] loadSessionsArrayFromDatabaseWithQueryString:query];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.favorites != nil && [self.favorites count] != 0) {
                self.dataSetEmpty = NO;
                [self.tableView reloadData];
            } else {
                self.dataSetEmpty = YES;
            }
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataSetEmpty) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSetEmpty) {
        return 0;
    }
    return self.favorites.count;
}

#pragma mark - TableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFavoritesTableViewCell];
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFavoritesTableViewCell];
    }
    Session *session = [self.favorites objectAtIndex:indexPath.row];
    cell.textLabel.text = session.title;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Session *session = [self.favorites objectAtIndex:indexPath.row];
    NSURL *requestURL = [NSURL URLWithString:session.urlString relativeToURL:[NSURL URLWithString:kASCIIWWDCHomepageURLString]];
    
    MyWebViewController *webViewController = [[MyWebViewController alloc] init];
    webViewController.requestURL = requestURL;
    webViewController.session = session;
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *str = @"看起来你还没有收藏哦~";
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName:[UIColor darkGrayColor]
                                 };
    return [[NSAttributedString alloc] initWithString:str attributes:attributes];
}


#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    if (self.dataSetEmpty) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return NO;
}



@end
