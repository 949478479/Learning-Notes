//
//  LXFlickrPhotoHeaderView.m
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/2.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

#import "LXFlickrPhotoHeaderView.h"

@interface LXFlickrPhotoHeaderView ()

@property (nonatomic, weak) IBOutlet UILabel *searchLabel;

@end

@implementation LXFlickrPhotoHeaderView

- (void)setTitle:(NSString *)title
{
    _title = [title copy];

    self.searchLabel.text = _title;
}

@end