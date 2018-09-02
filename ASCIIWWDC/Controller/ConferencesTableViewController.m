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

static NSString * const kConferenceTableViewCell = @"ConferenceTableViewCell";
static NSString * const kLoadingTableViewCell = @"LoadingTableViewCell";
static NSString * const kFilteredTableViewCell = @"FilteredTableViewCell";
typedef void(^configureCellBlock)(ConferenceTableViewCell *cell, Conference *conference);

@interface ConferencesTableViewController () <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating>
@property (nonatomic, copy) NSArray<Conference *> *conferences;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, copy) configureCellBlock cellBlock;
@property (nonatomic, assign) BOOL dataSaved;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) BOOL isFiltering;
@property (nonatomic, strong) NSArray *filteredSessions;
- (void) loadContents;
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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kLoadingTableViewCell];
    [self.tableView registerClass:[ConferenceTableViewCell class] forCellReuseIdentifier:kConferenceTableViewCell];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFilteredTableViewCell];
    
    self.cellBlock = ^(ConferenceTableViewCell *cell, Conference *conference) {
        
        [cell.logoImageView sd_setImageWithURL:[NSURL URLWithString:conference.logoUrlString relativeToURL:[NSURL URLWithString:kASCIIWWDCHomepageURLString]]];
        
        cell.nameLabel.text = conference.name;
        cell.shortDescriptionLabel.text = conference.shortDescription;
        cell.timeLabel.text = [[conference.time componentsSeparatedByString:@"T"] firstObject];
        
        [cell.nameLabel sizeToFit];
        [cell.shortDescriptionLabel sizeToFit];
        [cell.timeLabel sizeToFit];
    };
    
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.navigationItem.searchController = self.searchController;
    self.definesPresentationContext = true;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadContents];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ViewController Life Cycle
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (! self.dataSaved) {
        [self saveContents];
    }
}


#pragma mark - Load Contents From ASCIIWWDC HomePage

- (void) loadContents {
    self.isLoading = true;

    self.conferences = [[DBManager sharedManager] loadConferencesArrayFromDatabaseWithQueryString:nil];
    if (self.conferences.count == 0) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = requestSerializer;
        manager.responseSerializer = responseSerializer;
        
        NSURL *URL = [NSURL URLWithString:kASCIIWWDCHomepageURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error) {
                NSLog(@"error: %@", error.domain.description);
            } else {
                self.conferences = [[ParserManager sharedManager]  createConferencesArrayFromResponseObject:responseObject];
                self.isLoading = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.indicatorView stopAnimating];
                    [self.indicatorView removeFromSuperview];
                    [self.tableView reloadData];
                });
            }
        }];
        [dataTask resume];
    } else {
        self.isLoading = NO;
    }
}

- (void) saveContents {
    NSLog(@"Conferences saved");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DBManager sharedManager] saveConferencesArray:self.conferences];
        self.dataSaved = YES;
    });
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.isFiltering?44.0f:144.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isFiltering) {
        return self.filteredSessions.count;
    } else {
        if (_isLoading) {
            return 1;
        } else {
            return self.conferences.count;
        }
    }
    
}

- (UIActivityIndicatorView *) indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        float width = [UIScreen mainScreen].bounds.size.width;
        _indicatorView.frame = CGRectMake(width/2-18, 4, 36, 36);
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
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
        if (_isLoading) {
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
            _cellBlock(cell, conference);
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

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self filterSessionsForSearchText:searchController.searchBar.text];
}

- (void) filterSessionsForSearchText:(NSString *) query {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [self.conferences enumerateObjectsUsingBlock:^(Conference * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Conference *conference = (Conference *)obj;
        NSArray *tracks = conference.tracks;
        for (int i = 0; i < tracks.count; i++) {
            Track *track = [tracks objectAtIndex:i];
            for(int j = 0; j < track.sessions.count; j++) {
                Session *session = [track.sessions objectAtIndex:j];
                if ([session.title.lowercaseString containsString:query.lowercaseString]) {
                    [result addObject:session];
                }
            }
        }
    }];
    self.filteredSessions = [result copy];
    [self.tableView reloadData];
}

- (BOOL) isFiltering {
    return self.searchController.isActive && ![self searchBarIsEmpty];
}

- (BOOL) searchBarIsEmpty {
    return self.searchController.searchBar == nil || self.searchController.searchBar.text.length == 0;
}
@end
