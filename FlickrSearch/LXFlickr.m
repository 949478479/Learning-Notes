//
//  LXFlickr.m
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/1.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

#import <ObjectiveFlickr.h>

#import "LXFlickr.h"
#import "LXFlickrPhoto.h"

static NSString * const kOFSampleAppAPIKey          = @"77766361c226eb1cf362b9dc46d70c47";
static NSString * const kOFSampleAppAPISharedSecret = @"44dce4451bb55ea1";

@interface LXFlickr () <OFFlickrAPIRequestDelegate>

@property (nonatomic, copy)   NSString           *searchString;
@property (nonatomic, copy)   LXFlickrSearchCompletionBlock completion;

@property (nonatomic, strong) NSMutableArray     *flickrPhotos;
@property (nonatomic, strong) NSMutableSet       *getSizeRequests;

@property (nonatomic, strong) OFFlickrAPIContext *flickrContext;
@property (nonatomic, strong) OFFlickrAPIRequest *searchRequest;

@end

@implementation LXFlickr

- (instancetype)init
{
    self = [super init];
    if (self) {
        _flickrPhotos    = [NSMutableArray new];
        _getSizeRequests = [NSMutableSet new];
        _flickrContext   = [[OFFlickrAPIContext alloc] initWithAPIKey:kOFSampleAppAPIKey
                                                         sharedSecret:kOFSampleAppAPISharedSecret];
    }
    return self;
}

- (void)flickrPhotosWithSearchString:(NSString *)searchString
                          completion:(LXFlickrSearchCompletionBlock)completion
{
    [self.searchRequest cancel];
    [self.getSizeRequests makeObjectsPerformSelector:@selector(cancel)];
    [self.getSizeRequests removeAllObjects];

    self.searchString = searchString;
    self.completion   = completion;

    self.searchRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
    self.searchRequest.delegate = self;
    [self.searchRequest callAPIMethodWithGET:@"flickr.photos.search"
                                   arguments:@{ @"text" : searchString,
                                                @"per_page" : @"20" }];
}

#pragma mark - OFFlickrAPIRequestDelegate

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest
 didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    if (self.searchRequest != inRequest) {
        NSArray *size = inResponseDictionary[@"sizes"][@"size"];

        LXFlickrPhoto *flickrPhoto = [LXFlickrPhoto new];
        for (NSDictionary *dict in size) {
            if ([dict[@"label"] isEqualToString:@"Thumbnail"]) {
                flickrPhoto.thumbnailURL  = dict[@"source"];
                flickrPhoto.thumbnailSize = (CGSize) {
                    [dict[@"width"] doubleValue], [dict[@"height"] doubleValue]
                };
                if (!CGSizeEqualToSize(flickrPhoto.largeImageSize, CGSizeZero)) {
                    break;
                }
            } else if ([dict[@"label"] isEqualToString:@"Large"]) {
                flickrPhoto.largeImageURL  = dict[@"source"];
                flickrPhoto.largeImageSize = (CGSize) {
                    [dict[@"width"] doubleValue], [dict[@"height"] doubleValue]
                };
                if (!CGSizeEqualToSize(flickrPhoto.thumbnailSize, CGSizeZero)) {
                    break;
                }
            }
        }


        [self.flickrPhotos addObject:flickrPhoto];
        
        [self.getSizeRequests removeObject:inRequest];

        if (self.getSizeRequests.count == 0) {
            if (self.completion) {
                self.completion(self.searchString, [self.flickrPhotos copy], nil);
            }
            [self.flickrPhotos removeAllObjects];
        }
    }
    else {
        for (NSDictionary *photo in inResponseDictionary[@"photos"][@"photo"]) {
            OFFlickrAPIRequest *request =
                [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
            request.delegate = self;
            [request callAPIMethodWithGET:@"flickr.photos.getSizes"
                                arguments:@{ @"photo_id" : photo[@"id"] }];
            [self.getSizeRequests addObject:request];
        }
    }
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest
        didFailWithError:(NSError *)inError
{
    if (self.searchRequest == inRequest) {
        if (self.completion) {
            self.completion(self.searchString, nil, inError);
        }
    } else {
        [self.getSizeRequests removeObject:inRequest];
    }

    NSLog(@"搜索失败: %@", inError.localizedDescription);
}

@end