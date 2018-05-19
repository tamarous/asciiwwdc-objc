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
@end
