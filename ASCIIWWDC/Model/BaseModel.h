//
//  BaseModel.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2020/1/2.
//  Copyright © 2020 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BaseModelProtocol <NSObject>

+ (NSString *)tableName;
+ (NSString *)statementForCreateTable;
- (NSString *)statementForInsert;
- (NSString *)statementForUpdate;

@optional
- (NSString *)statementForInsertOrReplace;

- (NSArray<id<BaseModelProtocol>> *)subModels;

@end

NS_ASSUME_NONNULL_END
