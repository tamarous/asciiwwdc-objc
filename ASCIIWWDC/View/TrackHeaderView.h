//
//  TrackHeaderView.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrackHeaderView;

@protocol TrackHeaderViewDelegate <NSObject>
- (void)trackDidClicked:(TrackHeaderView *)trackHeaderView;
@end

@interface TrackHeaderView : UIButton
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, weak) id<TrackHeaderViewDelegate> delegate;
@end
