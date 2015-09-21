//
//  ViewController.m
//  QQFriendListDemo
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "LXFriendCell.h"
#import "LXGroupModel.h"
#import "LXHeaderView.h"
#import "LXFriendModel.h"
#import "ViewController.h"

static const CGFloat kLXHeaderViewHeight = 44;

static NSString * const kLXCellIdentifier       = @"LXFriendCell";
static NSString * const kLXHeaderViewIdentifier = @"LXHeaderView";

@interface ViewController () <LXHeaderViewDelegate>

@property (nonatomic, strong) NSArray<LXGroupModel *> *groupModels;

@end

@implementation ViewController

#pragma mark - 注册 Nib

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *headerViewNib = [UINib nibWithNibName:NSStringFromClass([LXHeaderView class]) bundle:nil];
    [self.tableView registerNib:headerViewNib forHeaderFooterViewReuseIdentifier:kLXHeaderViewIdentifier];
}

#pragma mark - 懒加载模型文件

- (NSArray<LXGroupModel *> *)groupModels
{
    if (!_groupModels) {
        NSString *fullPath     = [[NSBundle mainBundle] pathForResource:@"friends.plist" ofType:nil];
        NSArray *dictArray     = [NSArray arrayWithContentsOfFile:fullPath];
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:dictArray.count];
        for (NSDictionary *dict in dictArray) {
            [models addObject:[LXGroupModel groupModelWithDictionary:dict]];
        }
        _groupModels = [models copy];
    }
    return _groupModels;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.groupModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LXGroupModel *groupModel = self.groupModels[section];

    return groupModel.isOpen ? groupModel.friendModels.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kLXCellIdentifier
                                                         forIndexPath:indexPath];

    LXGroupModel *groupModel   = self.groupModels[indexPath.section];
    LXFriendModel *friendModel = groupModel.friendModels[indexPath.row];

    [cell configureWithFriendModel:friendModel];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    LXHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kLXHeaderViewIdentifier];

    headerView.delegate = self;

    [headerView configureWithGroupModel:self.groupModels[section]];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kLXHeaderViewHeight;
}

#pragma mark - LXHeaderViewDelegate

- (void)headerViewDidTapped:(LXHeaderView *)headerView
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:headerView.groupModel.section.integerValue]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end

@interface LXTableView : UITableView
@end
@implementation LXTableView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    /* 
     为了让 headerView 更灵敏地响应点击而关闭了 delaysContentTouches, 这将导致即使手指在 headerView
     上快速滑动,作为 headerView 的 UIButton 都会响应.而此方法默认实现为若 view 为 UIControll, 则返回 NO.
     这将导致在 headerView 上滑动时, tableView 会转发消息给 button 而自己无法滑动. */
    return YES;
}

@end