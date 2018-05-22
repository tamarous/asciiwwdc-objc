//
//  Conference.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "Conference.h"
static NSString * CONFERENCE_TABLE_NAME = @"CONFERENCES";

@implementation Conference
- (NSString *) description {
    NSString *desc = [NSString stringWithFormat:@"name: %@, desc: %@, time: %@\n", self.name, self.shortDescription, self.time];
    return desc;
}

- (BOOL) save {
    if (! [[DBManager sharedManager] tableExists:CONFERENCE_TABLE_NAME]) {
        [[DBManager sharedManager] createTable:CONFERENCE_TABLE_NAME statementString: [[self class] stringForCreateTable]];
    }
    return [[DBManager sharedManager] executeInsertString:[[self class] stringForInsertConference:self] inTable:CONFERENCE_TABLE_NAME];
}

- (BOOL) update {
    return [[DBManager sharedManager] executeUpdateString:[[self class] stringForUpdateConference:self] inTable:CONFERENCE_TABLE_NAME];
}

+ (NSString *) tableName {
    return @"CONFERENCES";
}

+ (NSString *) stringForCreateTable {
    NSString *str = [NSString stringWithFormat:@"CREATE TABLE %@ IF NOT EXISTS (NAME TEXT PRIMARY KEY NOT NULL, LOGO_URL_STRING TEXT NOT NULL, SHORT_DESCRIPTION TEXT NOT NULL, TIME TEXT NOT NULL, LOCATION TEXT NOT NULL);", CONFERENCE_TABLE_NAME];
    return str;
}

+ (NSString *)stringForInsertConference:(Conference *)conference {
    NSString *str = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@ VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\");",CONFERENCE_TABLE_NAME, conference.name, conference.logoUrlString,conference.shortDescription, conference.time, conference.location.description];
    return str;
}

+ (NSString *)stringForUpdateConference:(Conference *)conference {
    NSString *str = [NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET LOGO_URL_STRING = %@  SHORT_DESCRIPTION = %@ TIME = %@ LOCATION = %@ WHERE NAME = %@;",CONFERENCE_TABLE_NAME, conference.logoUrlString,conference.shortDescription,conference.time,conference.location.description, conference.name];
    return str;
}
@end
