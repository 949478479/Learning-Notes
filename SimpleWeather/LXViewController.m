//
//  ViewController.m
//  SimpleWeather
//
//  Created by 从今以后 on 15/7/26.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXViewController.h"
#import "LXManager.h"
#import "LXCondition.h"

#import <RACEXTScope.h>
#import <ReactiveCocoa.h>
#import <UIImageView+LBBlurredImage.h>

@interface LXViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel     *cityLabel;
@property (nonatomic, strong) IBOutlet UILabel     *hiloLabel;
@property (nonatomic, strong) IBOutlet UILabel     *temperatureLabel;
@property (nonatomic, strong) IBOutlet UILabel     *conditionsLabel;
@property (nonatomic, strong) IBOutlet UIImageView *iconView;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIImageView *blurredImageView;

@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;

@end

@implementation LXViewController

#pragma mark - 初始化

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _hourlyFormatter = [NSDateFormatter new];
        _hourlyFormatter.dateFormat = @"a h:mm";

        _dailyFormatter = [NSDateFormatter new];
        _dailyFormatter.dateFormat = @"MM dd  EE";
    }
    return self;
}

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableHeaderView.frame = self.view.bounds;
    self.tableView.rowHeight             = self.view.bounds.size.height / 7;

    [self.blurredImageView setImageToBlur:[UIImage imageNamed:@"bg"]
                               blurRadius:10
                          completionBlock:nil];

    @weakify(self)
    
    // 监听 LXManager 的 currentCondition, 一旦发生变化就在主线程执行 block 中的内容.
    [[RACObserve([LXManager sharedManager], currentCondition)
      deliverOn:RACScheduler.mainThreadScheduler]
      subscribeNext:^(LXCondition *newCondition) {
          @strongify(self)
          self.temperatureLabel.text = [NSString stringWithFormat:@"%.f°", newCondition.temperature.floatValue];
          self.conditionsLabel.text  = newCondition.conditionDescription;
          self.cityLabel.text        = newCondition.locationName;
          if (newCondition.imageName) {
              self.iconView.image    = [UIImage imageNamed:newCondition.imageName];
          }
    }];

    // 信号的返回值将会赋值给 hiloLabel 的 text 属性.
    // 观察 LXManager 的 currentCondition 属性的 tempHigh 和 tempLow, 将信号合并返回单一数据.
    RAC(self.hiloLabel, text) =
        [[RACSignal combineLatest:
              @[RACObserve([LXManager sharedManager], currentCondition.tempHigh),
                RACObserve([LXManager sharedManager], currentCondition.tempLow)]
          reduce:^(NSNumber *high, NSNumber *low){
              return [NSString stringWithFormat:@"%.f° / %.f°", high.floatValue, low.floatValue];
          }]
          deliverOn:RACScheduler.mainThreadScheduler];

    // 逐时/每日 预报变化时刷新表视图.
    [[RACObserve([LXManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(NSArray *newForecast) {
            @strongify(self)
            [self.tableView reloadData];
      }];

    [[RACObserve([LXManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(NSArray *newForecast) {
            @strongify(self)
            [self.tableView reloadData];
      }];

    [[LXManager sharedManager] findCurrentLocation];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 使用最近 6小时/天 的预报,不足也要留出空位.然后额外添加了一个单元格作为页眉.
    if (section == 0) {
        return MIN( [LXManager sharedManager].hourlyForecast.count, (NSUInteger)6 ) + 1;
    }
    return MIN( [LXManager sharedManager].dailyForecast.count, (NSUInteger)6 ) + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier  = (indexPath.row == 0) ? @"HeaderCell" : @"NormalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"小时预报"]; // 第一行是标题单元格.
        } else {
            LXCondition *weather = [LXManager sharedManager].hourlyForecast[indexPath.row - 1];
            [self configureHourlyCell:cell weather:weather];
        }
    } else {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"每日预报"];
        } else {
            LXCondition *weather = [LXManager sharedManager].dailyForecast[indexPath.row - 1];
            [self configureDailyCell:cell weather:weather];
        }
    }

    return cell;
}

#pragma mark - 配置单元格内容

- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title
{
    cell.textLabel.text = title;
}

- (void)configureHourlyCell:(UITableViewCell *)cell weather:(LXCondition *)weather
{
    cell.imageView.image       = [UIImage imageNamed:weather.imageName];
    cell.textLabel.text        = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text  = [NSString stringWithFormat:@"%.f°", weather.temperature.floatValue];
}

- (void)configureDailyCell:(UITableViewCell *)cell weather:(LXCondition *)weather
{
    cell.imageView.image      = [UIImage imageNamed:weather.imageName];
    cell.textLabel.text       = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.f° / %.f°",
                                 weather.tempHigh.floatValue, weather.tempLow.floatValue];
}

#pragma mark - 改变模糊效果

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat position = MAX(0, scrollView.contentOffset.y);
    CGFloat percent  = MIN(position / scrollView.bounds.size.height, 1);
    self.blurredImageView.alpha = percent;
}

@end