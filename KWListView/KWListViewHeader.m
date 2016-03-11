//  Copyright (c) 2015年 kevin. All rights reserved.
//
//  文件名称：KWListViewHeader.m
//  项目名称：KWListViewDemo
//  作   者：kevin
//  创建时间：15/5/17
//  文件说明：kevin

#import "KWListViewHeader.h"
#import "KWListViewConfig.h"
#import "UIView+KW.h"
#import <objc/message.h>
#import "UITableView+KW.h"

@interface KWListViewHeader ()

/** 显示上次刷新时间的标签 */
@property (weak, nonatomic) UILabel *updatedTimeLabel;

/** 上次刷新时间 */
@property (strong, nonatomic) NSDate *updatedTime;

/** 显示状态文字的标签 */
@property (weak, nonatomic) UILabel *stateLabel;

/** 所有状态对应的文字 */
@property (strong, nonatomic) NSMutableDictionary *stateTitles;


/** 所有状态对应的动画图片 */
@property (strong, nonatomic) NSMutableDictionary *stateImages;

/** 播放动画图片的控件 */
@property (weak, nonatomic) UIImageView *gifView;
@end

@implementation KWListViewHeader

#pragma mark - 懒加载
- (NSMutableDictionary *)stateTitles
{
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
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

- (UILabel *)updatedTimeLabel
{
    if (!_updatedTimeLabel) {
        UILabel *updatedTimeLabel = [[UILabel alloc] init];
        updatedTimeLabel.backgroundColor = [UIColor clearColor];
        updatedTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_updatedTimeLabel = updatedTimeLabel];
    }
    return _updatedTimeLabel;
}

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 设置为默认状态
        self.state = KWListViewHeaderStateIdle;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        self.kw_h = KWRefreshHeaderHeight;
    }
}

- (void)drawRect:(CGRect)rect
{
    if (self.state == KWListViewHeaderStateWillRefresh) {
        self.state = KWListViewHeaderStateRefreshing;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.kw_y = - self.kw_h;
    
    CGRect rect = self.bounds;
    UIImage *image = [self.stateImages[@(KWListViewHeaderStateIdle)] lastObject];
    if (!image) {
        self.gifView.frame = rect;
        return;
    }
    CGSize imageSize = image.size;
    NSInteger power = [UIScreen mainScreen].bounds.size.width > 750 ? 3 : 2;
    imageSize = CGSizeMake(imageSize.width * power, imageSize.height * power);
    rect = CGRectMake(rect.size.width * 0.5 - (imageSize.width * 0.5) * 0.5, 20, imageSize.width * 0.5, imageSize.height * 0.5);
    self.gifView.frame = rect;
}

#pragma mark - 私有方法

#pragma mark KVO属性监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden || self.state == KWListViewHeaderStateRefreshing) return;
    
    // 根据contentOffset调整state
    if ([keyPath isEqualToString:KWRefreshContentOffset]) {
        [self adjustStateWithContentOffset];
    }
}

#pragma mark 根据contentOffset调整state
- (void)adjustStateWithContentOffset
{
    if (self.state != KWListViewHeaderStateRefreshing) {
        // 在刷新过程中，跳转到下一个控制器时，contentInset可能会变
        _tableViewOriginalInset = _tableView.contentInset;
    }
    
    // 在刷新的 refreshing 状态，动态设置 content inset
    if (self.state == KWListViewHeaderStateRefreshing ) {
        if(_tableView.contentOffset.y >= -_tableViewOriginalInset.top ) {
            _tableView.kw_insetT = _tableViewOriginalInset.top;
        } else {
            _tableView.kw_insetT = MIN(_tableViewOriginalInset.top + self.kw_h,
                                        _tableViewOriginalInset.top - _tableView.contentOffset.y);
        }
        return;
    }
    
    CGFloat offsetY = _tableView.kw_offsetY;
    CGFloat happenOffsetY = - _tableViewOriginalInset.top;

    if (offsetY >= happenOffsetY) return;
    CGFloat normal2pullingOffsetY = happenOffsetY - self.kw_h;
    if (_tableView.isDragging) {
        self.pullingPercent = (happenOffsetY - offsetY) / self.kw_h;
        
        if (self.state == KWListViewHeaderStateIdle && offsetY < normal2pullingOffsetY) {
            self.state = KWListViewHeaderStatePulling;
        } else if (self.state == KWListViewHeaderStatePulling && offsetY >= normal2pullingOffsetY) {
            self.state = KWListViewHeaderStateIdle;
        }
    } else if (self.state == KWListViewHeaderStatePulling) {
        self.pullingPercent = 1.0;
        self.state = KWListViewHeaderStateRefreshing;
    } else {
        self.pullingPercent = (happenOffsetY - offsetY) / self.kw_h;
    }
}

