//
//  Location.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "Location.h"
@interface Location() <NSCopying>
@end

@implementation Location
- (id) copyWithZone:(NSZone *)zone {
    Location *newLocation = [[Location alloc] init];
    newLocation.addressRegion = [_addressRegion copyWithZone:zone];
    newLocation.addressCountry = [_addressCountry copyWithZone:zone];
    newLocation.addressLocality = [_addressLocality copyWithZone:zone];
    newLocation.streetAddress = [_streetAddress copyWithZone:zone];
    newLocation.name = [_name copyWithZone:zone];
    return newLocation;
}

- (NSString *) description {
    NSString *str = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@", _name, _streetAddress, _addressLocality, _addressRegion, _postalCode, _addressCountry];
    return str;
}

+ (instancetype) locationFromDescriptionString:(NSString *)description {
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
