//
//  LXFriendModel.h
//  QQFriendListDemo
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface LXFriendModel : NSObject

@property (nonatomic, readonly, copy) NSString *icon;

@property (nonatomic, readonly, copy) NSString *name;

@property (nonatomic, readonly, copy) NSString *intro;

@property (nonatomic, readonly, assign, getter=isVip) BOOL vip;

- (instancetype)initWithDictionary:(NSDictionary *)dict NS_DESIGNATED_INITIALIZER;

+ (instancetype)friendModelWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END