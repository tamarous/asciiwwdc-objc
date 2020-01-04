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
#import "Track.h"
#import "BaseModel.h"
@interface DBManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)tableExists:(NSString *)tableName;
- (BOOL)createTable:(NSString *)tableName statementString:(NSString *)statementString;
- (BOOL)executeInsertString:(NSString *)insertString inTable:(NSString *)tableName;
- (BOOL)executeUpdateString:(NSString *)updateString inTable:(NSString *)tableName;

- (NSArray *)loadConferencesArrayFromDatabaseWithQueryString:(NSString *)queryString;
- (NSArray *)loadTracksArrayFromDatabaseWithQueryString:(NSString *)queryString;
- (NSArray *)loadSessionsArrayFromDatabaseWithQueryString:(NSString *)queryString;

- (BOOL)saveModel:(id<BaseModelProtocol>)model;
- (BOOL)updateModel:(id<BaseModelProtocol>)model;
- (BOOL)saveModels:(NSArray<id<BaseModelProtocol> > *)models;
@end
