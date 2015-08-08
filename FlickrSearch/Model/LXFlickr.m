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

@property (nonatomic, copy  ) NSString *searchString;
@property (nonatomic, strong) NSMutableArray *flickrPhotos;
@property (nonatomic, copy  ) LXFlickrSearchCompletionBlock completion;

@property (nonatomic, strong) OFFlickrAPIContext *flickrContext;
@property (nonatomic, strong) OFFlickrAPIRequest *searchRequest;
@property (nonatomic, strong) NSMutableSet       *getSizeRequests;

@end

@implementation LXFlickr

#pragma mark - 初始化

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

- (NSMutableArray *)flickrPhotos
{
    if (!_flickrPhotos) {
        _flickrPhotos = [NSMutableArray new];
    }
    return _flickrPhotos;
}

#pragma mark - 发起请求

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
                                   arguments:@{ @"text" : searchString, @"per_page" : @"20" }];
}

#pragma mark - OFFlickrAPIRequestDelegate

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest
 didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    // 获取单个图片尺寸请求完成.
    if (self.searchRequest != inRequest) {

        NSArray *size = inResponseDictionary[@"sizes"][@"size"];

        LXFlickrPhoto *flickrPhoto = [LXFlickrPhoto new];

        for (NSDictionary *dict in size) {

            if ([dict[@"label"] isEqualToString:@"Small"]) {

                flickrPhoto.thumbnailURL  = [NSURL URLWithString:dict[@"source"]];
                flickrPhoto.thumbnailSize = (CGSize) {
                    [dict[@"width"] doubleValue], [dict[@"height"] doubleValue]
                };

                break;
            }
        }

        // 有的图片没有 Large 这个尺寸,所以若最后一个尺寸不是太大就用最后一个.否则用倒数第二个.
        NSDictionary *dict = size.lastObject;
        CGSize screenSize  = [UIScreen mainScreen].bounds.size;
        CGFloat width      = [dict[@"width"] doubleValue];
        CGFloat height     = [dict[@"height"] doubleValue];

        if (width * height <= screenSize.width * screenSize.height) {
            flickrPhoto.largeImageURL  = [NSURL URLWithString:dict[@"source"]];
            flickrPhoto.largeImageSize = CGSizeMake(width, height);
        }
        else {
            dict = size[size.count - 2];
            flickrPhoto.largeImageURL  = [NSURL URLWithString:dict[@"source"]];
            flickrPhoto.largeImageSize = (CGSize) {
                [dict[@"width"] doubleValue], [dict[@"height"] doubleValue]
            };
        }

        [self.flickrPhotos addObject:flickrPhoto];

        [self p_isLastGetSizeRequestComplete:inRequest];
    }
    // 搜索图片请求完成.
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
    // 搜索请求出错.
    if (self.searchRequest == inRequest) {
        !self.completion ?: self.completion(self.searchString, nil, inError);
    }
    // 获取单个图片尺寸出错.
    else {
        [self p_isLastGetSizeRequestComplete:inRequest];
    }
}

#pragma mark - 请求是否完成

- (void)p_isLastGetSizeRequestComplete:(OFFlickrAPIRequest *)request
{
    [self.getSizeRequests removeObject:request];

    if (self.getSizeRequests.count == 0) {
        !self.completion ?: self.completion(self.searchString, self.flickrPhotos, nil);
        self.flickrPhotos = nil;
    }
}

@end