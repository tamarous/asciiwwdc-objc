//
//  ConferencesViewModel.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2020/1/1.
//  Copyright © 2020 Wang Zewei. All rights reserved.
//

#import "ConferencesViewModel.h"
#import "NetworkManager.h"
#import "Constants.h"
#import "DBManager.h"
#import <ReactiveObjC/ReactiveObjC.h>

#import "MyWebViewController.h"
#import "TracksTableViewController.h"



@interface ConferencesViewModel ()
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, strong) RACCommand<id, RACTuple *> *loadContentFromNetworkCommand;
@property (nonatomic, strong) RACCommand<id, RACTuple *> *loadContentFromDiskCommmand;
@property (nonatomic, strong) RACCommand<id, RACTuple *> *saveContentCommand;
@property (nonatomic, copy, readwrite) NSArray *conferences;
@property (nonatomic, assign) BOOL isFiltering;
@property (nonatomic, assign) BOOL dataSaved;
@property (nonatomic, copy) NSArray *filteredSessions;
@end

@implementation ConferencesViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self bindEvents];
    }
    return self;
}


#pragma mark - Actions
- (void)loadContent {
    [self.loadContentFromNetworkCommand execute:nil];
}

- (void)saveContent {
    if (self.dataSaved) {
        return;
    }
    [[RACScheduler schedulerWithPriority:RACSchedulerPriorityDefault] schedule:^{
        [self.saveContentCommand execute:nil];
    }];
}

- (void)bindEvents {
    @weakify(self);
    [self.saveContentCommand.executionSignals subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.dataSaved = YES;
    }];
    
    [self.loadContentFromDiskCommmand.executing subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        self.isLoading = [x boolValue];
    }];
    [self.loadContentFromNetworkCommand.executing subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        self.isLoading = [x boolValue];
    }];
    [[self.loadContentFromDiskCommmand.executionSignals switchToLatest] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self);
        RACTupleUnpack(NSArray *conferences) = x;
        self.conferences = conferences;
        self.isLoading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.tableView reloadData];
        });
    } error:^(NSError * _Nullable error) {
        [self.loadContentFromNetworkCommand execute:nil];
    }];
    [[self.loadContentFromNetworkCommand.executionSignals switchToLatest] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self);
        self.isLoading = NO;
        RACTupleUnpack(NSArray *conferences) = x;
        self.conferences = conferences;
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.tableView reloadData];
        });
    }];
}

- (void)filterWithQuery:(NSString *)query {
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
