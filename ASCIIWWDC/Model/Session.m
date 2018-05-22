  //
//  Session.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "Session.h"


static NSString * SESSION_TABLE_NAME = @"SESSIONS";
@implementation Session
- (BOOL) save {
    if (! [[DBManager sharedManager] tableExists:SESSION_TABLE_NAME]) {
        [[DBManager sharedManager] createTable:SESSION_TABLE_NAME statementString:[[self class] stringForCreateTable]];
    }
    return [[DBManager sharedManager] executeInsertString:[[self class] stringForInsertSession:self] inTable:SESSION_TABLE_NAME];
}
- (BOOL) update {
    if (! [[DBManager sharedManager] tableExists:SESSION_TABLE_NAME]) {
        [[DBManager sharedManager] createTable:SESSION_TABLE_NAME statementString:[[self class] stringForCreateTable]];
    }
    return [[DBManager sharedManager] executeUpdateString:[[self class] stringForUpdateSession:self] inTable:SESSION_TABLE_NAME];
}

- (BOOL) insertOrReplace {
    if (! [[DBManager sharedManager] tableExists:SESSION_TABLE_NAME]) {
        [[DBManager sharedManager] createTable:SESSION_TABLE_NAME statementString:[[self class] stringForCreateTable]];
    }
    return [[DBManager sharedManager] executeUpdateString:[[self class] stringForInsertOrReplace:self] inTable:SESSION_TABLE_NAME];
}

+ (NSString *) tableName {
    return @"SESSIONS";
}

+ (NSString *)stringForCreateTable {
    NSString *str = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (URL_STRING TEXT PRIMARY KEY NOT NULL,TITLE TEXT NOT NULL,SESSION_ID TEXT NOT NULL, FAVORED INTEGER DEFAULT 0);", SESSION_TABLE_NAME];
    return str;
}

+ (NSString *)stringForInsertSession:(Session *)session {
    NSString *str = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@ VALUES(\"%@\", \"%@\", \"%@\", %d);", SESSION_TABLE_NAME,session.urlString, session.title, session.sessionID, session.isFavored];
    return str;
}

+ (NSString *)stringForUpdateSession:(Session *)session {
    NSString *str = [NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET TITLE = %@ SESSION_ID = %@ FAVORED = %d WHERE URL_STRING = %@;",SESSION_TABLE_NAME,session.title, session.sessionID, session.isFavored, session.urlString];
    return str;
}

+ (NSString *)stringForInsertOrReplace:(Session *)session {
    NSString *str = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (URL_STRING, TITLE, SESSION_ID, FAVORED) VALUES(\"%@\", \"%@\", \"%@\",%d);",SESSION_TABLE_NAME,session.urlString,session.title,session.sessionID,session.isFavored];
    return str;
}
@end
