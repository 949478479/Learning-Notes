//
//  AppDelegate.m
//  QQ好友列表
//
//  Created by Apple on 15/1/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    UIUserNotificationType type = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 233;

    return YES;
}

@end