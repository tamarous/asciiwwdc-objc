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
#import "DBManager.h"

static NSString * const kConferenceTableViewCell = @"ConferenceTableViewCell";
static NSString * const kLoadingTableViewCell = @"LoadingTableViewCell";
typedef void(^configureCellBlock)(ConferenceTableViewCell *cell, Conference *conference);

@interface ConferencesTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) NSArray<Conference *> *conferences;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, copy) configureCellBlock cellBlock;
@property (nonatomic, assign) BOOL dataSaved;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kLoadingTableViewCell];
    [self.tableView registerClass:[ConferenceTableViewCell class] forCellReuseIdentifier:kConferenceTableViewCell];
    
    self.cellBlock = ^(ConferenceTableViewCell *cell, Conference *conference) {
        
        [cell.logoImageView sd_setImageWithURL:[NSURL URLWithString:conference.logoUrlString relativeToURL:[NSURL URLWithString:kASCIIWWDCHomepageURLString]]];
        
        cell.nameLabel.text = conference.name;
        cell.shortDescriptionLabel.text = conference.shortDescription;
        cell.timeLabel.text = conference.time;
        
        [cell.nameLabel sizeToFit];
        [cell.shortDescriptionLabel sizeToFit];
        [cell.timeLabel sizeToFit];
    };
    
    
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
            self.isLoading = false;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicatorView stopAnimating];
                [self.indicatorView removeFromSuperview];
                [self.tableView reloadData];
            });
        }
    }];
    [dataTask resume];
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
    return 144.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isLoading) {
        return 1;
    } else {
        return self.conferences.count;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TracksTableViewController *tracksController = [[TracksTableViewController alloc] init];
    tracksController.hidesBottomBarWhenPushed = YES;
    Conference *conference = [self.conferences objectAtIndex:indexPath.row];
    tracksController.tracks = conference.tracks;
    tracksController.trackTitle = conference.name;
    [self.navigationController pushViewController:tracksController animated:YES];
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end
