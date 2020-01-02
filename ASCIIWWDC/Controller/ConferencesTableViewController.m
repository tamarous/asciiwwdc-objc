//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "ConferencesTableViewController.h"
#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>
#import "TracksTableViewController.h"
#import "MyWebViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import "ConferencesViewModel.h"
#import "ConferenceTableViewCell.h"

static NSString * const kConferenceTableViewCell = @"ConferenceTableViewCell";
static NSString * const kLoadingTableViewCell = @"LoadingTableViewCell";
static NSString * const kFilteredTableViewCell = @"FilteredTableViewCell";

@interface ConferencesTableViewController () <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating>
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) ConferencesViewModel *viewModel;
- (void)bindEvents;
@end

@implementation ConferencesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"ASCIIWWDC";
    
    self.viewModel = [[ConferencesViewModel alloc] init];

    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kLoadingTableViewCell];
    [self.tableView registerClass:[ConferenceTableViewCell class] forCellReuseIdentifier:kConferenceTableViewCell];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFilteredTableViewCell];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.viewModel.tableView = self.tableView;
    
    self.navigationItem.searchController = self.searchController;
    self.definesPresentationContext = true;
    
    [self.view addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(40);
        make.centerY.mas_equalTo(self.view);
    }];

    [self bindEvents];
    [self.viewModel loadContent];
}

#pragma mark - ViewController Life Cycle
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel saveContent];
}

#pragma mark - Actions
- (void)bindEvents {
    @weakify(self);
    [[RACObserve(self.viewModel, isLoading) deliverOnMainThread] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if ([x boolValue]) {
            [self.indicatorView startAnimating];
        } else {
            [self.indicatorView stopAnimating];
        }
        self.indicatorView.hidden = ![x boolValue];
    }];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isFiltering) {
        Session *session = [self.viewModel.filteredSessions objectAtIndex:indexPath.row];
        NSURL *requestURL = [NSURL URLWithString:session.urlString relativeToURL:[NSURL URLWithString:kASCIIWWDCHomepageURLString]];
        
        MyWebViewController *webViewController = [[MyWebViewController alloc] init];
        webViewController.requestURL = requestURL;
        webViewController.session = session;
        webViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webViewController animated:YES];
    } else {
        TracksTableViewController *tracksController = [[TracksTableViewController alloc] init];
        tracksController.hidesBottomBarWhenPushed = YES;
        Conference *conference = [self.viewModel.conferences objectAtIndex:indexPath.row];
        tracksController.tracks = conference.tracks;
        tracksController.trackTitle = conference.name;
        [self.navigationController pushViewController:tracksController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.isFiltering?44.0f:144.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isFiltering ? self.viewModel.filteredSessions.count : (self.viewModel.isLoading ? 0 : self.viewModel.conferences.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isFiltering) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFilteredTableViewCell forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFilteredTableViewCell];
        }
        Session *session = (Session *)[self.viewModel.filteredSessions objectAtIndex:indexPath.row];
        cell.textLabel.text = session.title;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        return cell;
    } else {
        ConferenceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kConferenceTableViewCell forIndexPath:indexPath];
        if (!cell) {
            cell = [[ConferenceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kConferenceTableViewCell];
        }
        Conference *conference = [self.viewModel.conferences objectAtIndex:indexPath.row];
        [cell configureWithConference:conference];
        return cell;
    }
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self filterSessionsForSearchText:searchController.searchBar.text];
}

- (void)filterSessionsForSearchText:(NSString *)query {
    [self.viewModel filterWithQuery:query];
}

#pragma mark - Getter & Setter
- (BOOL)isFiltering {
    return self.searchController.isActive && self.searchController.searchBar.text.length >= 0;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.hidesNavigationBarDuringPresentation = NO;
        _searchController.obscuresBackgroundDuringPresentation = NO;
        [_searchController.searchBar sizeToFit];
    }
    return _searchController;
};
@end

