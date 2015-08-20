//
//  KWRefreshComponent.h
//  KWListViewDemo
//
//  Created by kevin on 15/5/17.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KWListViewAdder : UIView
{
    UIEdgeInsets _scrollViewOriginalInset;
    __weak UIScrollView *_scrollView;
}

@property (copy, nonatomic) void (^refreshingBlock)();

- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action;

@property (weak, nonatomic) id refreshingTarget;

@property (assign, nonatomic) SEL refreshingAction;

- (void)beginRefreshing;

- (void)endRefreshing;

- (BOOL)isRefreshing;

@end
