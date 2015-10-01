//
//  PlayViewController.h
//  KWListViewDemo
//
//  Created by 凯文马 on 15/10/1.
//  Copyright © 2015年 凯文马. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PlayType) {
    PlayTypeFail,
    PlayTypeEmpty,
    PlayTypeNormal,
};

@interface PlayViewController : UIViewController
@property (nonatomic, assign) PlayType type;

- (instancetype)initWithType:(PlayType)type;

@end
