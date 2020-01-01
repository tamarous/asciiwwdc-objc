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
#import  <ReactiveObjC/ReactiveObjC.h>
static NSString * const kFavoritesTableViewCell = @"FavoritesTableViewCell";
@interface FavoritesTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic, copy) NSArray *favorites;
@property (nonatomic, assign) BOOL dataSetEmpty;
@property (nonatomic, strong) RACCommand<id, RACTuple *> *loadContentCommand;
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
    
    [self bindEvents];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.loadContentCommand execute:nil];
}

- (void)bindEvents {
    @weakify(self);
    [[self.loadContentCommand.executionSignals switchToLatest] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self);
        RACTupleUnpack(NSArray *favorites) = x;
        self.favorites = favorites;
        self.dataSetEmpty = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.tableView reloadData];
        });
    } error:^(NSError * _Nullable error) {
        self.dataSetEmpty = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.tableView reloadData];
        });
    }];
}

- (RACCommand *)loadContentCommand {
    if (!_loadContentCommand) {
        _loadContentCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE FAVORED = 1;", [Session tableName]];
                NSArray *favorites = [[DBManager sharedManager] loadSessionsArrayFromDatabaseWithQueryString:query];
                if (favorites && favorites.count > 0) {
                    [subscriber sendNext:RACTuplePack(favorites)];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:nil];
                }
                return nil;
            }];
        }];
    }
    return _loadContentCommand;
}

#pragma mark - Tableview data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSetEmpty ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSetEmpty ? 0 : self.favorites.count;
}

#pragma mark - TableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFavoritesTableViewCell];
    if (!cell) {
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
    NSString *str = @"空空如也，请先阅读某些内容~";
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName:[UIColor blackColor]
                                 };
    return [[NSAttributedString alloc] initWithString:str attributes:attributes];
}


#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return self.dataSetEmpty;
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
