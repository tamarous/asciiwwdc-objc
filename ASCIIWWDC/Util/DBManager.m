//
//  DBManager.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "DBManager.h"


@interface DBManager()
@property (nonatomic, strong) FMDatabase *dataBase;
@property (nonatomic, copy) NSString *dataBasePath;
@end

@implementation DBManager
- (instancetype) init {
    self = [super init];
    if (self) {
        if ([self databaseExists]) {
        } else {
            [self createDatabase];
            NSLog(@"database created");
        }
    }
    return self;
}

- (BOOL) databaseExists {
    return self.dataBasePath != nil && self.dataBase != nil;
}

- (BOOL) tableExists:(NSString *) tableName {
    if (! [self databaseExists]) {
        NSLog(@"database not exist");
        return NO;
    }
    return [self.dataBase tableExists:tableName];
}

+ (instancetype) sharedManager {
    static DBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DBManager alloc] init];
    });
    return manager;
}

- (void) createDatabase {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.dataBasePath = [paths[0] stringByAppendingPathComponent:@"sessions.db"];
    self.dataBase = [FMDatabase databaseWithPath:self.dataBasePath];
    NSLog(@"%@", self.dataBasePath);
}

- (BOOL) createTable:(NSString *)tableName statementString:(NSString *)statementString {
    if ([self databaseExists]) {
        if ([self.dataBase open]) {
            if (! [self.dataBase tableExists:tableName]) {
                if (! [self.dataBase executeStatements:statementString]) {
                    NSLog(@"create table failed.");
                    return NO;
                }
            }
            [self.dataBase close];
            return YES;
        }
    }
    return NO;
}

- (BOOL) executeStatementString:(NSString *) statementString inTable:(NSString *)tableName {
    NSAssert([self databaseExists], @"database not existed.");
    if ([self.dataBase open]) {
        if (! [self.dataBase executeStatements:statementString]) {
            NSLog(@"create table:%@ failed.", tableName);
            return NO;
        }
        [self.dataBase close];
        return YES;
    }
    return NO;
}

- (BOOL) executeInsertString:(NSString *) insertString inTable:(NSString *)tableName {
    NSAssert([self databaseExists], @"database not existed.");
    if ([self.dataBase open]) {
        if ([self.dataBase tableExists: tableName]) {
            if (! [self.dataBase executeUpdate:insertString]) {
                if ([self.dataBase hadError]) {
                    NSLog(@"Error:%@", [[self.dataBase lastError] domain]);
                }
                NSLog(@"update table:%@ failed.", tableName);
                return NO;
            }
        } else {
            NSLog(@"Table not existed.");
        }
    }
    [self.dataBase close];
    return YES;
}


- (BOOL) executeUpdateString:(NSString *) updateString inTable:(NSString *)tableName {
    NSAssert([self databaseExists], @"database not existed.");
    if ([self.dataBase open]) {
        if ([self.dataBase tableExists: tableName]) {
            if (! [self.dataBase executeUpdate:updateString]) {
                if ([self.dataBase hadError]) {
                    NSLog(@"Error:%@", [[self.dataBase lastError] domain]);
                }
                NSLog(@"update table:%@ failed.", tableName);
                return NO;
            }
        } else {
            NSLog(@"Table not existed.");
        }
    }
    [self.dataBase close];
    return YES;
}


- (BOOL) saveConference:(Conference *)conference {
    NSAssert([self databaseExists], @"database not existed");
    if (! [self tableExists:[Conference tableName]]) {
        [self createTable:[Conference tableName] statementString:[Conference stringForCreateTable]];
    }
    return [self executeInsertString:[Conference stringForInsertConference:conference] inTable:[Conference tableName]];
}

- (BOOL) updateConference:(Conference *)conference {
    return [self executeUpdateString:[Conference stringForUpdateConference:conference] inTable:[Conference tableName]];
}

- (BOOL)updateSession:(Session *)session {
    return [self executeUpdateString:[Session stringForUpdateSession:session] inTable:[Session tableName]];
}

