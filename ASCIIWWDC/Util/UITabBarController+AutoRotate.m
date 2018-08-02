//
//  UITabViewController+AutoRotate.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/8/1.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "UITabBarController+AutoRotate.h"

@implementation UITabBarController (AutoRotate)
- (BOOL) shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}
@end
