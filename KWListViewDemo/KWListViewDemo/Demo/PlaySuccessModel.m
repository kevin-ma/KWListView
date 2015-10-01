//
//  PlaySuccessModel.m
//  KWListViewDemo
//
//  Created by 凯文马 on 15/10/1.
//  Copyright © 2015年 凯文马. All rights reserved.
//

#import "PlaySuccessModel.h"

@implementation PlaySuccessModel

+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    PlaySuccessModel *model = [[self alloc] init];
    model.userName = dict[@"username"];
    model.content = dict[@"content"];
    model.time = [dict[@"time"] integerValue];
    return model;
}

+ (NSArray *)modelsWithDicts:(NSArray *)dicts
{
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSDictionary *dict in dicts) {
        [temp addObject:[self modelWithDict:dict]];
    }
    return [temp copy];
}

@end
