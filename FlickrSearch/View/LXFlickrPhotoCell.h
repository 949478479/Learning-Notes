//
//  LXFlickrPhotoCell.h
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/2.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

@import UIKit;

@class LXFlickrPhoto;

@interface LXFlickrPhotoCell : UICollectionViewCell

@property (nonatomic, readonly, weak) IBOutlet UIImageView *imageView;

- (void)configureWithFlickrPhoto:(LXFlickrPhoto *)flickrPhoto;

@end