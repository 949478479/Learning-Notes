//
//  LXCondition.m
//  SimpleWeather
//
//  Created by 从今以后 on 15/7/26.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXCondition.h"


static const float kLXMPSToMPH = 2.23694;


@implementation LXCondition

#pragma mark - 映射图片名

+ (NSDictionary *)p_imageMap
{
    static NSDictionary *_imageMap;
    if (!_imageMap) {
        _imageMap = @{
                      @"01d" : @"weather-clear",
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
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}

- (NSString *)imageName
{
    return [LXCondition p_imageMap][_icon];
}

#pragma mark - 字典转模型

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"date"                 : @"dt",
             @"locationName"         : @"name",
             @"humidity"             : @"main.humidity",
             @"temperature"          : @"main.temp",
             @"tempHigh"             : @"main.temp_max",
             @"tempLow"              : @"main.temp_min",
             @"sunrise"              : @"sys.sunrise",
             @"sunset"               : @"sys.sunset",
             @"conditionDescription" : @"weather.description",
             @"condition"            : @"weather.main",
             @"icon"                 : @"weather.icon",
             @"windBearing"          : @"wind.deg",
             @"windSpeed"            : @"wind.speed"
             };
}

#pragma mark - 日期转换

+ (NSValueTransformer *)dateJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:[value floatValue]];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [NSString stringWithFormat:@"%f",[value timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)sunriseJSONTransformer
{
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer
{
    return [self dateJSONTransformer];
}

#pragma mark - 环境转换

+ (NSValueTransformer *)conditionDescriptionJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [value firstObject];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return @[value];
    }];
}

+ (NSValueTransformer *)conditionJSONTransformer
{
    return [self conditionDescriptionJSONTransformer];
}

+ (NSValueTransformer *)iconJSONTransformer
{
    return [self conditionDescriptionJSONTransformer];
}


#pragma mark - 风速转换

+ (NSValueTransformer *)windSpeedJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return @([value floatValue] * kLXMPSToMPH);
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return @([value floatValue] / kLXMPSToMPH);
    }];
}

@end