//
//  Conference.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "Track.h"

@interface Conference : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *logoUrlString;
@property (nonatomic, copy) NSString *shortDescription;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) NSArray<Track *> *tracks;
- (BOOL) save;
- (BOOL) update;
+ (NSString *) tableName;
+ (NSString *) stringForCreateTable;
+ (NSString *) stringForInsertConference:(Conference *) conference;
+ (NSString *) stringForUpdateConference:(Conference *) conference;
@end
