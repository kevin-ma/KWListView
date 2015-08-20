//
//  UIScrollView+KW.m
//  KWListViewDemo
//
//  Created by kevin on 15/5/17.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "UIScrollView+KW.h"
#import "KWListViewFooter.h"
#import "KWListViewHeader.h"
#import <objc/runtime.h>

@implementation UIScrollView (KW)
- (void)setKw_insetT:(CGFloat)kw_insetT
{
    UIEdgeInsets inset = self.contentInset;
    inset.top = kw_insetT;
    self.contentInset = inset;
}

- (CGFloat)kw_insetT
{
    return self.contentInset.top;
}

- (void)setKw_insetB:(CGFloat)kw_insetB
{
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = kw_insetB;
    self.contentInset = inset;
}

- (CGFloat)kw_insetB
{
    return self.contentInset.bottom;
}

- (void)setKw_insetL:(CGFloat)kw_insetL
{
    UIEdgeInsets inset = self.contentInset;
    inset.left = kw_insetL;
    self.contentInset = inset;
}

- (CGFloat)kw_insetL
{
    return self.contentInset.left;
}

- (void)setKw_insetR:(CGFloat)kw_insetR
{
    UIEdgeInsets inset = self.contentInset;
    inset.right = kw_insetR;
    self.contentInset = inset;
}

- (CGFloat)kw_insetR
{
    return self.contentInset.right;
}

- (void)setKw_offsetX:(CGFloat)kw_offsetX
{
    CGPoint offset = self.contentOffset;
    offset.x = kw_offsetX;
    self.contentOffset = offset;
}

- (CGFloat)kw_offsetX
{
    return self.contentOffset.x;
}

- (void)setKw_offsetY:(CGFloat)kw_offsetY
{
    CGPoint offset = self.contentOffset;
    offset.y = kw_offsetY;
    self.contentOffset = offset;
}

- (CGFloat)kw_offsetY
{
    return self.contentOffset.y;
}

- (void)setKw_contentSizeW:(CGFloat)kw_contentSizeW
{
    CGSize size = self.contentSize;
    size.width = kw_contentSizeW;
    self.contentSize = size;
}

- (CGFloat)kw_contentSizeW
{
    return self.contentSize.width;
}

- (void)setKw_contentSizeH:(CGFloat)kw_contentSizeH
{
    CGSize size = self.contentSize;
    size.height = kw_contentSizeH;
    self.contentSize = size;
}

- (CGFloat)kw_contentSizeH
{
    return self.contentSize.height;
}

@end

@implementation UIScrollView (list)

- (KWListViewHeader *)addHeaderWithRefreshingBlock:(void (^)())block
{
    KWListViewHeader *header = [self addHeader];
    header.refreshingBlock = block;
    return header;
}

- (KWListViewHeader *)addHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    KWListViewHeader *header = [self addHeader];
    header.refreshingTarget = target;
    header.refreshingAction = action;
    return header;
}

- (KWListViewHeader *)addHeader
{
    KWListViewHeader *header = [[KWListViewHeader alloc] init];
    self.header = header;
    return header;
}

- (void)removeHeader
{
    self.header = nil;
}

#pragma mark - Property Methods

#pragma mark header
static char KWListViewHeaderKey;
- (void)setHeader:(KWListViewHeader *)header
{
    if (header != self.header) {
        [self.header removeFromSuperview];
        
        [self willChangeValueForKey:@"header"];
        objc_setAssociatedObject(self, &KWListViewHeaderKey,
                                 header,
                                 OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"header"];
        
        [self addSubview:header];
    }
}

- (KWListViewHeader *)header
{
    return objc_getAssociatedObject(self, &KWListViewHeaderKey);
}

#pragma mark - 上拉刷新
- (KWListViewFooter *)addFooterWithRefreshingBlock:(void (^)())block
{
    KWListViewFooter *footer = [self addFooter];
    footer.refreshingBlock = block;
    return footer;
}

- (KWListViewFooter *)addFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    KWListViewFooter *footer = [self addFooter];
    footer.refreshingTarget = target;
    footer.refreshingAction = action;
    return footer;
}

- (KWListViewFooter *)addFooter
{
    KWListViewFooter *footer = [[KWListViewFooter alloc] init];
    self.footer = footer;
    return footer;
}

- (void)removeFooter
{
    self.footer = nil;
}

static char KWListViewFooterKey;
- (void)setFooter:(KWListViewFooter *)footer
{
    if (footer != self.footer) {
        [self.footer removeFromSuperview];
        
        [self willChangeValueForKey:@"footer"];
        objc_setAssociatedObject(self, &KWListViewFooterKey,
                                 footer,
                                 OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"footer"];
        
        [self addSubview:footer];
    }
}

- (KWListViewFooter *)footer
{
    return objc_getAssociatedObject(self, &KWListViewFooterKey);
}
//
#pragma mark - swizzle
+ (void)load
{
    Method method1 = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
    Method method2 = class_getInstanceMethod([self class], @selector(deallocSwizzle));
    method_exchangeImplementations(method1, method2);
}

- (void)deallocSwizzle
{
    [self removeFooter];
    [self removeHeader];
    
    [self deallocSwizzle];
}


@end
