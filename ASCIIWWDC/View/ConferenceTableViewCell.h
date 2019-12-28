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

- (void)configureWithConference:(Conference *)conference;
@end
