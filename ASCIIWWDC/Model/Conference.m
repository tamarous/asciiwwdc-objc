//
//  Conference.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "Conference.h"

@implementation Conference
- (NSString *) description {
    NSString *desc = [NSString stringWithFormat:@"name: %@, desc: %@, time: %@\n", self.name, self.shortDescription, self.time];
    return desc;
}
@end
