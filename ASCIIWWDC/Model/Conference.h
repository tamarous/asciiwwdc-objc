//
//  Conference.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"
#import "BaseModel.h"

@interface Location : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *streetAddress;
@property (nonatomic, copy) NSString *addressLocality;
@property (nonatomic, copy) NSString *addressRegion;
@property (nonatomic, copy) NSString *postalCode;
@property (nonatomic, copy) NSString *addressCountry;
+ (instancetype) locationFromDescriptionString:(NSString *) description;
@end

@interface Conference : NSObject <BaseModelProtocol>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *logoUrlString;
@property (nonatomic, copy) NSString *shortDescription;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) NSArray<Track *> *tracks;
@end
