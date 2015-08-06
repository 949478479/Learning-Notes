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

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation LXFlickrPhotoViewController

@synthesize photoIndex       = _photoIndex;
@synthesize originalImageURL = _originalImageURL;
@synthesize placeholderImage = _placeholderImage;

- (void)dealloc
{
    // 同时只存在左中右三个控制器,多出的会销毁,及时取消任务,否则 hud 进度走不动.
    [self.imageView sd_cancelCurrentImageLoad];
}

#pragma mark - 预加载图片

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 这里有个诡异的强引用,在 block 内添加会造成控制器无法销毁,只好把添加 hud 放在外面处理.
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText      = @"加载中...";
    hud.mode           = MBProgressHUDModeDeterminate;
    [self.imageView addSubview:hud];

    __weak __typeof(hud) weakHud = hud;

    [self.imageView sd_setImageWithURL:self.originalImageURL
                      placeholderImage:self.placeholderImage
                               options:(SDWebImageOptions)0
                              progress:
     ^(NSInteger receivedSize, NSInteger expectedSize) {

         if (expectedSize == -1) { // 第一次调用时 expectedSize 为 -1.
             [weakHud show:YES];
         }
         weakHud.progress = (float)receivedSize / expectedSize;

     } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
         [weakHud hide:YES];
     }];
}

@end