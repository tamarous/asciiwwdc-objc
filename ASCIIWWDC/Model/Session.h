//
//  Session.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject
@property (nonatomic, copy) NSString *sessionID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign) BOOL isFavored;
+ (NSString *) tableName;
+ (NSString *) stringForCreateTable;
+ (NSString *) stringForInsertSession:(Session *) session;
+ (NSString *) stringForUpdateSession:(Session *) session;
+ (NSString *) stringForInsertOrReplace:(Session *) session;
//- (BOOL) save;
//- (BOOL) update;
//- (BOOL) insertOrReplace;
@end
