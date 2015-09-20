//
//  LXMessageCell.m
//  ChatUIDemo
//
//  Created by 从今以后 on 15/9/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXMessageCell.h"

@interface LXMessageCell ()

@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UIImageView *bubbleView;
@property (nonatomic, weak) IBOutlet UILabel     *contentLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelLeadingConstraint;

@end

@implementation LXMessageCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    _contentLabel.preferredMaxLayoutWidth =
        LXKeyWindow().lx_width - _labelLeadingConstraint.constant * 2;
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    _contentLabel.text = message;
}

#pragma mark - 点击事件处理

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _bubbleView.highlighted = [_bubbleView pointInside:[touches.anyObject locationInView:_bubbleView]
                                             withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _bubbleView.highlighted = NO;

    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _bubbleView.highlighted = NO;
    
    [super touchesCancelled:touches withEvent:event];
}

@end