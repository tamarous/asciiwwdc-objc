//
// Created by 汪泽伟 on 2019/12/28.
// Copyright (c) 2019 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Conference.h"

@interface NetworkManager : NSObject

+ (void)loadConferencesWithCompletion:(void (^)(NSArray *conferences, NSError *error))completion;

@end
