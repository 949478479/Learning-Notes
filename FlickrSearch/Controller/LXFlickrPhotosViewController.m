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

@interface LXFlickrPhotosViewController () <UITextFieldDelegate, LXFlickrPhotoBrowserDataSource>

@property (nonatomic, strong) MBProgressHUD        *hud;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) UILabel              *shareTextLabel;

@property (nonatomic, strong) LXFlickr             *flickr;
@property (nonatomic, strong) NSMutableArray       *searchStrings;
@property (nonatomic, strong) NSMutableDictionary  *searchResults;

@property (nonatomic, strong) NSMutableDictionary  *selectedPhotos;
@property (nonatomic, strong) NSIndexPath          *selectedIndexPath;

@property (nonatomic, assign) BOOL sharing;

@end

@implementation LXFlickrPhotosViewController

#pragma mark - 初始化

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.flickr         = [LXFlickr new];
    self.searchStrings  = [NSMutableArray new];
    self.searchResults  = [NSMutableDictionary new];
    self.selectedPhotos = [NSMutableDictionary new];

    self.collectionView.backgroundColor =
        [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cork"]];
}

#pragma mark - 导航控制

- (IBAction)unwindWithSegue:(UIStoryboardSegue *)segue { }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *searchString = self.searchStrings[self.selectedIndexPath.section];

    LXPhotoBrowser *browser   = [segue.destinationViewController viewControllers].lastObject;
    browser.dataSource        = self;
    browser.totalOfPhotos     = [self.searchResults[searchString] count];
    browser.currentPhotoIndex = self.selectedIndexPath.item;
}

#pragma mark - 辅助方法

- (LXFlickrPhoto *)p_flickrPhotoForIndexPath:(NSIndexPath *)indexPath
{
    NSString *searchString = self.searchStrings[indexPath.section];
    NSArray *searchResults = self.searchResults[searchString];
    return searchResults[indexPath.item];
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

#pragma mark - 发起搜索请求

- (void)p_performSearchWithSearchString:(NSString *)searchString
{
    [self.flickr flickrPhotosWithSearchString:searchString
                                   completion:
     ^(NSString *searchString, NSArray *flickrPhotos, NSError *error) {

         if (flickrPhotos.count > 0) {

             [self.searchStrings removeObject:searchString];
             [self.searchStrings insertObject:searchString atIndex:0];
             [self.searchResults setObject:flickrPhotos forKey:searchString];

             [self.collectionView reloadData];
         }

         [self.hud hide:YES];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if (error) {
             [MBProgressHUD lx_showHudForError:@"网络不给力啊..."];
         }
     }];
}

#pragma mark - 分享图片

- (IBAction)p_shareAction:(UIBarButtonItem *)sender
{
    if (self.searchStrings.count == 0) { return; }

    if (self.selectedPhotos.count > 0) {

        UIActivityViewController *activityVC =
            [[UIActivityViewController alloc] initWithActivityItems:self.selectedPhotos.allValues
                                              applicationActivities:nil];
        activityVC.completionWithItemsHandler =
            ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                [self p_switchShareState];
        };
        activityVC.modalPresentationStyle = UIModalPresentationPopover;
        activityVC.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;

        [self presentViewController:activityVC animated:YES completion:nil];
    }
    else {
        [self p_switchShareState];
    }
}

- (void)p_updateShareTextLabel
{
    if (!self.shareTextLabel) {
        self.shareTextLabel = [UILabel new];
        self.shareTextLabel.textColor = self.view.tintColor;
    }
    self.shareTextLabel.text =
        [NSString stringWithFormat:@"选中了%lu张图片", self.selectedPhotos.count];
    [self.shareTextLabel sizeToFit];
}

- (void)p_switchShareState
{
    self.sharing = !self.sharing;

    self.textField.enabled = !self.sharing;

    [self.selectedPhotos removeAllObjects];

    self.collectionView.allowsMultipleSelection = self.sharing;
    [self.collectionView selectItemAtIndexPath:nil
                                      animated:YES
                                scrollPosition:UICollectionViewScrollPositionNone];
    if (self.sharing) {
        [self p_updateShareTextLabel];
        UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:self.shareTextLabel];
        [self.navigationItem setRightBarButtonItems:@[self.navigationItem.rightBarButtonItem, labelItem]
                                           animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItems:@[self.navigationItem.rightBarButtonItem]
                                           animated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *serachString = [textField.text stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self p_performSearchWithSearchString:serachString];

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
    return self.searchStrings.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSString *searchString = self.searchStrings[section];
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

    headerView.title = self.searchStrings[indexPath.section];

    return headerView;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView
    shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;

    if (self.sharing) {

        LXFlickrPhotoCell *cell =
            (LXFlickrPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];

        [self.selectedPhotos setObject:cell.imageView.image forKey:indexPath];
        [self p_updateShareTextLabel];

    } else {
        [self performSegueWithIdentifier:@"ModalPhotoBrower" sender:nil];
    }

    return self.sharing;
}

- (void)collectionView:(UICollectionView *)collectionView
    didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedPhotos removeObjectForKey:indexPath];
    [self p_updateShareTextLabel];
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

@end