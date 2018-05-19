//
//  ParserManager.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HTMLKit.h>
#import "Conference.h"


@interface ParserManager : NSObject
+ (instancetype) sharedManager;
- (NSArray *) createConferencesArrayFromResponseObject:(id) responseObject;
@end
