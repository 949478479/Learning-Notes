//
//  LXPhotoBrowser.m
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/5.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

#import "LXPhotoBrowser.h"
#import "LXPhotoBrowerProtocol.h"

@interface LXPhotoBrowser () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageVC;

@end

@implementation LXPhotoBrowser

- (void)dealloc
{

}

#pragma mark - 初始化

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self p_setTitleWithPhotoIndex:self.currentPhotoIndex];

    self.pageVC = self.childViewControllers.lastObject;
    self.pageVC.delegate   = self;
    self.pageVC.dataSource = self;
    [self.pageVC setViewControllers:@[[self p_viewControllerAtIndex:self.currentPhotoIndex]]
                          direction:UIPageViewControllerNavigationDirectionForward
                           animated:NO
                         completion:nil];
}

#pragma mark - 设置索引标题

- (void)p_setTitleWithPhotoIndex:(NSUInteger)index
{
    self.title = [NSString stringWithFormat:@"%lu / %lu", index + 1, self.totalOfPhotos];
}

#pragma mark - 创建图片控制器

- (UIViewController<LXPhotoBrowerProtocol> *)p_viewControllerAtIndex:(NSUInteger)index
{
    UIViewController<LXPhotoBrowerProtocol> *photoVC =
        [self.storyboard instantiateViewControllerWithIdentifier:@"LXFlickrPhotoVC"];

    photoVC.photoIndex       = index;
    photoVC.originalImageURL = [self.delegate photoBrowser:self originalImageURLAtIndex:index];
    photoVC.placeholderImage = [self.delegate photoBrowser:self thumbnailAtIndex:index];

    return photoVC;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    UIViewController<LXPhotoBrowerProtocol> *photoVC =
        (UIViewController<LXPhotoBrowerProtocol> *)viewController;

    if (photoVC.photoIndex == 0) {
        return nil;
    }

    return [self p_viewControllerAtIndex:photoVC.photoIndex - 1];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    UIViewController<LXPhotoBrowerProtocol> *photoVC =
        (UIViewController<LXPhotoBrowerProtocol> *)viewController;

    if (photoVC.photoIndex == self.totalOfPhotos - 1) {
        return nil;
    }

    return [self p_viewControllerAtIndex:photoVC.photoIndex + 1];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
    willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    UIViewController<LXPhotoBrowerProtocol> *photoVC =
        (UIViewController<LXPhotoBrowerProtocol> *)pendingViewControllers.lastObject;

    self.currentPhotoIndex = photoVC.photoIndex;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (completed) {
        [self p_setTitleWithPhotoIndex:self.currentPhotoIndex];
    }
    else {
        UIViewController<LXPhotoBrowerProtocol> *photoVC =
            (UIViewController<LXPhotoBrowerProtocol> *)previousViewControllers.lastObject;

        self.currentPhotoIndex = photoVC.photoIndex; // 回滚索引.
    }
}

@end