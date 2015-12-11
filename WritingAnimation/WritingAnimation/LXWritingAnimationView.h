//
//  WritingAnimationView.h
//  WritingAnimation
//
//  Created by 从今以后 on 15/12/11.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface LXWritingAnimationView : UIView

/// 默认为 @c 0 秒
@property (nonatomic) IBInspectable double duration;

/// 默认为 1.0
@property (nonatomic) IBInspectable CGFloat lineWidth;
/// 默认为 @c nil
@property (nonatomic, nullable) IBInspectable UIColor *fillColor;
/// 默认为黑色
@property (nonatomic, nullable) IBInspectable UIColor *strokeColor;

/// 默认为 72.0 号系统字体
@property (nonatomic) UIFont *font;
/// 默认为空字符串
@property (nonatomic, copy) IBInspectable NSString *text;

/// 开始动画
- (IBAction)startAnimation;
/// 移除动画
- (IBAction)endAnimation;

@end

NS_ASSUME_NONNULL_END
