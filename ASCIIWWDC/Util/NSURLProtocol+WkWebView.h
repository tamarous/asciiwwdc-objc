//
//  NSURLProtocol+WkWebView.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/7/31.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLProtocol (WkWebView)
+ (void)wk_registerScheme:(NSString *)scheme;

+ (void)wk_unregisterScheme:(NSString *)scheme;

@end
