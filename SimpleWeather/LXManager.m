//
//  LXManager.m
//  SimpleWeather
//
//  Created by 从今以后 on 15/7/26.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXClient.h"
#import "LXManager.h"
#import "LXCondition.h"
#import <TSMessage.h>
#import <ReactiveCocoa.h>


@interface LXManager () <CLLocationManagerDelegate>

@property (nonatomic, readwrite, strong) LXCondition *currentCondition;

@property (nonatomic, readwrite, strong) CLLocation  *currentLocation;

@property (nonatomic, readwrite, strong) NSArray     *hourlyForecast;

@property (nonatomic, readwrite, strong) NSArray     *dailyForecast;


@property (nonatomic, strong) LXClient *client;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end


@implementation LXManager

#pragma mark - 获取单例

+ (instancetype)sharedManager
{
    static id sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

#pragma mark - 初始化

- (instancetype)init
{
    self = [super init];
    if (self) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;

        _client = [LXClient new];

        // 观察自身的 currentLocation 属性变化, 如果其值为 nil 则忽略方法链后面的部分.
        [[[[RACObserve(self, currentLocation) ignore:nil] flattenMap:^RACStream *(CLLocation *newLocation) {
            return [RACSignal merge:@[[self updateCurrentConditions],
                                      [self updateDailyForecast],
                                      [self updateHourlyForecast]]];
            // 将信号传递给主线程的观察者.发生错误时显示个提示.
        }] deliverOn:RACScheduler.mainThreadScheduler] subscribeError:^(NSError *error) {
            [TSMessage showNotificationWithTitle:@"错误"
                                        subtitle:@"获取过程出了些问题..."
                                            type:TSMessageNotificationTypeError];
        }];
    }
    return self;
}

#pragma mark - 获取位置

- (void)findCurrentLocation
{
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0.0"
                                                options:NSNumericSearch] != NSOrderedAscending) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations.lastObject;
    if (location.horizontalAccuracy > 0) {
        [manager stopUpdatingLocation];
        self.currentLocation = location;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
}

#pragma mark - 获取气象数据

- (RACSignal *)updateCurrentConditions
{
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(LXCondition *condition) {
        self.currentCondition = condition;
    }];
}

- (RACSignal *)updateDailyForecast
{
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.dailyForecast = conditions;
    }];
}

- (RACSignal *)updateHourlyForecast
{
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.hourlyForecast = conditions;
    }];
}

@end