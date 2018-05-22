//
//  DBManager.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
@interface DBManager : NSObject

+ (instancetype) sharedManager;

- (BOOL) createTable:(NSString *)tableName statementString:(NSString *)statementString;

- (BOOL) executeInsertString:(NSString *) insertString inTable:(NSString *)tableName;

- (BOOL) executeUpdateString:(NSString *)updateString inTable:(NSString *)tableName;

- (BOOL) tableExists:(NSString *) tableName;

- (BOOL) saveArrays:(NSArray *) arrays inTable:(NSString *) tableName;
@end