#pragma mark - 公共方法
- (void)setTitle:(NSString *)title forState:(KWListViewHeaderState)state
{
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
    self.stateLabel.text = self.stateTitles[@(self.state)];
}

- (void)beginRefreshing
{
    if (self.window) {
        self.state = KWListViewHeaderStateRefreshing;
    } else {
        self.state = KWListViewHeaderStateWillRefresh;
        [self setNeedsDisplay];
    }
}

- (void)endRefreshing
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.state = KWListViewHeaderStateIdle;
    });
}

- (BOOL)isRefreshing
{
    return self.state == KWListViewHeaderStateRefreshing;
}

#pragma mark - 懒加载
- (NSMutableDictionary *)stateImages
{
    if (!_stateImages) {
        self.stateImages = [NSMutableDictionary dictionary];
    }
    return _stateImages;
}

- (UIImageView *)gifView
{
    if (!_gifView) {
        UIImageView *gifView = [[UIImageView alloc] init];
        [self addSubview:_gifView = gifView];
    }
    return _gifView;
}

#pragma mark - 公共方法
#pragma mark 设置状态
- (void)setState:(KWListViewHeaderState)state
{
    if (self.state == state) return;
    
    // 旧状态
    KWListViewHeaderState oldState = self.state;
    
    NSArray *images = self.stateImages[@(state)];
    if (images.count != 0) {
        switch (state) {
            case KWListViewHeaderStateIdle: {
                if (oldState == KWListViewHeaderStateRefreshing) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(KWRefreshSlowAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.pullingPercent = 0.0;
                    });
                } else {
                    self.pullingPercent = self.pullingPercent;
                }

                break;
            }
                
            case KWListViewHeaderStatePulling:
            case KWListViewHeaderStateRefreshing: {
                [self.gifView stopAnimating];
                if (images.count == 1) { // 单张图片
                    self.gifView.image = [images lastObject];
                } else { // 多张图片
                    self.gifView.animationImages = images;
                    self.gifView.animationDuration = 0.6f;
                    [self.gifView startAnimating];
                }
                break;
            }
                
            default:
                break;
        }
    }
    _state = state;
    switch (state) {
        case KWListViewHeaderStateIdle: {
            if (oldState == KWListViewHeaderStateRefreshing) {

                self.updatedTime = [NSDate date];
                

                [UIView animateWithDuration:KWRefreshSlowAnimationDuration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{

                    _tableView.kw_insetT -= self.kw_h;
                } completion:nil];
            }
            break;
        }
            
        case KWListViewHeaderStateRefreshing: {
            [UIView animateWithDuration:KWRefreshFastAnimationDuration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{

                CGFloat top = _tableViewOriginalInset.top + self.kw_h;
                _tableView.kw_insetT = top;
                
                _tableView.kw_offsetY = - top;
            } completion:^(BOOL finished) {
                if (self.refreshingBlock) {
                    self.refreshingBlock();
                }
                
                if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
                    msgSend(msgTarget(self.refreshingTarget), self.refreshingAction, self);
                }
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)setPullingPercent:(CGFloat)pullingPercent
{
    _pullingPercent = pullingPercent;
    NSArray *images = self.stateImages[@(self.state)];
    switch (self.state) {
        case KWListViewHeaderStateIdle: {
            [self.gifView stopAnimating];
            NSUInteger index =  images.count * self.pullingPercent;
            if (index >= images.count) index = images.count - 1;
            self.gifView.image = images[index];
            break;
        }
        default:
            break;
    }
}

- (void)setImages:(NSArray *)images forState:(KWListViewHeaderState)state
{
    if (images == nil) return;
    
    self.stateImages[@(state)] = images;
    
    UIImage *image = [images firstObject];
    if (image.size.height > self.kw_h) {
        self.kw_h = image.size.height;
    }
    [self layoutIfNeeded];
}
@end
