//
//  LXFlickrPhoto.h
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/1.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

@import UIKit;

@interface LXFlickrPhoto : NSObject

@property (nonatomic, assign) CGSize  thumbnailSize;
@property (nonatomic, assign) CGSize  largeImageSize;
@property (nonatomic, strong) NSURL  *thumbnailURL;
@property (nonatomic, strong) NSURL  *largeImageURL;

@end