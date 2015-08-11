//
//  LXPhotoBrowser.h
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/5.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

@import UIKit;

@class LXPhotoBrowser;

@protocol LXFlickrPhotoBrowserDataSource <NSObject>

- (UIImage *)photoBrowser:(LXPhotoBrowser *)flickrPhotoBrowser thumbnailAtIndex:(NSUInteger)index;

- (NSURL *)photoBrowser:(LXPhotoBrowser *)flickrPhotoBrowser originalImageURLAtIndex:(NSUInteger)index;

@end

@interface LXPhotoBrowser : UIViewController

@property (nonatomic, weak) id<LXFlickrPhotoBrowserDataSource> dataSource;

@property (nonatomic, assign) NSUInteger totalOfPhotos;

@property (nonatomic, assign) NSUInteger currentPhotoIndex;

@end