//
//  LXFlickrPhotosViewController.m
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/1.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

#import <ObjectiveFlickr.h>

#import "LXFlickr.h"
#import "LXFlickrPhoto.h"
#import "LXFlickrPhotoCell.h"
#import "LXFlickrPhotoHeaderView.h"
#import "LXFlickrPhotosViewController.h"

static const CGFloat kPadding = 16;

static NSString * const kPhotoCellIdentifier  = @"FlickrPhotoCell";
static NSString * const kHeaderViewIdentifier = @"FlickrPhotoHeaderView";

static NSString * const kOFSampleAppAPIKey          = @"77766361c226eb1cf362b9dc46d70c47";
static NSString * const kOFSampleAppAPISharedSecret = @"44dce4451bb55ea1";

@interface LXFlickrPhotosViewController () <UICollectionViewDelegateFlowLayout, UITextFieldDelegate, OFFlickrAPIRequestDelegate>

@property (nonatomic, weak) IBOutlet UITextField    *textField;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSMutableArray      *searches;
@property (nonatomic, strong) NSMutableDictionary *searchResults;

@property (nonatomic, strong) LXFlickr *flickr;

@end

@implementation LXFlickrPhotosViewController

#pragma mark - 生命周期

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.flickr        = [LXFlickr new];
    self.searches      = [NSMutableArray new];
    self.searchResults = [NSMutableDictionary new];

    self.collectionView.backgroundColor =
        [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cork"]];

    [self.textField addSubview:({
        UIActivityIndicatorView *activityIndicator =
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.center = (CGPoint){
            CGRectGetMidX(self.textField.bounds), CGRectGetMidY(self.textField.bounds)
        };
        self.activityIndicator = activityIndicator;
        activityIndicator;
    })];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    textField.enabled = NO;

    [self.flickr flickrPhotosWithSearchString:textField.text
                                   completion:
     ^(NSString *searchString, NSArray *flickrPhotos, NSError *error) {
         
         if (flickrPhotos.count > 0 && ![self.searches containsObject:searchString]) {
             [self.searches insertObject:searchString atIndex:0];
             self.searchResults[searchString] = flickrPhotos;

             [self.collectionView reloadData];
         }

         textField.enabled = YES;
         [self.activityIndicator stopAnimating];
     }];

    [self.activityIndicator startAnimating];
    [textField resignFirstResponder];
    textField.text = nil;

    return YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.searches.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSString *searchString = self.searches[section];
    return [self.searchResults[searchString] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LXFlickrPhotoCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier
                                                  forIndexPath:indexPath];

    NSString *searchString     = self.searches[indexPath.section];
    LXFlickrPhoto *flickrPhoto = self.searchResults[searchString][indexPath.row];
    [cell configureWithFlickrPhoto:flickrPhoto];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    LXFlickrPhotoHeaderView *headerView =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                           withReuseIdentifier:kHeaderViewIdentifier
                                                  forIndexPath:indexPath];

    headerView.searchText = self.searches[indexPath.section];

    return headerView;
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *searchString     = self.searches[indexPath.section];
    LXFlickrPhoto *flickrPhoto = self.searchResults[searchString][indexPath.item];
    return (CGSize){
        flickrPhoto.thumbnailSize.width + kPadding, flickrPhoto.thumbnailSize.height + kPadding
    };
}

@end