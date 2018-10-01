//
//  ConferenceTableViewCell.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "ConferenceTableViewCell.h"
#import <Masonry.h>

@interface ConferenceTableViewCell()
@property (nonatomic, strong) UIView *containerView;
@end

@implementation ConferenceTableViewCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self configureViews];
    }
    
    return self;
}

- (void) configureViews {
    self.containerView = [[UIView alloc] init];
    [self.contentView addSubview:self.containerView];
    
    
    self.logoImageView = [[UIImageView alloc] init];
    self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.containerView addSubview:self.logoImageView];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.font = [UIFont systemFontOfSize:20.0];
    [self.containerView addSubview:self.nameLabel];
    
    self.shortDescriptionLabel = [[UILabel alloc] init];
    self.shortDescriptionLabel.textAlignment = NSTextAlignmentLeft;
    self.shortDescriptionLabel.font = [UIFont systemFontOfSize:18.0];
    [self.containerView addSubview:self.shortDescriptionLabel];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    self.timeLabel.font = [UIFont systemFontOfSize:16.0];
    [self.containerView addSubview:self.timeLabel];
    
    
    self.containerView.backgroundColor = [UIColor whiteColor];
    
    self.containerView.layer.cornerRadius = 5.0;
    self.containerView.layer.shadowOpacity = 0.5;
    self.containerView.layer.shadowColor =  [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowRadius = 5.0;
    self.containerView.layer.shadowOffset = CGSizeMake(5, 5);
    self.containerView.layer.masksToBounds = true;
    
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(5);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-5);
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView.mas_top).with.offset(28);
        make.left.equalTo(self.containerView.mas_left).with.offset(8);
        make.bottom.equalTo(self.containerView.mas_bottom).with.offset(-10);
        make.width.equalTo(self.logoImageView.mas_height);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView.mas_top).with.offset(28);
        make.left.equalTo(self.logoImageView.mas_right).with.offset(8);
        make.right.equalTo(self.containerView.mas_right).with.offset(-8);
        make.height.equalTo(@24);
    }];
    
    [self.shortDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(12);
        make.left.equalTo(self.logoImageView.mas_right).with.offset(8);
        make.right.equalTo(self.containerView.mas_right).with.offset(-8);
        make.height.equalTo(@20);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shortDescriptionLabel.mas_bottom).with.offset(12);
        make.left.equalTo(self.logoImageView.mas_right).with.offset(8);
        make.right.equalTo(self.containerView.mas_right).with.offset(-8);
        make.height.equalTo(@20);
    }];
    
    self.containerView.layer.shadowPath = ([[UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds cornerRadius:5.0] CGPath]);
    
}

@end
