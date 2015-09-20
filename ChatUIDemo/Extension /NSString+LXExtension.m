//
//  NSString+LXExtension.m
//
//  Created by 从今以后 on 15/9/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "NSString+LXExtension.h"

@implementation NSString (LXExtension)

- (CGRect)lx_boundingRectWithSize:(CGSize)size font:(UIFont *)font
{
    return [self boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{ NSFontAttributeName : font }
                              context:nil];
}

@end