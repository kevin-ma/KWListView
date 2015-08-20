//
//  UIScrollView+KW.h
//  KWListViewDemo
//
//  Created by kevin on 15/5/17.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KWListViewConfig.h"

@class KWListViewHeader;
@class KWListViewFooter;

@interface UIScrollView (KW)
@property (assign, nonatomic) CGFloat kw_insetT;
@property (assign, nonatomic) CGFloat kw_insetB;
@property (assign, nonatomic) CGFloat kw_insetL;
@property (assign, nonatomic) CGFloat kw_insetR;

@property (assign, nonatomic) CGFloat kw_offsetX;
@property (assign, nonatomic) CGFloat kw_offsetY;

@property (assign, nonatomic) CGFloat kw_contentSizeW;
@property (assign, nonatomic) CGFloat kw_contentSizeH;

@end

@interface UIScrollView (List)

#pragma mark - 访问下拉刷新控件
/** 下拉刷新控件 */
@property (strong, nonatomic, readonly) KWListViewHeader *header;

#pragma mark - 添加下拉刷新控件

/**
 * 添加一个gif图片的下拉刷新控件
 *
 * @param block 进入刷新状态就会自动调用这个block
 */
- (KWListViewHeader *)addHeaderWithRefreshingBlock:(void (^)())block;

/**
 * 添加一个gif图片的下拉刷新控件
 *
 * @param target 进入刷新状态就会自动调用target对象的action方法
 * @param action 进入刷新状态就会自动调用target对象的action方法
 */
- (KWListViewHeader *)addHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

#pragma mark - 移除下拉刷新控件
/**
 * 移除下拉刷新控件
 */
- (void)removeHeader;

#pragma mark - 访问上拉刷新控件
/** 上拉刷新控件 */
@property (strong, nonatomic, readonly) KWListViewFooter *footer;

#pragma mark - 添加上拉刷新控件
/**
 * 添加一个传统的上拉刷新控件
 *
 * @param block 进入刷新状态就会自动调用这个block
 */
- (KWListViewFooter *)addFooterWithRefreshingBlock:(void (^)())block;
/**
 * 添加一个传统的上拉刷新控件
 *
 * @param target 进入刷新状态就会自动调用target对象的action方法
 * @param action 进入刷新状态就会自动调用target对象的action方法
 */
- (KWListViewFooter *)addFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

#pragma mark - 移除上拉刷新控件
/**
 * 移除上拉刷新控件
 */
- (void)removeFooter;
@end
