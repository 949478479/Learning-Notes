//
//  LXGroupModel.m
//  QQ好友列表
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