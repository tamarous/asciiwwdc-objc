//
//  Track.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface Track : NSObject <BaseModelProtocol>
@property (nonatomic, copy) NSString *trackName;
@property (nonatomic, copy) NSString *conferenceName;
@property (nonatomic, copy) NSArray *sessions;

@end
