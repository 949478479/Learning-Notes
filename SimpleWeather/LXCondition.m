//
//  LXCondition.m
//  SimpleWeather
//
//  Created by 从今以后 on 15/7/26.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXCondition.h"


@implementation LXCondition

@synthesize date      = _date;
@synthesize windSpeed = _windSpeed;
@synthesize sunset    = _sunset;
@synthesize sunrise   = _sunrise;

#pragma mark - 映射图片名

+ (NSDictionary *)p_imageMap
{
    static NSDictionary *imageMap;
    if (!imageMap) {
        imageMap = @{@"01d" : @"weather-clear",
                     @"02d" : @"weather-few",
                     @"03d" : @"weather-few",
                     @"04d" : @"weather-broken",
                     @"09d" : @"weather-shower",
                     @"10d" : @"weather-rain",
                     @"11d" : @"weather-tstorm",
                     @"13d" : @"weather-snow",
                     @"50d" : @"weather-mist",
                     @"01n" : @"weather-moon",
                     @"02n" : @"weather-few-night",
                     @"03n" : @"weather-few-night",
                     @"04n" : @"weather-broken",
                     @"09n" : @"weather-shower",
                     @"10n" : @"weather-rain-night",
                     @"11n" : @"weather-tstorm",
                     @"13n" : @"weather-snow",
                     @"50n" : @"weather-mist"};
    }
    return imageMap;
}

- (NSString *)imageName
{
    return [LXCondition p_imageMap][self.icon];
}

#pragma mark - 字典转模型

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"date"                 : @"dt",
             @"locationName"         : @"name",
             @"humidity"             : @"main.humidity",
             @"temperature"          : @"main.temp",
             @"tempHigh"             : @"main.temp_max",
             @"tempLow"              : @"main.temp_min",
             @"sunrise"              : @"sys.sunrise",
             @"sunset"               : @"sys.sunset",
             @"conditionDescription" : @"weather[0].description",
             @"condition"            : @"weather[0].main",
             @"icon"                 : @"weather[0].icon",
             @"windBearing"          : @"wind.deg",
             @"windSpeed"            : @"wind.speed"};
}

#pragma mark - 类型转换

- (NSDate *)date
{
    return [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)_date doubleValue]];
}

- (NSDate *)sunrise
{
    return [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)_sunrise doubleValue]];
}

- (NSDate *)sunset
{
    return [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)_sunset doubleValue]];
}

// 由 m/s => 英里/时
//#pragma mark - 风速转换
//
//static const double kMPSToMPH = 2.23694;
//
//- (NSNumber *)windSpeed
//{
//    return @(_windSpeed.doubleValue * kMPSToMPH);
//}
@end