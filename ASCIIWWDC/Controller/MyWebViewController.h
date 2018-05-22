//
//  WebViewController.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
@interface MyWebViewController : UIViewController
@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, strong) Session *session;
@end
