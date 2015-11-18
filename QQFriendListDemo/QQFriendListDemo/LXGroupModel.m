//
//  LXGroupModel.m
//  QQFriendListDemo
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "LXGroupModel.h"
#import "LXFriendModel.h"

@implementation LXGroupModel

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:_friendModels.count];
        for (NSDictionary *dict in _friendModels) {
           [models addObject:[LXFriendModel friendModelWithDictionary:dict]];
        }
        _friendModels = [models copy];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"必须使用指定构造器 -initWithDictionary: 初始化.");
    return [self initWithDictionary:@{}];
}

+ (instancetype)groupModelWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"friends"]) {
        _friendModels = value;
    } else {
        [super setValue:value forUndefinedKey:key];
    }
}

@end