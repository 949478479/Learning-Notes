//
//  UIViewController+LXAdditions.h
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (LXAdditions)

/**
 *  获取控制器的导航栏.
 */
@property (nullable, nonatomic, readonly) __kindof UINavigationBar *lx_navigationBar;

/**
 *  使用和类名同名的 @c xib 文件实例化控制器.
 */
+ (instancetype)lx_instantiateFromNib;

@end

NS_ASSUME_NONNULL_END
