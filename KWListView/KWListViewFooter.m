//  Copyright (c) 2015年 kevin. All rights reserved.
//
//  文件名称：KWListViewFooter.m
//  项目名称：KWListViewDemo
//  作   者：kevin
//  创建时间：15/5/17

#import "KWListViewFooter.h"
#import "KWListViewConfig.h"
#import "UIScrollView+KW.h"
#import "KWListViewHeader.h"
#import "UIView+KW.h"
#import <objc/message.h>

@interface KWListViewFooter ()

@property (weak, nonatomic) UILabel *stateLabel;

@property (weak, nonatomic) UIButton *loadMoreButton;

@property (weak, nonatomic) UILabel *noMoreLabel;

@property (strong, nonatomic) NSMutableArray *willExecuteBlocks;

@property (nonatomic, weak) UIActivityIndicatorView *activityView;

@end

@implementation KWListViewFooter
- (NSMutableArray *)willExecuteBlocks
{
    if (!_willExecuteBlocks) {
        self.willExecuteBlocks = [NSMutableArray array];
    }
    return _willExecuteBlocks;
}

- (UIButton *)loadMoreButton
{
    if (!_loadMoreButton) {
        UIButton *loadMoreButton = [[UIButton alloc] init];
        loadMoreButton.backgroundColor = [UIColor clearColor];
        [loadMoreButton addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_loadMoreButton = loadMoreButton];
        loadMoreButton.userInteractionEnabled = NO;
    }
    return _loadMoreButton;
}

- (UILabel *)noMoreLabel
{
    if (!_noMoreLabel) {
        UILabel *noMoreLabel = [[UILabel alloc] init];
        noMoreLabel.backgroundColor = [UIColor clearColor];
        noMoreLabel.textAlignment = NSTextAlignmentCenter;
        noMoreLabel.textColor = [UIColor colorWithRed:0x80/255.f green:0x80/255.f blue:0x80/255.f alpha:1.0];
        noMoreLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_noMoreLabel = noMoreLabel];
    }
    return _noMoreLabel;
}

- (UILabel *)stateLabel
{
    if (!_stateLabel) {
        UILabel *stateLabel = [[UILabel alloc] init];
        stateLabel.backgroundColor = [UIColor clearColor];
        stateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_stateLabel = stateLabel];
    }
    return _stateLabel;
}

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.appearencePercentTriggerAutoRefresh = 1.0;
        
        self.automaticallyRefresh = YES;
        self.state = KWListViewFooterStateIdle;
        
        [self setTitle:KWRefreshFooterStateNoMoreDataText forState:KWListViewFooterStateNoMoreData];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 旧的父控件
    [self.superview removeObserver:self forKeyPath:KWRefreshContentSize context:nil];
    [self.superview removeObserver:self forKeyPath:KWRefreshPanState context:nil];
    
    if (newSuperview) {
        [newSuperview addObserver:self forKeyPath:KWRefreshContentSize options:NSKeyValueObservingOptionNew context:nil];
        [newSuperview addObserver:self forKeyPath:KWRefreshPanState options:NSKeyValueObservingOptionNew context:nil];
        
        self.kw_h = KWRefreshFooterHeight;
        _scrollView.kw_insetB += self.kw_h;
        [self adjustFrameWithContentSize];
    } else {
        _scrollView.kw_insetB -= self.kw_h;
    }
}

#pragma mark - 私有方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
    
    if (self.state == KWListViewFooterStateIdle) {
        if ([keyPath isEqualToString:KWRefreshPanState]) {
            if (_scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {// 手松开
                if (_scrollView.kw_insetT + _scrollView.kw_contentSizeH <= _scrollView.kw_h - 10) {  // 不够一个屏幕
                    if (_scrollView.kw_offsetY > - _scrollView.kw_insetT) { // 向上拽
                        [self beginRefreshing];
                    }
                } else {
                    if (_scrollView.kw_offsetY > _scrollView.kw_contentSizeH + _scrollView.kw_insetB - _scrollView.kw_h) {
                        [self beginRefreshing];
                    }
                }
            }
        } else if ([keyPath isEqualToString:KWRefreshContentOffset]) {
            if (self.state != KWListViewFooterStateRefreshing && self.automaticallyRefresh) {
                [self adjustStateWithContentOffset];
            }
        }
    }
    
    if ([keyPath isEqualToString:KWRefreshContentSize]) {
        [self adjustFrameWithContentSize];
    }
}

