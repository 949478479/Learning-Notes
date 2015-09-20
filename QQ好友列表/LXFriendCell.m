//
//  LXFriendCell.m
//  QQ好友列表
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "LXFriendCell.h"
#import "LXFriendModel.h"

@implementation LXFriendCell

- (void)setFriendModel:(LXFriendModel *)friendModel
{
    _friendModel = friendModel;

    self.imageView.image      = [UIImage imageNamed:friendModel.icon];
    self.textLabel.text       = friendModel.name;
    self.detailTextLabel.text = friendModel.intro;
    self.textLabel.textColor  = friendModel.isVip ? [UIColor redColor] : [UIColor blackColor];
}

@end