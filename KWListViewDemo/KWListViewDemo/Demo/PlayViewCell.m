//
//  PlayViewCell.m
//  KWListViewDemo
//
//  Created by 凯文马 on 15/10/1.
//  Copyright © 2015年 凯文马. All rights reserved.
//

#import "PlayViewCell.h"
#import "PlaySuccessModel.h"

@interface PlayViewCell ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation PlayViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(PlaySuccessModel *)model
{
    static NSString *ID = @"PlayViewCell";
    PlayViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[PlayViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        [cell addBaseView];
    }
    cell.model = model;
    return cell;
}

- (void)addBaseView
{
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.frame = CGRectMake(10, 10, 200, [nameLabel.font singleLineHeight]);
    nameLabel.textColor = [UIColor redColor];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.size.height + nameLabel.frame.origin.y + 10, [UIScreen mainScreen].bounds.size.width - 2 * nameLabel.frame.origin.x, 0)];
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.numberOfLines = 0;
    [self.contentView addSubview:contentLabel];
    self.contentLabel = contentLabel;
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.frame =  CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - nameLabel.frame.origin.x, [timeLabel.font singleLineHeight]);
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
}

- (void)setModel:(PlaySuccessModel *)model
{
    _model = model;
    _nameLabel.text = model.userName;
    _contentLabel.text = model.content;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日 HH:mm";
    _timeLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.time]];
    
    // 位置移动
    CGFloat height = [_contentLabel.text boundingRectWithSize:CGSizeMake(_contentLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_contentLabel.font} context:nil].size.height;
    _contentLabel.frame = (CGRect){_contentLabel.frame.origin,{_contentLabel.frame.size.width,height}};
    
    CGRect tempRect = _timeLabel.frame;
    tempRect.origin.y = _contentLabel.frame.origin.y + _contentLabel.frame.size.height + 10;
    _timeLabel.frame = tempRect;
}
@end

@implementation UIFont (KW)

- (CGFloat)singleLineHeight
{
    return [@"kw" boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self} context:nil].size.height;
}

@end