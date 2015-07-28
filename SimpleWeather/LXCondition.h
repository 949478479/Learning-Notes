//
//  LXCondition.h
//  SimpleWeather
//
//  Created by 从今以后 on 15/7/26.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

@import Foundation;

@interface LXCondition : NSObject

/** dt. */
@property (nonatomic, readonly, strong) NSDate   *date;

/** main.temp_min */
@property (nonatomic, readonly, strong) NSNumber *tempLow;
/** main.temp_max */
@property (nonatomic, readonly, strong) NSNumber *tempHigh;
/** main.temp */
@property (nonatomic, readonly, strong) NSNumber *temperature;

/** name. */
@property (nonatomic, readonly, copy  ) NSString *locationName;

/** weather[0].icon */
@property (nonatomic, readonly, copy  ) NSString *icon;
/** weather[0].description */
@property (nonatomic, readonly, copy  ) NSString *conditionDescription;

- (NSString *)imageName;

@end