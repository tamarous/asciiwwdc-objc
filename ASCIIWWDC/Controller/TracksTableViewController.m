//
//  TracksTableViewController.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "TracksTableViewController.h"
#import "TrackHeaderView.h"
#import "Constants.h"
#import "MyWebViewController.h"
static NSString * const kSessionTableViewCell = @"SessionTableViewCell";
#define TRACK_HEADER_HEIGHT 48

@interface TracksTableViewController () <TrackHeaderViewDelegate>
@property (nonatomic, strong) NSMutableArray *isOpen;
@end

@implementation TracksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.trackTitle;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSessionTableViewCell];
    
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setTracks:(NSArray *)tracks {
    _tracks = [tracks copy];
    _isOpen = [NSMutableArray arrayWithCapacity:tracks.count];
    for(int i = 0; i < tracks.count; i++) {
        _isOpen[i] = @NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tracks.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_isOpen[section] boolValue]) {
        Track *track = [self.tracks objectAtIndex:section];
        return track.sessions.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSessionTableViewCell forIndexPath:indexPath];
    if ( !cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSessionTableViewCell];
    }
    
    Track *track = [_tracks objectAtIndex:indexPath.section];
    Session *session = [track.sessions objectAtIndex:indexPath.row];
    cell.textLabel.text = session.title;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TRACK_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TrackHeaderView *trackHeaderView = [[TrackHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TRACK_HEADER_HEIGHT)];
    Track *track = [_tracks objectAtIndex:section];
    [trackHeaderView setTitle:track.trackName forState:UIControlStateNormal];
    [trackHeaderView setTag:section];
    
    trackHeaderView.delegate = self;
    return trackHeaderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Track *track = [_tracks objectAtIndex:indexPath.section];
    Session *session = [track.sessions objectAtIndex:indexPath.row];
    NSURL *requestURL = [NSURL URLWithString:session.urlString relativeToURL:[NSURL URLWithString:kASCIIWWDCHomepageURLString]];
    
    MyWebViewController *webViewController = [[MyWebViewController alloc] init];
    webViewController.hidesBottomBarWhenPushed = YES;
    webViewController.requestURL = requestURL;
    webViewController.session = session;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - TrackHeaderViewDelegate
- (void)trackDidClicked:(TrackHeaderView *)trackHeaderView {
    BOOL reverse = ![_isOpen[trackHeaderView.tag] boolValue];
    _isOpen[trackHeaderView.tag] = [NSNumber numberWithBool:reverse];
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:trackHeaderView.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return  UIInterfaceOrientationMaskPortrait;
}

@end
