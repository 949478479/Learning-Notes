//
//  LXGroupModel.h
//  QQFriendListDemo
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

@import Foundation;

@interface LXGroupModel : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *online;

@property (nonatomic, strong) NSArray *friendModels;

@property (nonatomic, assign, getter=isOpen) BOOL open;

+ (instancetype)groupModelWithDictionary:(NSDictionary *)dict;

@end