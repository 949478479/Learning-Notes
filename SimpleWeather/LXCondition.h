//
//  LXCondition.h
//  SimpleWeather
//
//  Created by 从今以后 on 15/7/26.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import <Mantle.h>


@interface LXCondition : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) NSDate *date;

@property (nonatomic, readonly) NSDate *sunrise;
@property (nonatomic, readonly) NSDate *sunset;

@property (nonatomic, readonly) NSNumber *humidity;

@property (nonatomic, readonly) NSNumber *tempLow;
@property (nonatomic, readonly) NSNumber *tempHigh;
@property (nonatomic, readonly) NSNumber *temperature;

@property (nonatomic, readonly) NSNumber *windSpeed;
@property (nonatomic, readonly) NSNumber *windBearing;

@property (nonatomic, readonly) NSString *icon;

@property (nonatomic, readonly) NSString *locationName;

@property (nonatomic, readonly) NSString *condition;
@property (nonatomic, readonly) NSString *conditionDescription;


- (NSString *)imageName;

@end