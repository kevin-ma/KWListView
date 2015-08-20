//
//  UIView+KW.m
//  KWListViewDemo
//
//  Created by kevin on 15/5/17.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "UIView+KW.h"

@implementation UIView (KW)
- (void)setKw_x:(CGFloat)kw_x
{
    CGRect frame = self.frame;
    frame.origin.x = kw_x;
    self.frame = frame;
}

- (CGFloat)kw_x
{
    return self.frame.origin.x;
}

- (void)setKw_y:(CGFloat)kw_y
{
    CGRect frame = self.frame;
    frame.origin.y = kw_y;
    self.frame = frame;
}

- (CGFloat)kw_y
{
    return self.frame.origin.y;
}

- (void)setKw_w:(CGFloat)kw_w
{
    CGRect frame = self.frame;
    frame.size.width = kw_w;
    self.frame = frame;
}

- (CGFloat)kw_w
{
    return self.frame.size.width;
}

- (void)setKw_h:(CGFloat)kw_h
{
    CGRect frame = self.frame;
    frame.size.height = kw_h;
    self.frame = frame;
}

- (CGFloat)kw_h
{
    return self.frame.size.height;
}

- (void)setKw_size:(CGSize)kw_size
{
    CGRect frame = self.frame;
    frame.size = kw_size;
    self.frame = frame;
}

- (CGSize)kw_size
{
    return self.frame.size;
}

- (void)setKw_origin:(CGPoint)kw_origin
{
    CGRect frame = self.frame;
    frame.origin = kw_origin;
    self.frame = frame;
}

- (CGPoint)kw_origin
{
    return self.frame.origin;
}
@end
