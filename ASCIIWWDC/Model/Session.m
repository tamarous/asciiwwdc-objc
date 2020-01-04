  //
//  Session.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "Session.h"
@implementation Session

#pragma mark - BaseModelProtocol
+ (NSString *)tableName {
    return NSStringFromClass([self class]);
}

+ (NSString *)statementForCreateTable {
    NSString *str = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (URL_STRING TEXT PRIMARY KEY NOT NULL,TITLE TEXT NOT NULL,SESSION_ID TEXT NOT NULL, TRACK_NAME TEXT NOT NULL, FAVORED INTEGER DEFAULT 0);", [[self class] tableName]];
    return str;
}

- (NSString *)statementForUpdate {
    NSString *str = [NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET TITLE = \"%@\",TRACK_NAME = \"%@\",SESSION_ID = \"%@\" ,FAVORED = %d WHERE URL_STRING = \"%@\";", [[
                                                                                                                                                                        self class] tableName], self.title, self.trackName, self.sessionID, self.isFavored,  self.urlString];
    return str;
}

- (NSString *)statementForInsert {
    NSString *str = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@ VALUES(\"%@\", \"%@\", \"%@\", \"%@\",%d);", [[self class] tableName], self.urlString, self.title, self.sessionID, self.trackName, self.isFavored];
    return str;
}

- (NSString *)statementForInsertOrReplace {
    NSString *str = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (URL_STRING, TITLE, SESSION_ID, TRACK_NAME,FAVORED) VALUES(\"%@\", \"%@\", \"%@\",\"%@\",%d);", [[self class] tableName], self.urlString, self.title, self.sessionID, self.trackName, self.isFavored];
    return str;
}
@end
