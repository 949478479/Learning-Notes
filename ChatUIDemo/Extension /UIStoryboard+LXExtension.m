//
//  UIStoryboard+LXExtension.m
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "UIStoryboard+LXExtension.h"

@implementation UIStoryboard (LXExtension)

+ (void)lx_showInitialVCWithStoryboardName:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [self storyboardWithName:storyboardName bundle:nil];
    LXKeyWindow().rootViewController = [storyboard instantiateInitialViewController];
}

+ (__kindof UIViewController *)lx_instantiateInitialVCWithStoryboardName:(NSString *)storyboardName
                                                              identifier:(NSString *)identifier
{
    UIStoryboard *storyboard = [self storyboardWithName:storyboardName bundle:nil];

    if (identifier) {
        return [storyboard instantiateViewControllerWithIdentifier:identifier];
    }

    return (UIViewController *)[storyboard instantiateInitialViewController];
}

@end