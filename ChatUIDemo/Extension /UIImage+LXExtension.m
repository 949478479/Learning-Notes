//
//  UIImage+LXExtension.m
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "UIImage+LXExtension.h"

@implementation UIImage (LXExtension)

- (UIImage *)lx_resizedImageWithTargetSize:(CGSize)targetSize
{
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, self.scale);

    [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];

    UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return targetImage;
}

@end