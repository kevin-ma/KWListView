//
//  KWListViewConfig.h
//  KWListViewDemo
//
//  Created by kevin on 15/5/17.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KWFileName(imageName) [[KWListViewBundleName stringByAppendingPathComponent:imageName] stringByAppendingFormat:@".png"]

#define KWLoadingIndex(index) [[KWListViewLoadingBundleName stringByAppendingPathComponent:@"grayloading"] stringByAppendingFormat:@"%ld@%@x.png",(long)(index),KWListViewDevice_Is_iPhone6Plus ? @"3" : @"2"]

#define KWListViewDevice_Is_iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define msgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define msgTarget(target) (__bridge void *)(target)

#define KWListViewFailedImageName  KWFileName(@"loading_failed")
#define KWListViewEmptyImageName   KWFileName(@"loading_empty")

// 常量
UIKIT_EXTERN const CGFloat KWRefreshHeaderHeight;
UIKIT_EXTERN const CGFloat KWRefreshFooterHeight;
UIKIT_EXTERN const CGFloat KWRefreshFastAnimationDuration;
UIKIT_EXTERN const CGFloat KWRefreshSlowAnimationDuration;

UIKIT_EXTERN NSString *const KWRefreshContentOffset;
UIKIT_EXTERN NSString *const KWRefreshContentSize;
UIKIT_EXTERN NSString *const KWRefreshPanState;
UIKIT_EXTERN NSString *const KWRefreshFooterStateNoMoreDataText;

UIKIT_EXTERN NSString *const KWListViewFailedText;
UIKIT_EXTERN NSString *const KWListViewEmptyText;

UIKIT_EXTERN NSString *const KWListViewBundleName;
UIKIT_EXTERN NSString *const KWListViewLoadingBundleName;

UIKIT_EXTERN NSString *const KWListViewParamPage;
UIKIT_EXTERN NSString *const KWListViewParamPageSize;