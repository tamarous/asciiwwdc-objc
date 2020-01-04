//
//  ZWCacheURLProtocol.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/8/2.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWCacheURLProtocol : NSURLProtocol<NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSessionConfiguration *config;
@property (nonatomic, assign) NSInteger requestInterval;
+ (void)startHookNetwork;
+ (void)stopHookNetwork;
+ (void)setConfig:(NSURLSessionConfiguration *) config;
+ (void)setRequestInterval:(NSInteger) requestInterval;
+ (void)clearUrlDicts;
@end
