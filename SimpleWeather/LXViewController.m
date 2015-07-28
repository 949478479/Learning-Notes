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

@end


@implementation LXViewController

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableHeaderView.frame = self.view.bounds;

    [self.blurredImageView setImageToBlur:[UIImage imageNamed:@"bg"]
                               blurRadius:10
                          completionBlock:nil];

    [[RACObserve([LXManager sharedManager], currentCondition)
      deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(LXCondition *newCondition) {

        self.temperatureLabel.text = [NSString stringWithFormat:@"%.f°", newCondition.temperature.floatValue];
        self.conditionsLabel.text  = [newCondition.condition capitalizedString];
        self.cityLabel.text        = [newCondition.locationName capitalizedString];
        self.iconView.image        = [UIImage imageNamed:newCondition.imageName];
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end