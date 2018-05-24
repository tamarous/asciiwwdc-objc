//
//  DBManager.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "Conference.h"
#import "Session.h"
@interface DBManager : NSObject

+ (instancetype) sharedManager;

- (BOOL) tableExists:(NSString *) tableName;

- (BOOL) createTable:(NSString *)tableName statementString:(NSString *)statementString;

- (BOOL) executeInsertString:(NSString *) insertString inTable:(NSString *)tableName;

- (BOOL) executeUpdateString:(NSString *)updateString inTable:(NSString *)tableName;

- (BOOL) saveSession:(Session *) session;

- (BOOL) updateSession:(Session *) session;

- (BOOL) saveSessionsArray:(NSArray *) sessions;

- (BOOL) saveConference:(Conference *) conference;

- (BOOL) updateConference:(Conference *) conference;

- (BOOL) saveConferencesArray:(NSArray *) conferences;

- (NSArray *) loadConferencesArrayFromDatabase;

- (NSArray *) loadSessionsArrayFromDatabase;
@end
