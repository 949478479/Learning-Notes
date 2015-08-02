//
//  LXFlickrPhotoHeaderView.m
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/2.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

#import "LXFlickrPhotoHeaderView.h"

@interface LXFlickrPhotoHeaderView ()

@property (nonatomic, weak) IBOutlet UILabel     *searchLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@end

@implementation LXFlickrPhotoHeaderView

- (void)setSearchText:(NSString *)searchText
{
    _searchText = [searchText copy];

    self.searchLabel.text = _searchText;
}

@end