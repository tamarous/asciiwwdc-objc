//
//  FavoritesViewModel.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2020/1/2.
//  Copyright © 2020 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FavoritesViewModel : NSObject

@property (nonatomic, copy, readonly) NSArray *favorites;
@property (nonatomic, assign, readonly) BOOL dataSetEmpty;
@property (nonatomic, weak) UITableView *tableView;

- (void)loadContent;

@end

NS_ASSUME_NONNULL_END
