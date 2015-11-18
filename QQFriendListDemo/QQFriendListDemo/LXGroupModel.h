//
//  LXGroupModel.h
//  QQFriendListDemo
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

@import Foundation;
@class LXFriendModel;

NS_ASSUME_NONNULL_BEGIN

@interface LXGroupModel : NSObject

@property (nonatomic, assign, getter=isOpen) BOOL open;
@property (nonatomic, readonly, strong) NSNumber *section;

@property (nonatomic, readonly, copy)   NSString *name;
@property (nonatomic, readonly, strong) NSNumber *online;

@property (nonatomic, readonly, strong) NSArray<LXFriendModel *> *friendModels;

- (instancetype)initWithDictionary:(NSDictionary *)dict NS_DESIGNATED_INITIALIZER;

+ (instancetype)groupModelWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END