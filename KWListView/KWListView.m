//  Copyright (c) 2015年 kevin. All rights reserved.
//
//  文件名称：KWListView.m
//  项目名称：KWListViewDemo
//  作   者：kevin
//  创建时间：15/5/18

#import "KWListView.h"
#import "UIScrollView+KW.h"
#import "KWListViewConfig.h"
#import "KWListViewFooter.h"

const NSInteger KWListViewCellImageTag = 694999;
const NSInteger KWListViewCellTextTag = 694998;
const NSInteger KWUncountTag = 694990;
const NSInteger KWEmptyViewTag = 6949998;

typedef NS_ENUM(NSInteger, KWLoadDataType) {
    KWLoadDataTypeRefresh = 1,
    KWLoadDataTypeMore,
};

@interface KWListView () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *cells;

@property (nonatomic, assign) BOOL hasSuperView;
@property (nonatomic, assign) BOOL hasDataSource;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) BOOL dataHasLoaded; // 已经加载过数据

# pragma mark - empty
@property (nonatomic, assign) BOOL empty;
@property (nonatomic, copy) NSString *emptyText;
@property (nonatomic, strong) UIImage *emptyImage;
@property (nonatomic, strong) UITableViewCell *emptyCell;

# pragma mark - failed
@property (nonatomic, assign) BOOL failed;
@property (nonatomic, copy) NSString *failedText;
@property (nonatomic, strong) UIImage *failedImage;
@property (nonatomic, strong) UITableViewCell *failedCell;

# pragma mark - nomore
@property (nonatomic, assign) BOOL noMore;
@end

@implementation KWListView
# pragma mark - basic
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self setValue:[UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.760] forKey:@"multiselectCheckmarkColor"];
        self.delegate = (id<KWListViewDelegate>)self;
        self.dataSource = (id<KWListViewDataSource>)self;
        _hasDataSource = NO;
        _hasSuperView = NO;
        _bottomMargin = -1;
        _pageSize = 20;
        _needLoadData = YES;
        _failedImage = [UIImage imageNamed:KWListViewFailedImageName];
        _emptyImage = [UIImage imageNamed:KWListViewEmptyImageName];
        _emptyText = KWListViewEmptyText;
    }
    return self;
}

- (NSInteger)pageSize
{
    if (_pageSize <= 0 ) {
        _pageSize = 10;
    }
    return _pageSize;
}

- (NSMutableDictionary *)cells
{
    if (!_cells) {
        _cells = [@{} mutableCopy];
    }
    return _cells;
}

- (void)setDelegate:(id<KWListViewDelegate>)delegate
{
    if ([self isEqual:delegate]) {
        [super setDelegate:(id<UITableViewDelegate>)delegate];
    } else {
        self.listDelegate = delegate;
    }
}

- (void)setDataSource:(id<KWListViewDataSource>)dataSource
{
    if ([self isEqual:dataSource]) {
        [super setDataSource:(id<UITableViewDataSource>)dataSource];
    } else {
        self.listDataSource = dataSource;
    }
}

# pragma mark - as tableView

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    UITableViewCell *cell = [super dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [self cellWithIdentifier:identifier];
        if (cell) {
            [self removeCell:cell];
        }
    }
    return cell;
}

# pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.empty || self.failed) {
        return 1;
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(listViewHasNumberOfRows:)]) {
        return [self.listDataSource listViewHasNumberOfRows:self];
    } else {
        return self.datas.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.empty) {
        return [self emptyCell];
    }
    if (self.failed) {
        return [self failedCell];
    }
    UITableViewCell *cell = [self.listDataSource listView:self cellForRow:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.empty || self.failed) {
        return self.frame.size.height;
    }
    if (self.listDataSource && [self.listDataSource respondsToSelector:@selector(listView:heightForRow:)]) {
        return [self.listDataSource listView:self heightForRow:indexPath.row];
    } else {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        [self addCell:cell];
        return [self heightForCell:cell];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.empty || self.failed) {
        if (self.failed) {
//            [self loadDataRefresh];
        }
        [self deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    if (self.listDelegate && [self.listDelegate respondsToSelector:@selector(listView:didSelectRow:)]) {
        [self.listDelegate listView:self didSelectRow:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.empty || self.failed) {
        return;
    }
    if (self.listDelegate && [self.listDelegate respondsToSelector:@selector(listView:didDeselectRow:)]) {
        [self.listDelegate listView:self didDeselectRow:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row + 1 == [self.dataSource tableView:tableView numberOfRowsInSection:0]) {
        if (self.noMore && self.contentSize.height <= self.frame.size.height) {
            if (self.footer) {
                [self removeFooter];
            }
        } else {
            if (!self.footer && !self.failed && !self.empty) {
                [self addFooterWithRefreshingTarget:self refreshingAction:@selector(loadDataMore)];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_failed || _empty) {
        return NO;
    }
    if (self.listDataSource && [self.listDataSource respondsToSelector:@selector(listView:canEditRow:)]) {
        return [self.listDataSource listView:self canEditRow:indexPath.row];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listDataSource && [self.listDataSource respondsToSelector:@selector(listView:commitEditingStyle:forRow:)]) {
        return [self.listDataSource listView:self commitEditingStyle:editingStyle forRow:indexPath.row];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listDataSource && [self.listDataSource respondsToSelector:@selector(listView:shouldHighlightRow:)]) {
        return [self.listDataSource listView:self shouldHighlightRow:indexPath.row];
    }
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.listDelegate respondsToSelector:@selector(listViewDidScroll:)]) {
        [self.listDelegate listViewDidScroll:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.listDelegate respondsToSelector:@selector(listViewDidEndDragging:willDecelerate:)]) {
        [self.listDelegate listViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.listDelegate respondsToSelector:@selector(listViewWillBeginDragging:)]) {
        [self.listDelegate listViewWillBeginDragging:self];
    }
}

# pragma mark - public
- (NSMutableArray *)datas
{
    if (!_datas) {
        self.datas = [NSMutableArray array];
    }
    return _datas;
}

- (void)reloadDataAtRow:(NSInteger)row withRowAnimation:(UITableViewRowAnimation)animation
{
    [self reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:animation];
}

- (void)reloadDataAtRow:(NSInteger)row
{
    [self reloadDataAtRow:row withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadData
{
    if (_dataHasLoaded && !_failed) {
        _empty = _datas.count == 0;
    }
    [super reloadData];
}

- (void)setEmptyText:(NSString *)text image:(UIImage *)image
{
    if (text) {
        self.emptyText = text;
    }
    if (image) {
        self.emptyImage = image;
    }
}

- (void)setFailedText:(NSString *)text image:(UIImage *)image
{
    if (text) {
        self.failedText = text;
    }
    if (image) {
        self.failedImage = image;
    }
}

# pragma mark - cells缓存
- (UITableViewCell *)cellWithIdentifier:(NSString *)identifier
{
    NSMutableSet *cells = self.cells[identifier];
    UITableViewCell *cell = [cells anyObject];
    return cell;
}

- (void)addCell:(UITableViewCell *)cell
{
    if (!cell) return;
    NSMutableSet *cells = self.cells[cell.reuseIdentifier];
    if (!cells) {
        self.cells[cell.reuseIdentifier] = [NSMutableSet setWithObject:cell];
    } else {
        [cells addObject:cell];
    }
}

- (void)removeCell:(UITableViewCell *)cell
{
    NSMutableSet *cells = self.cells[cell.reuseIdentifier];
    [cells removeObject:cell];
}

#pragma mark - common
- (void)setListDataSource:(id<KWListViewDataSource>)listDataSource
{
    _listDataSource = listDataSource;
    self.hasDataSource = YES;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ([self.superview isEqual:newSuperview]) return;
    self.hasSuperView = YES;
}

- (void)setHasDataSource:(BOOL)hasDataSource
{
    _hasDataSource = hasDataSource;
    [self addHeaderFooter];
}

- (void)setHasSuperView:(BOOL)hasSuperView
{
    _hasSuperView = hasSuperView;
    [self addHeaderFooter];
}

- (void)addHeaderFooter
{
    if (!self.hasSuperView || !self.hasDataSource) return;
    [self addHeaderWithRefreshingTarget:self refreshingAction:@selector(loadDataRefresh)];
    
    if ([self.listDataSource respondsToSelector:@selector(listView:imagesForRefreshWithState:)]) {
        [self.header setImages:[self.listDataSource listView:self imagesForRefreshWithState:KWListViewHeaderStateIdle] forState:KWListViewHeaderStateIdle];
        [self.header setImages:[self.listDataSource listView:self imagesForRefreshWithState:KWListViewHeaderStateRefreshing] forState:KWListViewHeaderStateRefreshing];
        [self.header setImages:[self.listDataSource listView:self imagesForRefreshWithState:KWListViewHeaderStateWillRefresh] forState:KWListViewHeaderStatePulling];
    } else {
        NSMutableArray *images1 = [@[] mutableCopy];
        for (NSInteger i = 26; i <= 50; i++) {
            [images1 addObject:[UIImage imageNamed:KWLoadingIndex(i)]];
        }
        NSMutableArray *images2 = [@[] mutableCopy];
        for (NSInteger i = 1; i <= 25; i++) {
            [images2 addObject:[UIImage imageNamed:KWLoadingIndex(i)]];
        }
        for (NSInteger i = 1; i <= 25; i++) {
            [images2 addObject:[UIImage imageNamed:KWLoadingIndex(26 - i)]];
        }
        
        [self.header setImages:images1 forState:KWListViewHeaderStateIdle];
        [self.header setImages:images2 forState:KWListViewHeaderStateRefreshing];
        [self.header setImages:images2 forState:KWListViewHeaderStatePulling];
    }
}

# pragma mark - load action

- (void)loadDataMore
{
    [self loadDataWithType:KWLoadDataTypeMore];
}

- (void)loadData
{
    [self.header beginRefreshing];
}

- (void)loadDataRefresh
{
    [self loadDataWithType:KWLoadDataTypeRefresh];
}

- (void)loadDataWithType:(KWLoadDataType)type
{
    if (type == KWLoadDataTypeRefresh) {
        self.currentPage = 0;
    }
    if (self.requestAction) {
        NSMutableDictionary *args;
        if (!args)
        {
            args = [[NSMutableDictionary alloc] init];
        }
        args[KWListViewParamPageSize] = @(self.pageSize);
        args[KWListViewParamPage] = @(self.currentPage + 1);
        self.requestAction(args, ^(BOOL success , NSArray *result){
            _dataHasLoaded = YES;
            if (type == KWLoadDataTypeRefresh) {
                [self.header endRefreshing];
            } else {
                if (self.footer) {
                    [self.footer endRefreshing];
                }
            }
            if (success) { // 成功
                NSAssert(result != nil, @"KWListView的requestAction中第二个参数不得为nil");
                NSAssert([result isKindOfClass:[NSArray class]], @"KWListView的requestAction中第二个参数必须返回NSArray类型数据");
                self.failed = NO;
                if (type == KWLoadDataTypeRefresh) {
                    if (result.count < 1) {
                        self.datas = [NSMutableArray arrayWithArray:result];
                        self.empty = YES;
                        if (self.footer) {
                            [self removeFooter];
                        }
                        if ([self.listDelegate respondsToSelector:@selector(listViewDidReceiveEmptyData:)]) {
                            [self.listDelegate listViewDidReceiveEmptyData:self];
                        }
                    }else {
                        self.empty = NO;
                        self.datas = [NSMutableArray arrayWithArray:result];
                        if (!self.footer) {
                            [self addFooterWithRefreshingTarget:self refreshingAction:@selector(loadDataMore)];
                        } else {
                            [self.footer resetNoMoreData];
                            self.noMore = NO;
                        }
                        self.currentPage ++;
                        if (self.pageSize != result.count || _withoutLoadingMore) {
                            [self.footer noticeNoMoreData];
                            self.noMore = YES;
                        }
                    }
                } else {
                    if (self.pageSize != result.count) { // 不足了
                        [self.footer noticeNoMoreData];
                        self.noMore = YES;
                    }
                    [self.datas addObjectsFromArray:result];
                    self.currentPage ++;
                }
            } else { // 失败
                if (type == KWLoadDataTypeRefresh) {
                    self.failed = YES;
                    self.empty = NO;
                    if (self.footer) {
                        [self removeFooter];
                    }
                } else {
                    
                }
                if ([self.listDelegate respondsToSelector:@selector(listViewDidFailedReceiveData:)]) {
                    [self.listDelegate listViewDidFailedReceiveData:self];
                }
            }
            [self reloadData];
            _needLoadData = NO;
        });
    }
}

# pragma mark - privite
- (CGFloat)heightForCell:(UITableViewCell *)cell
{
    CGFloat height = 0;
    CGFloat first = 1000;
    for (UIView *subview in cell.contentView.subviews) {
        if (subview.tag == KWUncountTag || subview.isHidden) {
            continue;
        }
        CGFloat bottom = subview.frame.origin.y + subview.frame.size.height;
        if (height < bottom) {
            height = bottom;
        }
        CGFloat y = subview.frame.origin.y;
        if (y < first) {
            first = y;
        }
    }
    if (height == 0) {
        height = -20;
    }
    if (self.bottomMargin == -1) {
        return height + first;
    } else {
        return height + self.bottomMargin;
    }
}

- (UITableViewCell *)emptyCell
{
    if (self.emptyView) {
        self.emptyView.tag = KWEmptyViewTag;
        _emptyCell = [[UITableViewCell alloc] initWithFrame:self.bounds];
        _emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [_emptyCell addSubview:self.emptyView];
        return _emptyCell;
    } else {
        UIView *emptyView = [_emptyCell viewWithTag:KWEmptyViewTag];
        [emptyView removeFromSuperview];
    }
    _emptyCell = [self cellWithImage:self.emptyImage text:self.emptyText cell:_emptyCell];
    _emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return _emptyCell;
}

- (UITableViewCell *)failedCell
{
    NSString *failedText = nil;
    if (!self.failedText) {
        failedText = KWListViewFailedText;
    } else {
        failedText = self.failedText;
    }
    _failedCell = [self cellWithImage:self.failedImage text:failedText cell:_failedCell];
    _failedCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return _failedCell;
}

- (UITableViewCell *)cellWithImage:(UIImage *)image text:(NSString *)text cell:(UITableViewCell *)cell
{
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:text];
    }
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:KWListViewCellImageTag];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.frame.size.height * 0.25, self.frame.size.width - 30, 80)];
        imageView.tag = KWListViewCellImageTag;
        [cell.contentView addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:KWListViewCellTextTag];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(15, imageView.frame.origin.y + imageView.frame.size.height + 10, self.frame.size.width - 30, 20)];
        label.tag = KWListViewCellTextTag;
        label.font = [UIFont systemFontOfSize:12];
        label.numberOfLines = 0;
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
    }
    [imageView setImage:image];
    label.text = text;
    CGFloat height = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : label.font} context:nil].size.height;
    CGRect labelF = label.frame;
    labelF.size.height = height;
    label.frame = labelF;
    return cell;
}

- (void)setWithoutLoadingMore:(BOOL)withoutLoadingMore
{
    _withoutLoadingMore = withoutLoadingMore;
    if (withoutLoadingMore && self.footer) {
        [self removeFooter];
    } else {
        if (!withoutLoadingMore && !self.footer) {
            [self addFooterWithRefreshingTarget:self refreshingAction:@selector(loadDataMore)];
        }
    }
}

- (void)setWithoutRefresh:(BOOL)withoutRefresh
{
    _withoutRefresh = withoutRefresh;
    if (withoutRefresh && self.header) {
        [self removeHeader];
    } else {
        if (!withoutRefresh && !self.header) {
            [self addHeaderFooter];
        }
    }
}

- (void)deselectRow:(NSInteger)row animated:(BOOL)animated
{
    [self deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:animated];
}

- (BOOL)isLoadingData
{
    if (self.header.state == KWListViewHeaderStateRefreshing || self.footer.state == KWListViewFooterStateRefreshing) {
        return YES;
    }
    return NO;
}
@end
