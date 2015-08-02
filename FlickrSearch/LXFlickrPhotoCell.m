//
//  LXFlickrPhotoCell.m
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/2.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

#import <UIImageView+WebCache.h>

#import "LXFlickrPhoto.h"
#import "LXFlickrPhotoCell.h"

@interface LXFlickrPhotoCell ()

@property (nonatomic, readwrite, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, readwrite, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation LXFlickrPhotoCell

- (void)configureWithFlickrPhoto:(LXFlickrPhoto *)flickrPhoto
{
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];

    [self.imageView sd_setImageWithURL:flickrPhoto.thumbnailURL
                             completed:
     ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
         [self.activityIndicatorView stopAnimating];
     }];
}

@end