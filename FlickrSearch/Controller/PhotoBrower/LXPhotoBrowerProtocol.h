//
//  LXPhotoBrowerProtocol.h
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/6.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

@protocol LXPhotoBrowerProtocol <NSObject>

@property (nonatomic, readwrite, assign) NSUInteger photoIndex;
@property (nonatomic, readwrite, strong) NSURL      *originalImageURL;
@property (nonatomic, readonly,  strong) UIImage    *originalImage;
@property (nonatomic, readwrite, strong) UIImage    *placeholderImage;

@end