//
//  LXFlickrPhotosViewController.m
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/1.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

#import <MBProgressHUD.h>

#import "LXFlickr.h"
#import "LXFlickrPhoto.h"
#import "LXPhotoBrowser.h"
#import "MBProgressHUD+LX.h"
#import "LXFlickrPhotoCell.h"
#import "LXFlickrPhotoHeaderView.h"
#import "LXFlickrPhotosViewController.h"

static const CGFloat kPadding = 16;

static NSString * const kPhotoCellIdentifier  = @"FlickrPhotoCell";
static NSString * const kHeaderViewIdentifier = @"FlickrPhotoHeaderView";

static NSString * const kOFSampleAppAPIKey          = @"77766361c226eb1cf362b9dc46d70c47";
static NSString * const kOFSampleAppAPISharedSecret = @"44dce4451bb55ea1";

@interface LXFlickrPhotosViewController () <UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UIViewControllerTransitioningDelegate, LXFlickrPhotoBrowserDataSource>

@property (nonatomic, strong) MBProgressHUD        *hud;
@property (nonatomic, weak  ) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSMutableArray      *photos;
@property (nonatomic, strong) NSMutableArray      *searches;
@property (nonatomic, strong) NSMutableDictionary *searchResults;
@property (nonatomic, strong) NSIndexPath         *currentLargePhotoIndexPath;
@property (nonatomic, strong) NSIndexPath         *previousLargePhotoIndexPath;

@property (nonatomic, strong) LXFlickr *flickr;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation LXFlickrPhotosViewController

#pragma mark - 初始化

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.flickr        = [LXFlickr new];
    self.photos        = [NSMutableArray new];
    self.searches      = [NSMutableArray new];
    self.searchResults = [NSMutableDictionary new];

    self.collectionView.backgroundColor =
        [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cork"]];
}

#pragma mark - 创建 HUD

- (MBProgressHUD *)hud
{
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.dimBackground = YES;
        [self.view.window addSubview:_hud];
    }
    return _hud;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.flickr flickrPhotosWithSearchString:textField.text
                                   completion:
     ^(NSString *searchString, NSArray *flickrPhotos, NSError *error) {
         
         if (flickrPhotos.count > 0 && ![self.searches containsObject:searchString]) {

             [self.searches insertObject:searchString atIndex:0];
             self.searchResults[searchString] = flickrPhotos;

             [self.collectionView reloadData];
         }

         [self.hud hide:NO];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if (error) {
             [MBProgressHUD lx_showHudForError:@"网络不给力啊..."];
         }
     }];

    [self.hud show:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    textField.text = nil;
    [textField resignFirstResponder];

    return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LXFlickrPhoto *flickrPhoto = [self p_flickrPhotoForIndexPath:indexPath];

    return (CGSize) {
        flickrPhoto.thumbnailSize.width + kPadding, flickrPhoto.thumbnailSize.height + kPadding
    };
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

    [cell configureWithFlickrPhoto:[self p_flickrPhotoForIndexPath:indexPath]];
    
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

- (BOOL)collectionView:(UICollectionView *)collectionView
    shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;

    return YES;
}

#pragma mark - LXFlickrPhotoBrowserDataSource

- (UIImage *)photoBrowser:(LXPhotoBrowser *)flickrPhotoBrowser thumbnailAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index
                                                 inSection:self.selectedIndexPath.section];
    LXFlickrPhotoCell *cell =
        (LXFlickrPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

    return cell.imageView.image;
}

- (NSURL *)photoBrowser:(LXPhotoBrowser *)flickrPhotoBrowser originalImageURLAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index
                                                 inSection:self.selectedIndexPath.section];

    return [self p_flickrPhotoForIndexPath:indexPath].largeImageURL;
}

#pragma mark - 导航控制

- (IBAction)unwindWithSegue:(UIStoryboardSegue *)segue { }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *searchString = self.searches[self.selectedIndexPath.section];

    LXPhotoBrowser *browser = [segue.destinationViewController viewControllers].lastObject;
    browser.dataSource              = self;
    browser.totalOfPhotos         = [self.searchResults[searchString] count];
    browser.currentPhotoIndex     = self.selectedIndexPath.item;
}

#pragma mark - 辅助方法

- (LXFlickrPhoto *)p_flickrPhotoForIndexPath:(NSIndexPath *)indexPath
{
    NSString *searchString = self.searches[indexPath.section];
    NSArray *searchResults = self.searchResults[searchString];
    return searchResults[indexPath.item];
}

@end