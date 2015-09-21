//
//  LXFriendCell.h
//  QQFriendListDemo
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

@import UIKit;
@class LXFriendModel;

NS_ASSUME_NONNULL_BEGIN

@interface LXFriendCell : UITableViewCell

@property (nonatomic, readonly, strong) LXFriendModel *friendModel;

- (void)configureWithFriendModel:(LXFriendModel *)friendModel;

@end

NS_ASSUME_NONNULL_END