//
//  ConferencesViewModel.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2020/1/1.
//  Copyright © 2020 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ConferencesViewModel : NSObject

@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, copy, readonly) NSArray *conferences;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy, readonly) NSArray *filteredSessions;

- (instancetype)init;
- (void)loadContent;
- (void)saveContent;
- (void)filterWithQuery:(NSString *)query;

@end

NS_ASSUME_NONNULL_END
