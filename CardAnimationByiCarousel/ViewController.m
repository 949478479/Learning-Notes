//
//  ViewController.m
//  CardAnimationByiCarousel
//
//  Created by 从今以后 on 15/8/5.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

#import <iCarousel.h>

#import "ViewController.h"

@interface ViewController () <iCarouselDelegate, iCarouselDataSource>

@property (nonatomic, assign) CGSize cardSize;

@end

@implementation ViewController

#pragma mark - 初始化

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGFloat cardWidth  = CGRectGetWidth(self.view.bounds) * 5 / 7; // 屏幕分 7 份,卡片宽占 5 份.
    CGFloat cardHeight = cardWidth * 16 / 9; // 16 : 9 的比例.
    self.cardSize = CGSizeMake(cardWidth, cardHeight);

    [self.view addSubview:({
        iCarousel *carousel      = [[iCarousel alloc] initWithFrame:self.view.bounds];
        carousel.type            = iCarouselTypeCustom;
        // 调整用户观察点偏移量.
        // 这个值是反着来的.例如这里向左偏移五分之一的卡片宽度,其效果为中心的卡片向右偏移这么个距离.其他卡片以此类推.
        carousel.viewpointOffset = CGSizeMake(-self.cardSize.width / 5, 0);
        carousel.delegate        = self;
        carousel.dataSource      = self;
        carousel;
    })];
}

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 10;
}

- (UIView *)carousel:(iCarousel *)carousel
  viewForItemAtIndex:(NSInteger)index
         reusingView:(UIView *)view
{
    if (!view) {
        view = [UIView new];

        view.bounds = (CGRect){ .size = self.cardSize };

        const CGFloat kCornerRadius = 5;

        view.layer.cornerRadius = kCornerRadius;

        view.layer.shadowOpacity = 0.5;
        view.layer.shadowRadius  = kCornerRadius;
        view.layer.shadowOffset  = CGSizeZero;
        view.layer.shadowPath    = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                              cornerRadius:kCornerRadius].CGPath;
        [view addSubview:({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.bounds];

            imageView.tag         = 'icon';
            imageView.contentMode = UIViewContentModeScaleAspectFill;

            imageView.layer.cornerRadius  = kCornerRadius;
            imageView.layer.masksToBounds = YES;

            imageView;
        })];
    }

    ((UIImageView *)[view viewWithTag:'icon']).image =
        [UIImage imageNamed:[NSString stringWithFormat:@"%ld", index]];

    return view;
}

#pragma mark - iCarouselDelegate

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return self.cardSize.width;
}

- (CATransform3D)carousel:(iCarousel *)carousel
   itemTransformForOffset:(CGFloat)offset
            baseTransform:(CATransform3D)transform
{
    // 正中间的视图静止时 offset 为 0, 它左边相邻的视图为 -1, 右边相邻的视图为 1, 以此类推.
    // 例如往右拖动时,正中间的视图的 offset 会由 0 开始向正方向增长,右边相邻的视图则由 1 开始向正方向增长,以此类推.
    // 这里根据 offset 不同计算偏移量和缩放量,以及确定 z 轴方向上的高度层级.

    CGFloat scale       = [self p_scaleByOffset:offset];
    CGFloat translation = [self p_translationByOffset:offset];

    transform = CATransform3DTranslate(transform, translation, 0, offset);
    transform = CATransform3DScale(transform, scale, scale, 1);

    return transform;
}

- (CGFloat)carousel:(iCarousel *)carousel
     valueForOption:(iCarouselOption)option
        withDefault:(CGFloat)value
{
    if (option == iCarouselOptionWrap) {
        value = YES; // 循环滚动.
    } else if (option == iCarouselOptionVisibleItems) {
        value = 4; // 同时只显示 4 个卡片.
    }
    return value;
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
    for (UIView *cardView in [carousel visibleItemViews]) {

        NSInteger index = [carousel indexOfItemView:cardView];
        CGFloat offset  = [carousel offsetForItemAtIndex:index];

        // 屏幕上只显示了4个卡片,最左边的 offset 为 -2,往左拖动时,其 offset 会在此基础上向负方向增长,即小于 -2.
        // 通过 +3 使 alpha 随着向左拖动由 1 => 0 过渡.而向右拖动时,则由 0 => 1 变化.
        if (offset < -2.0) {
            cardView.alpha = offset + 3;
        } else {
            cardView.alpha = 1;
        }
    }
}

#pragma mark - 辅助方法

- (CGFloat)p_scaleByOffset:(CGFloat)offset
{
    return offset * 0.05 + 1; // 随便写的.
}

- (CGFloat)p_translationByOffset:(CGFloat)offset
{
    // 这个是根据一条过原点的单调递增函数曲线的函数公式来的.
    // 最右边卡片初始位置偏移 4/5 卡片宽度,最左边卡片初始位置偏移 -2/5 卡片宽度.最后整理下就是这个值.
    // offset 即是 x 变量.
    
    CGFloat a = 5 / 4.0;
    CGFloat b = 5 / 8.0;

    return (1 / (a - b * offset) - 1 / a) * self.cardSize.width;
}

@end