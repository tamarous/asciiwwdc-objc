//
//  Session.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
@interface Session : NSObject <BaseModelProtocol>
@property (nonatomic, copy) NSString *sessionID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *trackName;
@property (nonatomic, assign) BOOL isFavored;
@end
