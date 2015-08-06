//
//  LXFlickrPhotoViewController.m
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/5.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

#import <MBProgressHUD.h>
#import <UIImageView+WebCache.h>

#import "LXFlickrPhotoViewController.h"

@interface LXFlickrPhotoViewController ()

@property (nonatomic, strong) MBProgressHUD        *hud;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end

@implementation LXFlickrPhotoViewController

@synthesize photoIndex       = _photoIndex;
@synthesize originalImageURL = _originalImageURL;
@synthesize placeholderImage = _placeholderImage;

- (void)dealloc
{

}

#pragma mark - 预加载图片

- (void)viewDidLoad
{
    [super viewDidLoad];

    __weak __typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:self.originalImageURL
                      placeholderImage:self.placeholderImage
                               options:(SDWebImageOptions)0
                              progress:
     ^(NSInteger receivedSize, NSInteger expectedSize) {
         [weakSelf p_addHudToImageView];
         weakSelf.hud.progress = (float)receivedSize / expectedSize;
     } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
         [weakSelf.hud hide:YES];
     }];
}

#pragma mark - 添加 HUD

- (void)p_addHudToImageView
{
    if (!self.hud) {

        self.hud           = [[MBProgressHUD alloc] initWithView:self.view];
        self.hud.labelText = @"加载中...";
        self.hud.mode      = MBProgressHUDModeDeterminate;

        [self.imageView addSubview:self.hud];

        [self.hud show:YES];
    }
}

@end