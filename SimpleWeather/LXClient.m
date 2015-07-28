//
//  LXClient.m
//  SimpleWeather
//
//  Created by 从今以后 on 15/7/26.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXClient.h"
#import "LXCondition.h"
#import "LXDailyForecast.h"
#import <ReactiveCocoa.h>

static NSString *const kConditionsWeatherAPI =
    @"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric&lang=zh_cn";
static NSString *const kHourlyForecastAPI    =
    @"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=metric&cnt=12";
static NSString *const kDailyForecastAPI     =
    @"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=metric&cnt=7";

@interface LXClient ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation LXClient

#pragma mark - 初始化

- (instancetype)init
{
    self = [super init];
    if (self) {
        _session = [NSURLSession sharedSession];
    }
    return self;
}

#pragma mark - 从网络请求 JSON 数据

- (RACSignal *)fetchJSONFromURL:(NSURL *)url
{
    // 创建然后返回信号.直到这个信号被订阅才会执行网络请求.
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url
                                                     completionHandler:
                                          ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSError *jsonError;
                id json = [NSJSONSerialization JSONObjectWithData:data
                                                          options:(NSJSONReadingOptions)kNilOptions
                                                            error:&jsonError];
                jsonError ? [subscriber sendError:error] : [subscriber sendNext:json]; // 发给订阅者.
            } else {
                [subscriber sendError:error]; // 通知订阅者出错了.
            }

            [subscriber sendCompleted]; // 无论该请求成功与否,通知订阅者请求已经完成.
        }];
        [dataTask resume];
        
        // 处理当信号摧毁时的清理工作.
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) { // 错误处理.该方法不订阅信号,仅仅是返回信号,因此可连接到方法尾部.
        NSLog(@"%@", error.localizedDescription);
    }];
}

#pragma mark - 获取对应位置的环境信息

- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kConditionsWeatherAPI,
                                       coordinate.latitude, coordinate.longitude]];

    return [[self fetchJSONFromURL:url] map:^id(id json) {
        return [LXCondition objectWithKeyValues:json];
    }];
}

#pragma mark - 获取逐时预报

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kHourlyForecastAPI,
                                       coordinate.latitude, coordinate.longitude]];

    return [[self fetchJSONFromURL:url] map:^id(id json) {
        RACSequence *list = [json[@"list"] rac_sequence]; // 获取返回 JSON 中的 "list" 数组,生成 rac 序列.
        return [[list map:^id(id item) { // 将数组内容继续映射,最终组成 LXCondition 对象数组返回出去.
            return [LXCondition objectWithKeyValues:item];
        }] array];
    }];
}

#pragma mark - 获取每日预报

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kDailyForecastAPI,
                                       coordinate.latitude, coordinate.longitude]];

    return [[self fetchJSONFromURL:url] map:^id(id json) {
        RACSequence *list = [json[@"list"] rac_sequence];
        return [[list map:^id(id item) {
            return [LXDailyForecast objectWithKeyValues:item];
        }] array];
    }];
}

@end