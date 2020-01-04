//
//  Conference.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "Conference.h"
static NSString * CONFERENCE_TABLE_NAME = @"CONFERENCES";

@implementation Location
- (id)copyWithZone:(NSZone *)zone {
    Location *newLocation = [[Location alloc] init];
    newLocation.addressRegion = [_addressRegion copyWithZone:zone];
    newLocation.addressCountry = [_addressCountry copyWithZone:zone];
    newLocation.addressLocality = [_addressLocality copyWithZone:zone];
    newLocation.streetAddress = [_streetAddress copyWithZone:zone];
    newLocation.name = [_name copyWithZone:zone];
    return newLocation;
}

- (NSString *)description {
    NSString *str = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@", _name, _streetAddress, _addressLocality, _addressRegion, _postalCode, _addressCountry];
    return str;
}

+ (instancetype)locationFromDescriptionString:(NSString *)description {
    Location *location = [[Location alloc] init];
    NSArray *array = [description componentsSeparatedByString:@","];
    location.name = array[0];
    location.streetAddress = array[1];
    location.addressLocality = array[2];
    location.addressRegion = array[3];
    location.postalCode = array[4];
    location.addressCountry = array[5];
    return location;
}
@end

@implementation Conference
- (NSString *)description {
    NSString *desc = [NSString stringWithFormat:@"name: %@, desc: %@, time: %@\n", self.name, self.shortDescription, self.time];
    return desc;
}

#pragma mark - BaseModelProtocol
+ (NSString *)tableName {
    return NSStringFromClass([self class]);
}

+ (NSString *)statementForCreateTable {
    NSString *str = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (NAME TEXT PRIMARY KEY NOT NULL, LOGO_URL_STRING TEXT NOT NULL, SHORT_DESCRIPTION TEXT NOT NULL, TIME TEXT NOT NULL, LOCATION TEXT NOT NULL);", [[self class] tableName]];
       return str;
}

- (NSString *)statementForUpdate {
    NSString *str = [NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET LOGO_URL_STRING = \"%@\" ,SHORT_DESCRIPTION = \"%@\", ,TIME = \"%@\" ,LOCATION = \"%@\" WHERE NAME = \"%@\";",[[self class] tableName], self.logoUrlString, self.shortDescription, self.time, self.location.description, self.name];
    return str;
}

- (NSString *)statementForInsert {
    NSString *str = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@ VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\");",[[self class] tableName], self.name, self.logoUrlString, self.shortDescription, self.time, self.location.description];
    return str;
}

- (NSArray<id<BaseModelProtocol>> *)subModels {
    return self.tracks;
}
@end
