//
//  PlaySuccessModel.h
//  KWListViewDemo
//
//  Created by 凯文马 on 15/10/1.
//  Copyright © 2015年 凯文马. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaySuccessModel : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger time;

+ (instancetype)modelWithDict:(NSDictionary *)dict;
+ (NSArray *)modelsWithDicts:(NSArray *)dicts;
@end
