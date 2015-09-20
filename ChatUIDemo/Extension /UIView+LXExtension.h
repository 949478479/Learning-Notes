//
//  UIView+LXExtension.h
//
//  Created by 从今以后 on 15/9/11.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LXExtension)

@property (nonatomic, assign) CGSize  lx_size;
@property (nonatomic, assign) CGFloat lx_width;
@property (nonatomic, assign) CGFloat lx_height;

@property (nonatomic, assign) CGPoint lx_origin;
@property (nonatomic, assign) CGFloat lx_originX;
@property (nonatomic, assign) CGFloat lx_originY;

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nullable, nonatomic, strong) IBInspectable UIColor *borderColor;

/**
 *  执行晃动动画.
 */
- (void)lx_shakeAnimation;

@end

NS_ASSUME_NONNULL_END