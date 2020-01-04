//
//  FavoritesViewModel.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2020/1/2.
//  Copyright © 2020 Wang Zewei. All rights reserved.
//

#import "FavoritesViewModel.h"
#import "DBManager.h"
#import "Session.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface FavoritesViewModel ()

@property (nonatomic, copy, readwrite) NSArray *favorites;
@property (nonatomic, assign, readwrite) BOOL dataSetEmpty;
@property (nonatomic, strong) RACCommand<id, RACTuple *> *loadContentCommand;

@end

@implementation FavoritesViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self bindEvents];
    }
    return self;
}

- (void)loadContent {
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

@end
