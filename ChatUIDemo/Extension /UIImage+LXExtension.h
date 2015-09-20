//
//  UIImage+LXExtension.h
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (LXExtension)

/**
 *  缩放图片到目标尺寸.
 *
 *  @param targetSize 目标尺寸.
 *
 *  @return 缩放后的图片.
 */
- (UIImage *)lx_resizedImageWithTargetSize:(CGSize)targetSize;

@end

NS_ASSUME_NONNULL_END