//
//  UINavigationController+AutoRotate.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/7/31.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "UINavigationController+AutoRotate.h"

@implementation UINavigationController(AutoRotate)
- (BOOL) shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return  [self.topViewController supportedInterfaceOrientations];
}

@end
