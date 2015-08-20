//
//  KWRefreshComponent.m
//  KWListViewDemo
//
//  Created by kevin on 15/5/17.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "KWListViewAdder.h"
#import "KWListViewConfig.h"
#import "UIView+KW.h"

@interface KWListViewAdder ()

@property (assign, nonatomic) UIEdgeInsets scrollViewOriginalInset;

@property (weak, nonatomic) UIScrollView *scrollView;
@end

@implementation KWListViewAdder
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    [self.superview removeObserver:self forKeyPath:KWRefreshContentOffset context:nil];
    
    if (newSuperview) {
        [newSuperview addObserver:self forKeyPath:KWRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
        self.kw_w = newSuperview.kw_w;
        self.kw_x = 0;
        self.scrollView = (UIScrollView *)newSuperview;
        self.scrollView.alwaysBounceVertical = YES;
        self.scrollViewOriginalInset = self.scrollView.contentInset;
    }
}

#pragma mark - 公共方法
- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    self.refreshingTarget = target;
    self.refreshingAction = action;
}

- (void)beginRefreshing
{
    
}

- (void)endRefreshing
{
    
}

- (BOOL)isRefreshing {
    return NO;
}

@end
