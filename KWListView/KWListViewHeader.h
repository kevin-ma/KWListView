//  Copyright (c) 2015年 kevin. All rights reserved.
//
//  文件名称：KWListViewHeader.h
//  项目名称：KWListViewDemo
//  作   者：kevin
//  创建时间：15/5/17
//  文件说明：

#import "KWListViewAdder.h"

typedef enum {
    KWListViewHeaderStateIdle = 1,
    KWListViewHeaderStatePulling,
    KWListViewHeaderStateRefreshing,
    KWListViewHeaderStateWillRefresh
} KWListViewHeaderState;

@interface KWListViewHeader : KWListViewAdder

@property (assign, nonatomic) KWListViewHeaderState state;

#pragma mark - 交给子类重写

@property (assign, nonatomic) CGFloat pullingPercent;

- (void)setImages:(NSArray *)images forState:(KWListViewHeaderState)state;
@end
