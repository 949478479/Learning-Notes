## PullRefresh

受这篇教程启发 [如何加入自訂的下拉更新元件](http://www.appcoda.com.tw/custom-pull-to-refresh/?utm_source=sendy&utm_medium=email&utm_campaign=pull-to-refresh-control)

![](https://github.com/949478479/Learning-Notes/blob/master/PullRefresh-screenshot/PullRefresh.gif)

本来为了省事就直接往`UIRefreshControl`上覆盖自定义刷新控件,结果发现坑比较多,这里记录下.

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
    初始拖动时只要不是太快 frame.minY 一般会比 -3 大,例如 -0.5 , -1 之类,这个时候如果高度 >=60 ,就隐藏. */
    hidden = (bounds.height >= 60 && frame.minY > -3)
    
    refreshContents.frame = bounds
}
```