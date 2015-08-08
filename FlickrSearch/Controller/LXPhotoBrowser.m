//
//  LXPhotoBrowser.m
//  FlickrSearch
//
//  Created by 从今以后 on 15/8/5.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

#import "LXPhotoBrowser.h"
#import "LXPhotoBrowerProtocol.h"

static const NSTimeInterval kHideBarDelay = 3;

@interface LXPhotoBrowser () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageVC;

@property (nonatomic, strong) dispatch_block_t delayHideBarBlock;

@end

@implementation LXPhotoBrowser

- (void)dealloc
{

}

#pragma mark - 初始化

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.pageVC = self.childViewControllers.lastObject;
    self.pageVC.delegate   = self;
    self.pageVC.dataSource = self;

    [self.pageVC setViewControllers:@[[self p_viewControllerAtIndex:self.currentPhotoIndex]]
                          direction:UIPageViewControllerNavigationDirectionForward
                           animated:NO
                         completion:nil];

    [self p_setTitleWithPhotoIndex:self.currentPhotoIndex];

    [self p_hideBarAfterDelay:kHideBarDelay];
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
    photoVC.originalImageURL = [self.dataSource photoBrowser:self originalImageURLAtIndex:index];
    photoVC.placeholderImage = [self.dataSource photoBrowser:self thumbnailAtIndex:index];

    return photoVC;
}

#pragma mark - UIPageViewControllerDataSource (供应图片展示控制器)

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

#pragma mark - UIPageViewControllerDelegate (更新索引标题)

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

#pragma mark - 显示/隐藏导航栏状态栏

- (IBAction)p_tapGestureRecognizer:(UITapGestureRecognizer *)sender
{
    if (self.navigationController.navigationBar.isHidden) {

        [self p_setBarHidden:NO];

        [self p_hideBarAfterDelay:kHideBarDelay + UINavigationControllerHideShowBarDuration];
    }
    else {
        [self p_setBarHidden:YES];

        dispatch_block_cancel(self.delayHideBarBlock);
    }

    // 防止狂点...
    sender.enabled = NO;

    dispatch_time_t when =
        dispatch_time(DISPATCH_TIME_NOW,
                      (int64_t)(UINavigationControllerHideShowBarDuration * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

- (void)p_hideBarAfterDelay:(NSTimeInterval)delay
{
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), self.delayHideBarBlock);
}

- (void)p_setBarHidden:(BOOL)hidden
{
    [self.navigationController setNavigationBarHidden:hidden animated:YES];

    [[UIApplication sharedApplication] setStatusBarHidden:hidden
                                            withAnimation:UIStatusBarAnimationSlide];
}

- (dispatch_block_t)delayHideBarBlock
{
    if ( !_delayHideBarBlock || dispatch_block_testcancel(_delayHideBarBlock) ) {
        __weak __typeof(self) weakSelf = self;
        _delayHideBarBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
            [weakSelf p_setBarHidden:YES];
        });
    }
    return _delayHideBarBlock;
}

@end