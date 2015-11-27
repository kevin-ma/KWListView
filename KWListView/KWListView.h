//  Copyright (c) 2015年 kevin. All rights reserved.
//
//  文件名称：KWListView.h
//  项目名称：KWListViewDemo
//  作   者：kevin
//  创建时间：15/5/18

/*
    用途：
        该控件用于显示列表式数据。
 
    优点：
        1. 免去tableView大量的数据源方法
        2. cell高度全自动计算
        3. 只需在block中写好请求即可完成显示
 
    使用方法请参照注释说明及Demo
    
    如发现BUG请联系QQ：694999544
 */



#import <UIKit/UIKit.h>
#import "KWListViewConfig.h"
#import "KWListViewHeader.h"

/**
 *  自动计算高度时，将视图tag设置为此值，则自动计算高度时忽略此视图
 */
UIKIT_EXTERN const NSInteger KWUncountTag;

@class KWListView;
/**
 *  请求操作
 *
 *  @param currentPage 待请求的页面
 *  @param ^           （请求结果&请求数据）
 */
typedef void(^KWReuqestBlock)(NSMutableDictionary *parameters, void(^)(BOOL success,id result));

@protocol KWListViewDataSource <NSObject>
/**
 *  数据源方法：设置每row的cell（请尽量复用cell）
 *
 *  @param listView 当前控件
 *  @param row      操作行数
 *
 *  @return 显示的cell
 */
- (UITableViewCell *)listView:(KWListView *)listView cellForRow:(NSInteger)row;
@optional
/**
 *  数据源方法：设置头部刷新的图片动画（可选）
 *
 *  @param listView 当前控件
 *  @param state    刷新时的几种状态
 *
 *  @return 动画的图片数组
 */
- (NSArray *)listView:(KWListView *)listView imagesForRefreshWithState:(KWListViewHeaderState)state;

/**
 *  数据源方法：设置每一行的高度（可选，当不实现时系统会自动计算高度）
 *
 *  @param listView 当前控件
 *  @param row      操作行数
 *
 *  @return 高度
 */
- (CGFloat)listView:(KWListView *)listView heightForRow:(NSInteger)row;

/**
 *  数据源方法：设置一共有多少行数据（可选，当不实现时系统会使用请求返回数量）
 *
 *  @param listView 当前控件
 *
 *  @return 行数
 */
- (NSInteger)listViewHasNumberOfRows:(KWListView *)listView;

/**
 *  数据源方法：是否可编辑（可选）
 *
 *  @param listView 当前控件
 *  @param row      操作行数
 *
 *  @return 是否可编辑
 */
- (BOOL)listView:(KWListView *)listView canEditRow:(NSInteger)row;

/**
 *  数据源方法：是否高亮（可选）
 *
 *  @param listView 当前控件
 *  @param row      操作行数
 *
 *  @return 是否高亮
 */
- (BOOL)listView:(KWListView *)listView shouldHighlightRow:(NSInteger)row;

- (void)listView:(KWListView *)listView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRow:(NSInteger)row;

@end

@protocol KWListViewDelegate <NSObject>
@optional
- (void)listView:(KWListView *)listView didSelectRow:(NSInteger)row;
- (void)listView:(KWListView *)listView didDeselectRow:(NSInteger)row;
- (void)listViewDidScroll:(KWListView *)listView;
/**
 *  代理方法：请求失败时会调用此方法
 *
 *  @param listView 当前控件
 */
- (void)listViewDidFailedReceiveData:(KWListView *)listView;

/**
 *  代理方法：请求数据为空时会调用此方法
 *
 *  @param listView 当前控件
 */
- (void)listViewDidReceiveEmptyData:(KWListView *)listView;

- (void)listViewDidEndDragging:(KWListView *)listView willDecelerate:(BOOL)decelerate;

- (void)listViewWillBeginDragging:(KWListView *)listView;
@end

@interface KWListView : UITableView
@property (nonatomic, assign) BOOL isLoadingData;

/**
 *  用来计算cell高度，距离最下面的子视图的高度差（系统自动计算cell高度时有效,若未设置则默认为最上面的子视图距cell上面的距离）
 */
@property (nonatomic, assign) CGFloat bottomMargin;

/**
 *  每次请求的数量，请设置与实际请求数量相同
 */
@property (nonatomic, assign) NSInteger pageSize;

/**
 *  请求成功时返回的数据
 */
@property (nonatomic, strong) NSMutableArray *datas;

/**
 *  数据源
 */
@property (nonatomic, weak) id<KWListViewDataSource> listDataSource;

/**
 *  代理
 */
@property (nonatomic, weak) id<KWListViewDelegate> listDelegate;

/**
 *  请求操作请在这里完成
 */
@property (nonatomic, copy) KWReuqestBlock requestAction;

@property (nonatomic, assign) BOOL withoutLoadingMore;
@property (nonatomic, assign) BOOL withoutRefresh;
@property (nonatomic, assign ,readonly) BOOL needLoadData;
@property (nonatomic, strong) UIView *emptyView;

/**
 *  刷新某一行数据(无动画)
 *
 *  @param row 某一行
 */
- (void)reloadDataAtRow:(NSInteger)row;

/**
 *  刷新某一行数据（可设置动画）
 *
 *  @param row       某一行
 *  @param animation 设置动画
 */
- (void)reloadDataAtRow:(NSInteger)row withRowAnimation:(UITableViewRowAnimation)animation;

/**
 *  设置数据为空时显示的内容（有默认值）
 *
 *  @param text  文字提示
 *  @param image 图片提示
 */
- (void)setEmptyText:(NSString *)text image:(UIImage *)image;

/**
 *  设置数据请求失败时显示的内容（有默认值）
 *
 *  @param text  文字提示
 *  @param image 图片提示
 */
- (void)setFailedText:(NSString *)text image:(UIImage *)image;

- (void)deselectRow:(NSInteger)row animated:(BOOL)animated;

- (void)setDelegate:(id<KWListViewDelegate>)delegate;
- (void)setDataSource:(id<KWListViewDataSource>)dataSource;
- (void)loadData;
@end
