//
//  UIView+LXAdditions.m
//
//  Created by 从今以后 on 15/9/11.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "UIView+LXAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIView (LXAdditions)

#pragma mark - size

- (void)setLx_size:(CGSize)lx_size
{
    CGRect frame = self.frame;
    frame.size   = lx_size;
    self.frame   = frame;
}

- (CGSize)lx_size
{
    return self.frame.size;
}

- (void)setLx_width:(CGFloat)lx_width
{
    CGRect frame     = self.frame;
    frame.size.width = lx_width;
    self.frame       = frame;
}

- (CGFloat)lx_width
{
    return CGRectGetWidth(self.frame);
}

- (void)setLx_height:(CGFloat)lx_height
{
    CGRect frame      = self.frame;
    frame.size.height = lx_height;
    self.frame        = frame;
}

- (CGFloat)lx_height
{
    return CGRectGetHeight(self.frame);
}

#pragma mark - origin

- (void)setLx_origin:(CGPoint)lx_origin
{
    CGRect frame = self.frame;
    frame.origin = lx_origin;
    self.frame   = frame;
}

- (CGPoint)lx_origin
{
    return self.frame.origin;
}

- (void)setLx_originX:(CGFloat)lx_originX
{
    CGRect frame   = self.frame;
    frame.origin.x = lx_originX;
    self.frame     = frame;
}

- (CGFloat)lx_originX
{
    return CGRectGetMinX(self.frame);
}

- (void)setLx_originY:(CGFloat)lx_originY
{
    CGRect frame   = self.frame;
    frame.origin.y = lx_originY;
    self.frame     = frame;
}

- (CGFloat)lx_originY
{
    return CGRectGetMinY(self.frame);
}

#pragma mark - center

- (void)setLx_centerX:(CGFloat)lx_centerX
{
    self.center = CGPointMake(lx_centerX, self.center.y);
}

- (CGFloat)lx_centerX
{
    return self.center.x;
}

- (void)setLx_centerY:(CGFloat)lx_centerY
{
    self.center = CGPointMake(self.center.x, lx_centerY);
}

- (CGFloat)lx_centerY
{
    return self.center.y;
}

#pragma mark - 图层圆角|边框宽度|边框颜色

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

- (void)setBorderColor:(nullable UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (nullable UIColor *)borderColor
{
    CGColorRef color = self.layer.borderColor;
    return color ? [UIColor colorWithCGColor:color] : nil;
}

#pragma mark - UINib 相关方法

+ (UINib *)lx_nib
{
    return [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
}

+ (NSString *)lx_nibName
{
    return NSStringFromClass(self);
}

+ (instancetype)lx_instantiateFromNib
{
    return [self lx_instantiateFromNibWithOwner:nil options:nil];
}

+ (instancetype)lx_instantiateFromNibWithOwner:(nullable id)ownerOrNil
                                       options:(nullable NSDictionary *)optionsOrNil
{
    NSArray *views = [[self lx_nib] instantiateWithOwner:ownerOrNil options:optionsOrNil];
    for (UIView *view in views) {
        if ([view isMemberOfClass:self]) {
            return view;
        }
    }
    NSAssert(NO, @"%@.xib 中未找到对应的 %@", NSStringFromClass(self), NSStringFromClass(self));
    return nil;
}

#pragma mark - 获取所属的控制器

- (nullable __kindof UIViewController *)lx_viewController
{
    UIResponder *nextResponder = self.nextResponder;

    while (nextResponder && ![nextResponder isKindOfClass:UIViewController.class]) {
        nextResponder = nextResponder.nextResponder;
    }

    return (UIViewController *)nextResponder;
}

- (nullable __kindof UINavigationController *)lx_navigationController
{
    UIResponder *nextResponder = self.nextResponder;

    while (nextResponder && ![nextResponder isKindOfClass:UINavigationController.class]) {
        nextResponder = nextResponder.nextResponder;
    }

    return (UINavigationController *)nextResponder;
}

- (nullable __kindof UITabBarController *)lx_tabBarController
{
    UIResponder *nextResponder = self.nextResponder;

    while (nextResponder && ![nextResponder isKindOfClass:UITabBarController.class]) {
        nextResponder = nextResponder.nextResponder;
    }

    return (UITabBarController *)nextResponder;
}

#pragma mark - 执行晃动动画

- (void)lx_performShakeAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];

    animation.keyPath  = @"position.x";
    animation.values   = @[ @0, @10, @-10, @10, @0 ];
    animation.keyTimes = @[ @0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1 ];
    animation.duration = 0.4;
    animation.additive = YES;

    [self.layer addAnimation:animation forKey:@"shake"];
}

@end

NS_ASSUME_NONNULL_END
