//
//  PlayViewCell.h
//  KWListViewDemo
//
//  Created by 凯文马 on 15/10/1.
//  Copyright © 2015年 凯文马. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlaySuccessModel;

@interface PlayViewCell : UITableViewCell

@property (nonatomic, strong) PlaySuccessModel *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(PlaySuccessModel *)model;

@end


@interface UIFont (KW)

- (CGFloat)singleLineHeight;

@end