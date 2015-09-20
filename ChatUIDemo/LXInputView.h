//
//  LXInputView.h
//  ChatUIDemo
//
//  Created by 从今以后 on 15/9/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXInputView, LXTextView;

@protocol LXInputViewDelegate <NSObject>
@optional
- (void)inputViewDidBeginEditing:(LXInputView *)inputView;
- (void)inputViewDidChange:(LXInputView *)inputView;
- (void)inputViewDidEndEditing:(LXInputView *)inputView;

/**
 *  在该方法中根据需要调整约束,调用 layoutIfNeeded 方法.若不实现此代理, inputView 只会调整自己的高度.
 *
 *  此方法在动画块中调用.
 *
 *  @param inputView 输入框.
 *  @param height    输入框的新高度.
 */
- (void)inputView:(LXInputView *)inputView changeHeight:(CGFloat )height;

- (void)inputView:(LXInputView *)inputView sendMessage:(NSString *)message;

@end

@interface LXInputView : UIView

@property (nonatomic, weak) IBOutlet id<LXInputViewDelegate> delegate;

@end