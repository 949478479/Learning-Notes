//
//  LXInputView.h
//  ChatUIDemo
//
//  Created by 从今以后 on 15/9/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXInputView;

NS_ASSUME_NONNULL_BEGIN

@protocol LXInputViewDelegate <NSObject>
@optional

- (void)inputViewDidBeginEditing:(LXInputView *)inputView;
- (void)inputViewDidChange:(LXInputView *)inputView;
- (void)inputViewDidEndEditing:(LXInputView *)inputView;

- (void)inputView:(LXInputView *)inputView didSendMessage:(NSString *)message;

/**
 *  此方法在动画块中调用. @c increment 可能为负数.
 */
- (void)inputView:(LXInputView *)inputView didChangeHeightWithIncrement:(CGFloat)increment;

@end

@interface LXInputView : UIView

@property (nullable, nonatomic, weak) IBOutlet id<LXInputViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END