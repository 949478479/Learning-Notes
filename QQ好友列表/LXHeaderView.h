//
//  LXHeaderView.h
//  QQ好友列表
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

@import UIKit;
@class LXGroupModel, LXHeaderView;

@protocol LXHeaderViewDelegate <NSObject>
@optional
- (void)headerViewDidTapped:(LXHeaderView *)headerView;

@end

@interface LXHeaderView : UITableViewHeaderFooterView

@property (nonatomic, assign) NSInteger section;

@property (nonatomic, strong) LXGroupModel *groupModel;

@property (nonatomic, weak) id<LXHeaderViewDelegate> delegate;

@end