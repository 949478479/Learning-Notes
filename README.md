# 继承 UIRefreshControl 的自定义下拉刷新控件

思路来自台版`AppCoda`的这篇教程 [如何加入自訂的下拉更新元件]
(http://www.appcoda.com.tw/custom-pull-to-refresh/?utm_source=sendy&utm_medium=email&utm_campaign=pull-to-refresh-control)

![](Screenshot/PullRefresh.gif)

为了省事就直接继承`UIRefreshControl`,然后往上覆盖自定义视图,结果发现坑比较多,这里记录下:

```swift
// UIRefreshControl 貌似会进行判断,如果背景色为 nil ,其高度将是恒定的 60 ,而不是随着拖动变化.
backgroundColor = backgroundColor ?? UIColor.clearColor()
```

```swift
override func layoutSubviews() {
	super.layoutSubviews()

    /* 初始高度是 64 (有导航栏)或者 60 (刷新控件固定高度就是 60).
    第一次下拉时,第一次触发此方法时高度一般是 64 或者 60 ,导致那一瞬间刷新控件底部会露出来,
    当然如果 cell 高度够大,或者有其他东西能遮挡住刷新控件露出来的部分,就看不见了.
    之后触发此方法时,高度基本等于 y 坐标的绝对值,可能会偏差 0.25~0.5 点.
    初始拖动时只要不是太快 frame.minY 一般会比 -3 大,例如 -0.5 , -1 之类,
    所以这个时候如果高度 >=60 ,就隐藏,不要露出来. */
    hidden = (bounds.height >= 60 && frame.minY > -3)
    
    refreshContents.frame = bounds
}
```

```swift
// 手动触发刷新不会调用 beginRefreshing() , refreshing 属性还不支持 KVO , 只好这样激活动画.
private func addRefreshingHandle() {
    addTarget(self, action: "animateRefreshStep1", forControlEvents: .ValueChanged)
}
```

```swift
override func beginRefreshing() {
    super.beginRefreshing()

	// 代码触发刷新时居然不会自动下拉...还得自己设置下拉.其高度是固定的 60 点.
    if let superview = superview as? UIScrollView {
        superview.setContentOffset(
        	CGPoint(x: 0, y: superview.contentOffset.y - 60), animated: true)
    }
    
    // 开始刷新动画.
    animateRefreshStep1()
}
```

```swift
override func endRefreshing() {
    super.endRefreshing()

    // 有时候可能是中途取消,所以重置下状态.
    currentLabelIndex = 0
    for label in labels {
        label.transform = CGAffineTransformIdentity
        label.textColor = UIColor.blackColor()
    }
}
```

动画部分:

```swift
@objc private func animateRefreshStep1() {

    if !refreshing { return } // 若刷新结束则终止继续后面的动画.

    let label = labels[self.currentLabelIndex]

    UIView.animateWithDuration(0.1, animations: {

        // 向右旋转45°,并改变文字颜色.
        label.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        label.textColor = self.getTextColor()

    }, completion: { _ in

        UIView.animateWithDuration(0.05, animations: {

            // 旋转动画结束后执行恢复原状动画.
            label.transform = CGAffineTransformIdentity
            label.textColor = UIColor.blackColor()

        }, completion: { _ in

            if !self.refreshing { return }

            // 恢复原状后执行下一个 label 的动画,全部完成后执行第二阶段动画.
            if ++self.currentLabelIndex < self.labels.count {
                self.animateRefreshStep1()
            } else {
                self.animateRefreshStep2()
            }
        })
    })
}
```

```swift
private func animateRefreshStep2() {

    if !refreshing { return }

    UIView.animateWithDuration(0.35, animations: {

        // 所有 label 放大动画.
        labels.map { $0.transform = CGAffineTransformMakeScale(1.5, 1.5) }

    }, completion: { _ in

        if !self.refreshing { return }

        UIView.animateWithDuration(0.25, animations: {

            // 所有 label 恢复原大小动画.
            labels.map { $0.transform = CGAffineTransformIdentity }
                
        }, completion: { _ in

            // 若刷新还未结束就循环播放动画.
            if self.refreshing {
                self.currentLabelIndex = 0
                self.animateRefreshStep1()
            }
        })
    })
}
```
