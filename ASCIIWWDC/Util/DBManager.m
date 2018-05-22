//
//  DBManager.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "DBManager.h"
#import "Session.h"


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

- (BOOL)saveArrays:(NSArray *)arrays inTable:(NSString *)tableName {
    
    return YES;
}
@end
