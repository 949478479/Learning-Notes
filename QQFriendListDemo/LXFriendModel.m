//
//  LXFriendModel.m
//  QQFriendListDemo
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "LXFriendModel.h"

@implementation LXFriendModel

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"必须使用指定构造器 -initWithDictionary: 初始化.");
    return [self initWithDictionary:@{}];
}

+ (instancetype)friendModelWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

@end