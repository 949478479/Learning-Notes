//
//  LXDailyForecast.m
//  SimpleWeather
//
//  Created by 从今以后 on 15/7/26.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXDailyForecast.h"

@implementation LXDailyForecast

+ (NSDictionary *)replacedKeyFromPropertyName
{
    NSMutableDictionary *paths = [[super replacedKeyFromPropertyName] mutableCopy];

    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"]  = @"temp.min";

    return paths;
}

@end