- (BOOL)saveConferencesArray:(NSArray *)conferences {
    NSAssert([self databaseExists], @"database not existed");
    @try{
        if ([self.dataBase open]) {
            if (! [self tableExists:[Conference tableName]]) {
                [self createTable:[Conference tableName] statementString:[Conference stringForCreateTable]];
            }
            [self.dataBase beginTransaction];
            for(Conference *conference in conferences) {
                NSString *insertStr = [Conference stringForInsertConference:conference];
                BOOL res = [self.dataBase executeUpdate:insertStr];
                if (! res) {
                    NSLog(@"failed insert %@", conference.description);
                }
                if ([self.dataBase hadError]) {
                    NSLog(@"Error: %@", self.dataBase.lastError.domain);
                }
            }
            [self.dataBase commit];
            [self.dataBase close];
            return YES;
        }
    } @catch(NSException *e) {
        [self.dataBase rollback];
    }
    return NO;
}

- (BOOL) saveSession:(Session *)session {
    NSAssert([self databaseExists], @"database not existed");
    if (! [self tableExists:[Session tableName]]) {
        [self createTable:[Session tableName] statementString:[Session stringForCreateTable]];
    }
    return [self executeInsertString:[Session stringForInsertSession:session] inTable:[Session tableName]];
}

- (BOOL) saveSessionsArray:(NSArray *)sessions {
    NSAssert([self databaseExists], @"database not existed");
    @try{
        if ([self.dataBase open]) {
            if (! [self tableExists:[Session tableName]]) {
                [self createTable:[Session tableName] statementString:[Session stringForCreateTable]];
            }
            [self.dataBase beginTransaction];
            for(Session *session in sessions) {
                NSString *insertStr = [Session stringForInsertSession:session];
                [self.dataBase executeUpdate:insertStr];
            }
            [self.dataBase commit];
            [self.dataBase close];
            return YES;
        }
    } @catch(NSException *e) {
        [self.dataBase rollback];
    }
    return NO;
}

- (NSArray *)loadSessionsArrayFromDatabaseWithQueryString:(NSString *)queryString {
    NSMutableArray *sessions = [NSMutableArray array];
    if ([self.dataBase open]) {
        if (! [self.dataBase tableExists:[Session tableName]]) {
            return nil;
        }
        if (queryString == nil) {
            queryString = [NSString stringWithFormat:@"SELECT * FROM %@;", [Session tableName]];
        }
        
        FMResultSet *set = [self.dataBase executeQuery:queryString];
        while([set next]) {
            Session *session = [[Session alloc] init];
            session.urlString = [set stringForColumn:@"URL_STRING"];
            session.title = [set stringForColumn:@"TITLE"];
            session.sessionID = [set stringForColumn:@"SESSION_ID"];
            session.isFavored = [set intForColumn:@"FAVORED"];
            [sessions addObject:session];
        }
        [self.dataBase close];
    }
    return [sessions copy];
}

- (NSArray *) loadConferencesArrayFromDatabaseWithQueryString:(NSString *)queryString {
    
    NSMutableArray *conferences = [NSMutableArray array];
    if ([self.dataBase open]) {
        if (! [self.dataBase tableExists:[Conference tableName]]) {
            return nil;
        }
        if (queryString == nil) {
            queryString = [NSString stringWithFormat:@"SELECT * FROM %@", [Conference tableName]];
        }
        
        FMResultSet *set = [self.dataBase executeQuery:queryString];
        while ([set next]) {
            Conference *conference = [[Conference alloc] init];
            conference.name = [set stringForColumn:@"TEXT"];
            conference.shortDescription = [set stringForColumn:@"SHORT_DESCRIPTION"];
            conference.logoUrlString = [set stringForColumn:@"LOGO_URL_STRING"];
            conference.location = [Location locationFromDescriptionString:[set stringForColumn:@"LOCATION"]];
            conference.time = [set stringForColumn:@"TIME"];
            [conferences addObject:conference];
        }
        [self.dataBase close];
    }
    return [conferences copy];
}

- (BOOL) isFavoredForSession:(Session *)session {
    if ( ![self tableExists:[Session tableName]]) {
        return NO;
    }
    int result = NO;
    if ([self.dataBase open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT FAVORED FROM %@ WHERE URL_STRING = \"%@\";", [Session tableName],session.urlString];
        FMResultSet *set = [self.dataBase executeQuery:sql];
        while ([set next]) {
            result = [set intForColumn:@"FAVORED"];
        }
    }
    return result == 1;
}

@end
