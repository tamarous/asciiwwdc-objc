//
//  DBManager.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "DBManager.h"
#import <FMDB.h>
#import "Conference.h"
#import "Session.h"
#import "Track.h"
@interface DBManager()
@property (nonatomic, strong) FMDatabase *dataBase;
@property (nonatomic, copy) NSString *dataBasePath;
- (BOOL)tableExists:(NSString *)tableName;
- (BOOL)createTable:(NSString *)tableName statementString:(NSString *)statementString;
- (BOOL)executeInsertString:(NSString *)insertString inTable:(NSString *)tableName;
- (BOOL)executeUpdateString:(NSString *)updateString inTable:(NSString *)tableName;
@end

@implementation DBManager
#pragma mark - DBManager

- (instancetype)init {
    self = [super init];
    if (self) {
        if (![self databaseExists]) {
            [self createDatabase];
            NSLog(@"database created");
        }
    }
    return self;
}

- (BOOL)databaseExists {
    return self.dataBasePath && self.dataBase;
}

- (BOOL)tableExists:(NSString *) tableName {
    if (! [self databaseExists]) {
        NSLog(@"database not exist");
        return NO;
    }
    return [self.dataBase tableExists:tableName];
}

+ (instancetype)sharedManager {
    static DBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DBManager alloc] init];
    });
    return manager;
}

- (void)dealloc {
    [self.dataBase close];
}

- (void)createDatabase {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.dataBasePath = [paths[0] stringByAppendingPathComponent:@"sessions.db"];
    self.dataBase = [FMDatabase databaseWithPath:self.dataBasePath];
    NSLog(@"%@", self.dataBasePath);
}

- (BOOL)createTable:(NSString *)tableName statementString:(NSString *)statementString {
    if ([self databaseExists] && [self.dataBase open]) {
        if (![self.dataBase tableExists:tableName]) {
            if (![self.dataBase executeStatements:statementString]) {
                NSLog(@"create table failed.");
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)executeStatementString:(NSString *)statementString inTable:(NSString *)tableName {
    if ([self.dataBase open]) {
        if (![self.dataBase executeStatements:statementString]) {
            NSLog(@"create table:%@ failed.", tableName);
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)executeInsertString:(NSString *)insertString inTable:(NSString *)tableName {
    if ([self.dataBase open]) {
        if ([self.dataBase tableExists:tableName]) {
            if (![self.dataBase executeUpdate:insertString]) {
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
    return YES;
}

- (BOOL)executeUpdateString:(NSString *)updateString inTable:(NSString *)tableName {
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
    return YES;
}


#pragma mark - Conference related
- (NSArray *)loadConferencesArrayFromDatabaseWithQueryString:(NSString *)queryString {
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
            conference.name = [set stringForColumn:@"NAME"];
            conference.shortDescription = [set stringForColumn:@"SHORT_DESCRIPTION"];
            conference.logoUrlString = [set stringForColumn:@"LOGO_URL_STRING"];
            conference.location = [Location locationFromDescriptionString:[set stringForColumn:@"LOCATION"]];
            conference.time = [set stringForColumn:@"TIME"];
            conference.tracks = [self loadTracksArrayFromDatabaseWithQueryString:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE CONFERENCE_NAME = \"%@\";", [Track tableName], conference.name]];
            [conferences addObject:conference];
        }
    }
    return [conferences copy];
}

#pragma mark - Track related
- (NSArray *)loadTracksArrayFromDatabaseWithQueryString:(NSString *)queryString {
    NSMutableArray *tracks = [NSMutableArray array];
    if ([self.dataBase open]) {
        if (![self.dataBase tableExists:[Track tableName]]) {
            return nil;
        }
        if (queryString == nil) {
            queryString = [NSString stringWithFormat:@"SELECT * FROM %@;", [Track tableName]];
        }
        
        FMResultSet *set = [self.dataBase executeQuery:queryString];
        while([set next]) {
            Track *track = [[Track alloc] init];
            track.trackName = [set stringForColumn:@"TRACK_NAME"];
            track.conferenceName = [set stringForColumn:@"CONFERENCE_NAME"];
            track.sessions = [self loadSessionsArrayFromDatabaseWithQueryString:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE TRACK_NAME = \"%@\";",[Session tableName], track.trackName]];
            [tracks addObject:track];
        }
    }
    return [tracks copy];
}


#pragma mark - Session related
- (NSArray *)loadSessionsArrayFromDatabaseWithQueryString:(NSString *)queryString {
    NSMutableArray *sessions = [NSMutableArray array];
    if ([self.dataBase open]) {
        if (![self.dataBase tableExists:[Session tableName]]) {
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
            session.trackName = [set stringForColumn:@"TRACK_NAME"];
            [sessions addObject:session];
        }
    }
    return [sessions copy];
}

- (BOOL)saveModel:(id<BaseModelProtocol>)model {
    if (![self tableExists:[[model class] tableName]]) {
       [self createTable:[[model class] tableName] statementString:[[model class] statementForCreateTable]];
    }
    return [self executeInsertString:[model statementForInsert] inTable:[[model class] tableName]];
}

- (BOOL)updateModel:(id<BaseModelProtocol>)model {
   return [self executeUpdateString:[model statementForUpdate] inTable:[[model class] tableName]];
}

- (BOOL)saveModels:(NSArray<id<BaseModelProtocol>> *)models {
    if ([self.dataBase open]) {
        if (![self tableExists:[[models[0] class] tableName]]) {
            [self createTable:[[models[0] class] tableName] statementString:[[models[0] class] statementForCreateTable]];
        }
        if (!self.dataBase.isInTransaction) {
            @try{
                [self.dataBase beginTransaction];
                for(id<BaseModelProtocol> model in models) {
                    [self saveModel:model];
                    if ([model respondsToSelector:@selector(subModels)] && model.subModels) {
                        NSArray<id<BaseModelProtocol> > *subModels = [model subModels];
                        [self saveModels:subModels];
                    }
                    if ([self.dataBase hadError]) {
                        NSLog(@"Error: %@", self.dataBase.lastError.domain);
                    }
                }
                [self.dataBase commit];
                return YES;
            } @catch(NSException *e) {
                [self.dataBase rollback];
                return NO;
            }
        } else {
            for(id<BaseModelProtocol> model in models) {
                [self saveModel:model];
                if ([model respondsToSelector:@selector(subModels)] && model.subModels) {
                    NSArray<id<BaseModelProtocol> > *subModels = [model subModels];
                    [self saveModels:subModels];
                }
                if ([self.dataBase hadError]) {
                    NSLog(@"Error: %@", self.dataBase.lastError.domain);
                }
            }
            return YES;
        }
    }
    return NO;
}
@end
