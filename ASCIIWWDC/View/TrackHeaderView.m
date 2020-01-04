//
//  TrackHeaderView.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "TrackHeaderView.h"
#import <ReactiveObjC/ReactiveObjC.h>
@implementation TrackHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.isOpen = NO;
    self.backgroundColor = [UIColor whiteColor];

    [self setShowsTouchWhenHighlighted:YES];
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    UIView *underLine = [[UIView alloc] initWithFrame: CGRectMake(0, CGRectGetHeight(self.bounds) - 0.5, CGRectGetWidth(self.bounds), 0.5)];
    underLine.backgroundColor = [UIColor grayColor];
    
    [self addSubview:underLine];
    @weakify(self);
    [[self rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(trackDidClicked:)]) {
            [self.delegate trackDidClicked:self];
        }
        self.isOpen = !self.isOpen;
    }];
}
@end
