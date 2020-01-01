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
@property (nonatomic, strong) RACCommand<id, RACTuple *> *loadContentFromNetworkCommand;
@property (nonatomic, strong) RACCommand<id, RACTuple *> *loadContentFromDiskCommmand;
@property (nonatomic, strong) RACCommand<id, RACTuple *> *saveContentCommand;
- (void)bindEvents;
@end

@implementation ConferencesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"ASCIIWWDC";

    UIEdgeInsets safeArea = self.view.safeAreaInsets;
    self.tableView.frame = CGRectMake(safeArea.left, safeArea.top, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight([UIScreen mainScreen].bounds)-safeArea.bottom);
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
        [self.loadContentFromDiskCommmand execute:nil];
    }];
}

#pragma mark - ViewController Life Cycle
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[RACScheduler schedulerWithPriority:RACSchedulerPriorityDefault] schedule:^{
        [self.saveContentCommand execute:nil];
    }];
}

#pragma mark - Actions

- (void)bindEvents {
    @weakify(self);
    [[RACObserve(self, isLoading) deliverOnMainThread] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if (![x boolValue]) {
            [self.indicatorView stopAnimating];
            [self.indicatorView removeFromSuperview];
        }
    }];
    [self.saveContentCommand.executionSignals subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.dataSaved = YES;
    }];
    [[self.loadContentFromDiskCommmand.executionSignals concat] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self);
        RACTupleUnpack(NSArray *conferences) = x;
        self.conferences = conferences;
        [[RACScheduler mainThreadScheduler] schedule:^{
            @strongify(self);
            [self.tableView reloadData];
        }];
    } error:^(NSError * _Nullable error) {
        [self.loadContentFromNetworkCommand execute:nil];
    }];
    [[self.loadContentFromNetworkCommand.executionSignals concat] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self);
        self.isLoading = NO;
        RACTupleUnpack(NSArray *conferences) = x;
        self.conferences = conferences;
        [[RACScheduler mainThreadScheduler] schedule:^{
            @strongify(self);
            [self.tableView reloadData];
        }];
    }];
}

- (void)saveContents {
    if (self.dataSaved) {
        return;
    }
    [[RACScheduler schedulerWithPriority:RACSchedulerPriorityDefault] schedule:^{
        [self.saveContentCommand execute:nil];
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

- (RACCommand *)loadContentFromDiskCommmand {
    if (!_loadContentFromDiskCommmand) {
        _loadContentFromDiskCommmand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                NSArray *conferences = [[DBManager sharedManager] loadConferencesArrayFromDatabaseWithQueryString:nil];
                if (conferences && conferences.count > 0) {
                    [subscriber sendNext:RACTuplePack(conferences)];
                    [subscriber sendCompleted];
                } else {
                    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-999 userInfo:nil];
                    [subscriber sendError:error];
                }
                return nil;
            }];
        }];
    }
    return _loadContentFromDiskCommmand;
}

- (RACCommand *)loadContentFromNetworkCommand {
    if (!_loadContentFromNetworkCommand) {
        _loadContentFromNetworkCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                [NetworkManager loadConferencesFromURL:kASCIIWWDCHomepageURLString completion:^(NSArray *conferences, NSError *error) {
                    if (!error) {
                        [subscriber sendNext:RACTuplePack(conferences)];
                        [subscriber sendCompleted];
                    } else {
                        [subscriber sendError:error];
                    }
                }];
                return nil;
            }];
        }];
    }
    return _loadContentFromNetworkCommand;
}

- (RACCommand *)saveContentCommand {
    if (!_saveContentCommand) {
        _saveContentCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                [[DBManager sharedManager] saveConferencesArray:self.conferences];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _saveContentCommand;
}
@end

