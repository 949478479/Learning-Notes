//
//  LXHeaderView.h
//  QQFriendListDemo
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

@import UIKit;
@class LXGroupModel, LXHeaderView;

NS_ASSUME_NONNULL_BEGIN

@protocol LXHeaderViewDelegate <NSObject>
@optional
- (void)headerViewDidTapped:(LXHeaderView *)headerView;

@end

@interface LXHeaderView : UITableViewHeaderFooterView

@property (nonatomic, readonly, strong) LXGroupModel *groupModel;

@property (nonatomic, weak) id<LXHeaderViewDelegate> delegate;

- (void)configureWithGroupModel:(LXGroupModel *)groupModel;

@end

NS_ASSUME_NONNULL_END