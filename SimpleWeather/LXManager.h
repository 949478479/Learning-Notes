//
//  LXManager.h
//  SimpleWeather
//
//  Created by 从今以后 on 15/7/26.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

@import Foundation;
@import CoreLocation;

@class LXCondition;


@interface LXManager : NSObject

@property (nonatomic, readonly, strong) LXCondition *currentCondition;

@property (nonatomic, readonly, strong) CLLocation  *currentLocation;

@property (nonatomic, readonly, strong) NSArray     *hourlyForecast;

@property (nonatomic, readonly, strong) NSArray     *dailyForecast;

+ (instancetype)sharedManager;

- (void)findCurrentLocation;

@end