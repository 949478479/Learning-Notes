//
//  LXPhotoBrowerProtocol.h
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/6.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

@protocol LXPhotoBrowerProtocol <NSObject>

@property (nonatomic, assign) NSUInteger photoIndex;
@property (nonatomic, strong) NSURL      *originalImageURL;
@property (nonatomic, strong) UIImage    *placeholderImage;

@end