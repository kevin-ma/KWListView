//  Copyright (c) 2015年 kevin. All rights reserved.
//
//  文件名称：KWListViewFooter.h
//  项目名称：KWListViewDemo
//  作   者：kevin
//  创建时间：15/5/17

#import "KWListViewAdder.h"

typedef enum {
    KWListViewFooterStateIdle = 1, // 普通闲置状态
    KWListViewFooterStateRefreshing, // 正在刷新中的状态
    KWListViewFooterStateNoMoreData // 所有数据加载完毕，没有更多的数据了
} KWListViewFooterState;


@interface KWListViewFooter : KWListViewAdder

- (void)noticeNoMoreData;

- (void)resetNoMoreData;


@property (assign, nonatomic) KWListViewFooterState state;


@property (assign, nonatomic, getter=isAutomaticallyRefresh) BOOL automaticallyRefresh;


@property (assign, nonatomic) CGFloat appearencePercentTriggerAutoRefresh;


@property (strong, nonatomic) UIColor *textColor;

@property (strong, nonatomic) UIFont *font;

@end
