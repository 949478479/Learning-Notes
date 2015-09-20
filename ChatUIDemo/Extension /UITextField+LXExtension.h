//
//  UITextField+LXExtension.h
//
//  Created by 从今以后 on 15/9/11.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (LXExtension)

/**
 *  设置文本区域.即 -[UITextField textRectForBounds:] 方法的返回值.若不指定或指定为0,则沿用默认值.
 */
@property (nonatomic, assign) IBInspectable CGRect textRect;

/**
 *  设置编辑区域.即 -[UITextField editingRectForBounds:] 方法的返回值.若不指定或指定为0,则沿用默认值.
 */
@property (nonatomic, assign) IBInspectable CGRect editingRect;

/**
 *  为 UITextField 添加左图标. UIImageView 为边长为 UITextField 高度的正方形,图片显示模式为居中.
 */
@property (nullable, nonatomic, strong) IBInspectable UIImage *leftImage;

@end

NS_ASSUME_NONNULL_END