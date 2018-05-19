//
//  ConferenceTableViewCell.h
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conference.h"
@interface ConferenceTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *shortDescriptionLabel;
@property (nonatomic, strong) UILabel *timeLabel;
//@property (nonatomic, strong) UILabel *LocationLabel;
@end
