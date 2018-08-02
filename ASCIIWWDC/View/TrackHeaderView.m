//
//  TrackHeaderView.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "TrackHeaderView.h"


@interface TrackHeaderView()

@end


@implementation TrackHeaderView
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void) setupUI {
    _isOpen = NO;
    self.backgroundColor = [UIColor whiteColor];
    
    
    [self setShowsTouchWhenHighlighted:YES];
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    
    UIView *underLine = [[UIView alloc] initWithFrame: CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width, 0.5)];
    underLine.backgroundColor = [UIColor grayColor];
    
    [self addSubview:underLine];
    [self addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) clicked: (TrackHeaderView *) sender {
    [self.delegate trackDidClicked:sender];
    _isOpen = ! _isOpen;
}
@end
