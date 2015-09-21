//
//  LXGroupModel.h
//  QQFriendListDemo
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

@import Foundation;

@interface LXGroupModel : NSObject

@property (nonatomic, strong) NSNumber *section;
@property (nonatomic, assign, getter=isOpen) BOOL open;

@property (nonatomic, copy)   NSString *name;
@property (nonatomic, strong) NSNumber *online;

@property (nonatomic, strong) NSArray *friendModels;

+ (instancetype)groupModelWithDictionary:(NSDictionary *)dict;

@end