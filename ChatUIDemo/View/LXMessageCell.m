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
@property (nonatomic, weak) IBOutlet UIButton *messageButton;

@end

@implementation LXMessageCell

- (void)setMessage:(NSString *)message
{
    _message = message;

    _messageButton.lx_normalTitle = message;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

static const CGFloat kMessageButtonPadding = 78;
static const CGFloat kMessageButtonTitleInset = 18;

@interface LXMessageButton : UIButton
@property (nonatomic, assign) CGFloat sizeIncrement;
@property (nonatomic, assign) CGFloat titleLabelMaxWidth;
@end

@implementation LXMessageButton

- (void)awakeFromNib
{
    [super awakeFromNib];

    _sizeIncrement = 2 * kMessageButtonTitleInset;
    _titleLabelMaxWidth = LXScreenSize().width - 2 * (kMessageButtonPadding + kMessageButtonTitleInset);

    self.titleLabel.numberOfLines = 0;
    self.titleEdgeInsets = UIEdgeInsetsMake(kMessageButtonTitleInset,
                                            kMessageButtonTitleInset,
                                            kMessageButtonTitleInset,
                                            kMessageButtonTitleInset);
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [self.titleLabel.text lx_sizeWithBoundingSize:(CGSize){_titleLabelMaxWidth, CGFLOAT_MAX}
                                                           font:self.titleLabel.font];
    size.width  += _sizeIncrement;
    size.height += _sizeIncrement;

    return size;
}

@end
