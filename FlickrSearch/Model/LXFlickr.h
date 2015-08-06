//
//  LXFlickr.h
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/1.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

@import Foundation;

typedef void(^LXFlickrSearchCompletionBlock)(NSString *searchString, NSArray *flickrPhotos, NSError *error);

@interface LXFlickr : NSObject

- (void)flickrPhotosWithSearchString:(NSString *)searchString
                          completion:(LXFlickrSearchCompletionBlock)completion;
@end