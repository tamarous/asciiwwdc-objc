//
//  ConferencesTableViewController.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "ConferencesTableViewController.h"
#import "ParserManager.h"
#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>
#import "ConferenceTableViewCell.h"
#import "TracksTableViewController.h"
#import "MyWebViewController.h"
#import "DBManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "NetworkManager.h"
static NSString * const kConferenceTableViewCell = @"ConferenceTableViewCell";
static NSString * const kLoadingTableViewCell = @"LoadingTableViewCell";
static NSString * const kFilteredTableViewCell = @"FilteredTableViewCell";

@interface ConferencesTableViewController () <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating>
@property (nonatomic, copy) NSArray<Conference *> *conferences;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL dataSaved;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) BOOL isFiltering;
@property (nonatomic, copy) NSArray *filteredSessions;
- (void)loadContents;
- (void)bindEvents;
@end

@implementation ConferencesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"ASCIIWWDC";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    
    UIEdgeInsets safeArea = self.view.safeAreaInsets;
    self.tableView.frame = CGRectMake(safeArea.left, safeArea.top, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kLoadingTableViewCell];
    [self.tableView registerClass:[ConferenceTableViewCell class] forCellReuseIdentifier:kConferenceTableViewCell];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFilteredTableViewCell];
    
    self.navigationItem.searchController = self.searchController;
    self.definesPresentationContext = true;

    [self bindEvents];
    [[RACScheduler schedulerWithPriority:RACSchedulerPriorityDefault] schedule:^{
        [self loadContents];
    }];
}

#pragma mark - ViewController Life Cycle
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveContents];
}

#pragma mark - Actions

- (void)bindEvents {
    [[RACObserve(self, isLoading) deliverOnMainThread] subscribeNext:^(NSNumber *x) {
        if (![x boolValue]) {
            [self.indicatorView stopAnimating];
            [self.indicatorView removeFromSuperview];
        }
    }];
}

- (void)loadContents {
    if (self.isLoading) {
        return;
    }
    self.isLoading = YES;
    self.conferences = [[DBManager sharedManager] loadConferencesArrayFromDatabaseWithQueryString:nil];
    if (!self.conferences || self.conferences.count == 0) {
        NSLog(@"Loading contents from network");
        @weakify(self);
        [NetworkManager loadConferencesFromURL:kASCIIWWDCHomepageURLString completion:^(NSArray *conferences, NSError *error) {
            @strongify(self);
            self.isLoading = NO;
            if (conferences) {
                self.conferences = conferences;
                [[RACScheduler schedulerWithPriority:RACSchedulerPriorityDefault] schedule:^{
                    [[DBManager sharedManager] saveConferencesArray:self.conferences];
                }];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    } else {
        NSLog(@"Loading contents from local disk.");
        self.isLoading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)saveContents {
    if (self.dataSaved) {
        return;
    }
    NSLog(@"Conferences saved");
    @weakify(self);
    [[RACScheduler schedulerWithPriority:RACSchedulerPriorityDefault] schedule:^{
        @strongify(self);
        [[DBManager sharedManager] saveConferencesArray:self.conferences];
        self.dataSaved = YES;
    }];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.isFiltering?44.0f:144.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isFiltering ? self.filteredSessions.count : (self.isLoading ? 1 : self.conferences.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isFiltering) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFilteredTableViewCell forIndexPath:indexPath];
        if (! cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFilteredTableViewCell];
        }
        Session *session = (Session *)[self.filteredSessions objectAtIndex:indexPath.row];
        cell.textLabel.text = session.title;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        return cell;
    } else {
        if (self.isLoading) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLoadingTableViewCell forIndexPath:indexPath];
            if (! cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLoadingTableViewCell];
            }
            [cell addSubview:self.indicatorView];
            [self.indicatorView startAnimating];
            return cell;
        } else {
            ConferenceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kConferenceTableViewCell forIndexPath:indexPath];
            if (! cell) {
                cell = [[ConferenceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kConferenceTableViewCell];
            }
            Conference *conference = [_conferences objectAtIndex:indexPath.row];
            [cell configureWithConference:conference];
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isFiltering) {
        Session *session = [self.filteredSessions objectAtIndex:indexPath.row];
        NSURL *requestURL = [NSURL URLWithString:session.urlString relativeToURL:[NSURL URLWithString:kASCIIWWDCHomepageURLString]];
        
        MyWebViewController *webViewController = [[MyWebViewController alloc] init];
        webViewController.requestURL = requestURL;
        webViewController.session = session;
        webViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webViewController animated:YES];
    } else {
        TracksTableViewController *tracksController = [[TracksTableViewController alloc] init];
        tracksController.hidesBottomBarWhenPushed = YES;
        Conference *conference = [self.conferences objectAtIndex:indexPath.row];
        tracksController.tracks = conference.tracks;
        tracksController.trackTitle = conference.name;
        [self.navigationController pushViewController:tracksController animated:YES];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self filterSessionsForSearchText:searchController.searchBar.text];
}

- (void)filterSessionsForSearchText:(NSString *)query {
    self.filteredSessions = [[[[self.conferences.rac_sequence map:^id _Nullable(Conference *_Nullable conference) {
        return [[conference.tracks.rac_sequence map:^id _Nullable(Track *_Nullable track) {
            return track.sessions.rac_sequence;
        }] flatten];
    }] flatten] filter:^BOOL(Session *_Nullable session) {
        return [session.title.lowercaseString containsString:query.lowercaseString];
    }] array];
    [self.tableView reloadData];
}

#pragma mark - Getter & Setter
- (BOOL)isFiltering {
    return self.searchController.isActive && self.searchController.searchBar.text.length >= 0;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        float width = [UIScreen mainScreen].bounds.size.width;
        _indicatorView.frame = CGRectMake(width/2-18, 4, 36, 36);
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

