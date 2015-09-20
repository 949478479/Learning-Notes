//
//  LXInputView.m
//  ChatUIDemo
//
//  Created by 从今以后 on 15/9/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXInputView.h"
#import "XXNibBridge.h"

static const NSUInteger kLXMaxCountOfRows = 7;
static const NSTimeInterval kLXAnimationDuration = 0.25;

static const CGFloat kLXLineSpacing = 5;

@interface LXInputView () <XXNibBridge, UITextViewDelegate>

@property (nonatomic, assign) BOOL shouldSend;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, assign) CGFloat maxHeight;

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIButton   *sendButton;
@property (nonatomic, weak) IBOutlet UIButton   *keyboardButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *sendButtonBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *keyboardButtonBottomConstraint;

@end

@implementation LXInputView

#pragma mark - 初始配置

- (void)awakeFromNib
{
    [super awakeFromNib];

    // 修改行间距.
    {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = kLXLineSpacing;
        NSDictionary *attributes = @{ NSFontAttributeName : _textView.font,
                                      NSParagraphStyleAttributeName : paragraphStyle };
        _textView.typingAttributes = attributes;
    }

    // 修改上下间距为行间距.这样进入滚动模式后能精确的换行,上一行的字不会露出来一部分.
    _textView.textContainerInset = UIEdgeInsetsMake(kLXLineSpacing, 0, kLXLineSpacing, 0);

    // 试验发现 contentSize.height = ceil(font.lineHeight + textContainerInset.top + textContainerInset.bottom)
    // textContainerInset.top 和 textContainerInset.bottom 默认均为 8.
    CGFloat height = ceil(_textView.font.lineHeight + 2 * kLXLineSpacing);

    // 修正 textView 的高度约束为 contentSize.height, 这样光标就居中了.另外还需调整俩按钮的位置,使之垂直居中.
    {
        CGFloat delta  = height - _textViewHeightConstraint.constant;

        _textViewHeightConstraint.constant       = height;
        _sendButtonBottomConstraint.constant     += delta / 2;
        _keyboardButtonBottomConstraint.constant += delta / 2;
    }

    // 试验发现每加一行高度增加 round(font.lineHeight + kLXLineSpacing), 个别情况可能会偏差一个点.所以用 ceil 上舍入好了.
    _maxHeight = height + ceil(_textView.font.lineHeight + kLXLineSpacing) * (kLXMaxCountOfRows - 1);
}

#pragma mark - IBAction

- (IBAction)sendButtonDidTapped:(UIButton *)sender
{
    // 先清空输入框恢复输入框单行高度再执行发送消息方法.即先恢复输入框和 tableView 的正常位置再刷新表格.
    // 否则代理会先刷新表格再调整 tableView 高度,两个动画可能会冲突,有时会造成 cell 变形等问题.
    _shouldSend = YES;
    _message = _textView.text;

    // 清空输入框,如果当前有多行则恢复单行高度.
    _textView.text = nil;
    [self textViewDidChange:(UITextView *)_textView];
}

- (IBAction)keyboardButtonDidTapped:(UIButton *)sender
{
    [_textView isFirstResponder] ? [_textView resignFirstResponder] : [_textView becomeFirstResponder];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([_delegate respondsToSelector:@selector(inputViewDidBeginEditing:)]) {
        [_delegate inputViewDidBeginEditing:self];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    _sendButton.enabled = textView.hasText;

    [self updateHeightWithAnimationAndSendMessageIfNeed];

    if ([_delegate respondsToSelector:@selector(inputViewDidChange:)]) {
        [_delegate inputViewDidChange:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([_delegate respondsToSelector:@selector(inputViewDidEndEditing:)]) {
        [_delegate inputViewDidEndEditing:self];
    }
}

#pragma mark - 更新输入框高度

- (void)updateHeightWithAnimationAndSendMessageIfNeed
{
    CGFloat contentSizeHeight = _textView.contentSize.height;
    CGFloat delta = contentSizeHeight - _textViewHeightConstraint.constant;

    // 尚未达到最大高度(达到最大高度后会进入滚动模式,高度不再增大,只可能减小.),且高度发生了变化.
    if (contentSizeHeight <= _maxHeight && ABS(delta))
    {
        _textViewHeightConstraint.constant = contentSizeHeight;
        [UIView animateWithDuration:kLXAnimationDuration animations:^{
            // 如果代理不实现就自己调用 layoutIfNeeded.
            if ([_delegate respondsToSelector:@selector(inputView:changeHeight:)]) {
                [_delegate inputView:self changeHeight:contentSizeHeight];
            } else {
                [self layoutIfNeeded];
            }
        } completion:^(BOOL finished) {
            // 动画结束后再发消息,避免和刷新表格动画冲突.
            [self notifyDelegateSendMessageIfNeed];
        }];
    } else {
        [self notifyDelegateSendMessageIfNeed];
    }
}

#pragma mark - 通知代理发送消息

- (void)notifyDelegateSendMessageIfNeed
{
    if (_shouldSend && [_delegate respondsToSelector:@selector(inputView:sendMessage:)]) {
        _shouldSend = NO;
        [_delegate inputView:self sendMessage:_message];
    }
}

@end

@interface LXTextView : UITextView
@end

@implementation LXTextView : UITextView

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    // 强制滚动至底部.可修复输入框达到最大高度时自动换行无法完全滚动至最底部的问题.
    rect.size.height = self.contentSize.height - rect.origin.y;
    [super scrollRectToVisible:rect animated:animated];
}

@end