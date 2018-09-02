//
//  Track.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "Track.h"
static NSString * TRACK_TABLE_NAME = @"TRACKS";


@implementation Track

+ (NSString *) tableName {
    return TRACK_TABLE_NAME;
}

+ (NSString *) stringForCreateTable {
    NSString *str = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (TRACK_ID INTEGER PRIMARY KEY,TRACK_NAME TEXT, CONFERENCE_NAME TEXT NOT NULL);",TRACK_TABLE_NAME];
    return str;
}

+ (NSString *) stringForInsertTrack:(Track *)track {
    NSString *str = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@ VALUES(NULL,\"%@\",\"%@\");",TRACK_TABLE_NAME,track.trackName,track.conferenceName];
    return str;
}

+ (NSString *) stringForUpdateTrack:(Track *)track {
    NSString *str = [NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET TRACK_NAME = \"%@\", CONFERENCE_NAME = \"%@\";",TRACK_TABLE_NAME,track.trackName,track.conferenceName];
    return str;
}

+ (NSString *) stringForInsertOrReplaceTrack:(Track *)track {
    NSString *str = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (TRACK_NAME, CONFERENCE_NAME) VALUES(\"%@\",\"%@\");",TRACK_TABLE_NAME,track.trackName,track.conferenceName];
    return str;
}

@end
