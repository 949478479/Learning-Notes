//
//  ViewController.m
//  SimpleWeather
//
//  Created by 从今以后 on 15/7/26.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

#import "LXViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>


@interface LXViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) IBOutlet UIImageView *blurredImageView;

@property (nonatomic) IBOutlet UITableView *tableView;

@end


@implementation LXViewController

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView.tableHeaderView.frame = self.view.bounds;
    [_blurredImageView setImageToBlur:[UIImage imageNamed:@"bg"] blurRadius:10 completionBlock:nil];
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