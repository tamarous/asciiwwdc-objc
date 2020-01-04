//
//  Track.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "Track.h"
@implementation Track

#pragma mark - BaseModelProtocol
+ (NSString *)tableName {
    return NSStringFromClass([self class]);
}

+ (NSString *)statementForCreateTable {
    NSString *str = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (TRACK_ID INTEGER PRIMARY KEY,TRACK_NAME TEXT, CONFERENCE_NAME TEXT NOT NULL);",[self tableName]];
    return str;
}

- (NSString *)statementForUpdate {
    NSString *str = [NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET TRACK_NAME = \"%@\", CONFERENCE_NAME = \"%@\";",[[self class] tableName], self.trackName, self.conferenceName];
    return str;
}

- (NSString *)statementForInsert {
    NSString *str = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@ VALUES(NULL,\"%@\",\"%@\");",[[self class] tableName], self.trackName, self.conferenceName];
    return str;
}

- (NSString *)statementForInsertOrReplace {
    NSString *str = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (TRACK_NAME, CONFERENCE_NAME) VALUES(\"%@\",\"%@\");", [[self class] tableName], self.trackName, self.conferenceName];
    return str;
}

- (NSArray<id<BaseModelProtocol>> *)subModels {
    return self.sessions;
}
@end
