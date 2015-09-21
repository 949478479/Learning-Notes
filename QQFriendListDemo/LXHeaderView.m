//
//  LXHeaderView.m
//  QQFriendListDemo
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "LXHeaderView.h"
#import "LXGroupModel.h"

@interface LXHeaderView ()

@property (nonatomic, weak) IBOutlet UILabel  *label;
@property (nonatomic, weak) IBOutlet UIButton *button;

@end

@implementation LXHeaderView

#pragma mark - 初始设置

- (void)awakeFromNib
{
    [super awakeFromNib];

    // 打开"Show View Frames"选项可以发现小三角旋转后左右两边会超出 imageView 范围.
    _button.imageView.clipsToBounds = NO;
    // 不设置居中会导致小三角变形.
    _button.imageView.contentMode = UIViewContentModeCenter;
}

#pragma mark - 配置

- (void)configureWithGroupModel:(LXGroupModel *)groupModel
{
    _groupModel = groupModel;

    [_button setTitle:groupModel.name forState:UIControlStateNormal];

    _button.imageView.transform = CGAffineTransformMakeRotation(groupModel.isOpen ? M_PI_2 : 0);

    _label.text = [NSString stringWithFormat:@"%@/%lu",
                   groupModel.online, (unsigned long)groupModel.friendModels.count];
}

#pragma mark - 按钮点击事件

- (IBAction)buttonDidTapped:(UIButton *)sender
{
    _groupModel.open = !_groupModel.isOpen;

    [UIView animateWithDuration:0.25 animations:^{
        _button.imageView.transform = CGAffineTransformMakeRotation(_groupModel.isOpen ? M_PI_2 : 0);
    }];

    if ([_delegate respondsToSelector:@selector(headerViewDidTapped:)]) {
        [_delegate headerViewDidTapped:self];
    }
}

@end