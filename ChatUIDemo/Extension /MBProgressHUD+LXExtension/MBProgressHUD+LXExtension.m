//
//  MBProgressHUD+LXExtension.m
//  LXWeChat
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "MBProgressHUD+LXExtension.h"

@implementation MBProgressHUD (LXExtension)

#pragma mark - 持续显示带蒙版的普通 HUD

+ (MBProgressHUD *)lx_showMessage:(NSString *)message
{
    UIWindow *keyWindow = LXKeyWindow();

    NSAssert(keyWindow, @"keyWindow 为 nil.");

    return [self lx_showMessage:message toView:keyWindow];
}

+ (MBProgressHUD *)lx_showMessage:(NSString *)message toView:(UIView *)view
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];

    hud.labelText = message;

    hud.dimBackground = YES;

    hud.removeFromSuperViewOnHide = YES;

    [view addSubview:hud];

    [hud show:YES];

    return hud;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 短暂显示自定义图标的 HUD

+ (void)lx_show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];

    hud.labelText = text;

    hud.removeFromSuperViewOnHide = YES;

    hud.mode = MBProgressHUDModeCustomView;

    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];

    [view addSubview:hud];

    [hud show:YES];

    [hud hide:YES afterDelay:1];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 短暂显示成功/失败图标的 HUD

+ (void)lx_showSuccess:(NSString *)success
{
    UIWindow *keyWindow = LXKeyWindow();

    NSAssert(keyWindow, @"keyWindow 为 nil.");

    [self lx_showSuccess:success toView:keyWindow];
}

+ (void)lx_showSuccess:(NSString *)success toView:(UIView *)view
{
    [self lx_show:success icon:@"MBProgressHUD.bundle/success.png" view:view];
}

+ (void)lx_showError:(NSString *)error
{
    UIWindow *keyWindow = LXKeyWindow();

    NSAssert(keyWindow, @"keyWindow 为 nil.");

    [self lx_showError:error toView:keyWindow];
}

+ (void)lx_showError:(NSString *)error toView:(UIView *)view
{
    [self lx_show:error icon:@"MBProgressHUD.bundle/error.png" view:view];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 隐藏 HUD

+ (void)lx_hideHUD
{
    UIWindow *keyWindow = LXKeyWindow();

    NSAssert(keyWindow, @"keyWindow 为 nil.");

    [self hideHUDForView:keyWindow animated:YES];
}

+ (void)lx_hideHUDForView:(UIView *)view
{
    [self hideHUDForView:view animated:YES];
}

@end