#pragma mark 根据contentOffset调整state
- (void)adjustStateWithContentOffset
{
    if (self.kw_y == 0) return;
    
    if (_scrollView.kw_insetT + _scrollView.kw_contentSizeH > _scrollView.kw_h) {
        if (_scrollView.kw_offsetY > _scrollView.kw_contentSizeH - _scrollView.kw_h + self.kw_h * self.appearencePercentTriggerAutoRefresh + _scrollView.kw_insetB - self.kw_h) {
            [self beginRefreshing];
        }
    }
}

- (void)adjustFrameWithContentSize
{
    self.kw_y = _scrollView.kw_contentSizeH;
}

- (void)buttonClick
{
    [self beginRefreshing];
}

#pragma mark - 公共方法
- (void)setHidden:(BOOL)hidden
{
    __weak typeof(self) weakSelf = self;
    BOOL lastHidden = weakSelf.isHidden;
    CGFloat h = weakSelf.kw_h;
    [weakSelf.willExecuteBlocks addObject:^{
        if (!lastHidden && hidden) {
            weakSelf.state = KWListViewFooterStateIdle;
            _scrollView.kw_insetB -= h;
        } else if (lastHidden && !hidden) {
            _scrollView.kw_insetB += h;
            
            [weakSelf adjustFrameWithContentSize];
        }
    }];
    [weakSelf setNeedsDisplay];
    
    [super setHidden:hidden];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    for (void (^block)() in self.willExecuteBlocks) {
        block();
    }
    [self.willExecuteBlocks removeAllObjects];
}

- (void)beginRefreshing
{
    self.state = KWListViewFooterStateRefreshing;
}

- (void)endRefreshing
{
    self.state = KWListViewFooterStateIdle;
}

- (BOOL)isRefreshing
{
    return self.state == KWListViewFooterStateRefreshing;
}

- (void)noticeNoMoreData
{
    self.state = KWListViewFooterStateNoMoreData;
}

- (void)resetNoMoreData
{
    self.state = KWListViewFooterStateIdle;
}

- (void)setTitle:(NSString *)title forState:(KWListViewFooterState)state
{
    if (title == nil) return;
    
    // 刷新当前状态的文字
    switch (state) {
        case KWListViewFooterStateIdle:
            [self.loadMoreButton setTitle:title forState:UIControlStateNormal];
            break;
            
        case KWListViewFooterStateRefreshing:
            self.stateLabel.text = title;
            break;
            
        case KWListViewFooterStateNoMoreData:
            self.noMoreLabel.text = title;
            break;
            
        default:
            break;
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    self.stateLabel.textColor = textColor;
    [self.loadMoreButton setTitleColor:textColor forState:UIControlStateNormal];
    self.noMoreLabel.textColor = textColor;
}

- (void)setFont:(UIFont *)font
{
    self.loadMoreButton.titleLabel.font = font;
    self.noMoreLabel.font = font;
    self.stateLabel.font = font;
}


#pragma mark - 懒加载
- (UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityView = activityView];
    }
    return _activityView;
}

#pragma mark - 初始化方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.loadMoreButton.frame = self.bounds;
    self.stateLabel.frame = self.bounds;
    self.noMoreLabel.frame = self.bounds;
    // 指示器
    self.activityView.center = CGPointMake(self.kw_w * 0.5, self.kw_h * 0.5);
}

#pragma mark - 公共方法
- (void)setState:(KWListViewFooterState)state
{
    if (self.state == state) return;
    _state = state;
    switch (state) {
        case KWListViewFooterStateIdle:{
            [self.activityView stopAnimating];
            self.noMoreLabel.hidden = YES;
            self.stateLabel.hidden = YES;
            self.loadMoreButton.hidden = YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.loadMoreButton.hidden = NO;
            });
            break;
        }
        case KWListViewFooterStateRefreshing:{
            [self.activityView startAnimating];
            self.loadMoreButton.hidden = YES;
            self.noMoreLabel.hidden = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.refreshingBlock) {
                    self.refreshingBlock();
                }
                if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
                    msgSend(msgTarget(self.refreshingTarget), self.refreshingAction, self);
                }
            });
            break;
        }
        case KWListViewFooterStateNoMoreData:{
            [self.activityView stopAnimating];
            self.loadMoreButton.hidden = YES;
            self.noMoreLabel.hidden = NO;
            self.stateLabel.hidden = YES;
            break;
        }
            
        default:
            break;
    }
}
@end
