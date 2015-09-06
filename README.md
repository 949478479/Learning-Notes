## CircularCollectionView
 
学习自`RayWenderlich`的教程 [UICollectionView Custom Layout Tutorial: A Spinning Wheel]
(http://www.raywenderlich.com/107687/uicollectionview-custom-layout-tutorial-spinning-wheel)
 
用`UICollectionView`自定义布局实现这么个轮子滚动效果:

![](https://github.com/949478479/Learning-Notes/blob/master/CircularCollectionView-screenshot/final-scrolling.gif)

基本的思路如下图:

![](https://github.com/949478479/Learning-Notes/blob/master/CircularCollectionView-screenshot/Screenshot-2015-06-01-14.11.42.png)

cell 间的夹角,基本可以随意指定,为了方便可以这么算,效果还不错:

```swift
let anglePerItem = atan(itemSize.width / radius)
```

滚动范围根据 cell 宽度算就行:

```swift
override func collectionViewContentSize() -> CGSize {
    return CGSize(width: CGFloat(collectionView!.numberOfItemsInSection(0)) * itemSize.width,
                 height: collectionView!.bounds.height)
}
```

自定义了布局属性,提供了一个锚点属性:

```swift
class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

    var anchorPoint = CGPoint(x: 0.5, y: 0.5)

    // 针对 anchorPoint, 覆盖 copyWithZone(_:) 和 isEqual(_:) 方法...
}
```

计算布局属性时,需修改锚点,从而让旋转中心跑到屏幕下方,而不是在 cell 中心,如下图:

![](https://github.com/949478479/Learning-Notes/blob/master/CircularCollectionView-screenshot/Screenshot-2015-06-01-16.22.12-192x500.png)

```swift
// 正常锚点 y = 0.5, 对应高度一半.现在要修改锚点到屏幕下方圆心处,即在高度一半基础上加上半径. 
let anchorPointY = (radius + itemSize.height / 2) / itemSize.height

// 让 cell 位于屏幕中心.
let centerX = collectionView!.contentOffset.x + collectionView!.bounds.width / 2

attributes.size        = itemSize
attributes.zIndex      = indexPath.item
attributes.center      = CGPoint(x: centerX, y: self.collectionView!.bounds.midY)
attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
attributes.transform   = CGAffineTransformMakeRotation(anglePerItem * CGFloat(indexPath.item))
```

如果不改锚点,就会变成下面这种堆叠的样子:

![](https://github.com/949478479/Learning-Notes/blob/master/CircularCollectionView-screenshot/Screenshot-2015-05-27-17.56.29-700x417.png)

而一旦改动了锚点, cell 的位置就会跑到屏幕上面去,所以还需要修正位置.

在自定义的 CircularCollectionViewCell 中实现`applyLayoutAttributes(_:)`方法应用自定义布局属性:

```swift
override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
    let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayoutAttributes
    // 修改锚点.
    layer.anchorPoint = circularlayoutAttributes.anchorPoint
    // 正常锚点为 0.5, 对应高度一半,锚点变化量乘上高度即是 y 方向上的位置改变量.
    center.y += (layer.anchorPoint.y - 0.5) * bounds.height
}
```

关于`anchorPoint`,`position`,`frame`,`bounds`这些东西之间的纠葛,可以参看此篇博客 
[彻底理解position与anchorPoint](http://wonderffee.github.io/blog/2013/10/13/understand-anchorpoint-and-position/).

此时效果将会是这样:

![](https://github.com/949478479/Learning-Notes/blob/master/CircularCollectionView-screenshot/scrolling-off.gif)

可以看到 cell 角度对了,但是都沿水平方向滚跑了.在滚动时,需要不断的刷新布局,让 cell 的中点始终处于屏幕中心,
再配合旋转,组合起来就是绕圆心滚动的轮子效果.

首先滚动时要重新布局:

```swift
override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
}
```

滚动起点和滚动终点的情况,如下图所示:

![](https://github.com/949478479/Learning-Notes/blob/master/CircularCollectionView-screenshot/combined-700x391.png)

仔细数一数,发现将最后一个 cell 滚动至屏幕中心时,这个滚动弧度(负数)刚好是 cell 间夹角乘上 cell 总数 - 1, 即:

```swift
let angleAtExtreme = -anglePerItem * CGFloat(itemCount - 1)
```

将这个弧度作为最大滚动弧度,然后根据 collectionView 当前滚动位置相对最终滚动位置的比例,计算当前滚动弧度:

注意最大滚动位置只能达到最终屏幕的左侧,所以应该是`最大内容范围 - 屏幕宽度`.

```swift
let currentAngle = angleAtExtreme * collectionView!.contentOffset.x / 
    (collectionViewContentSize().width - collectionView!.bounds.width)
```

然后在计算布局属性时将旋转弧度加上当前滚动弧度即可:

```swift
attributes.transform = CGAffineTransformMakeRotation(
    anglePerItem * CGFloat(indexPath.item) + currentAngle)
```

这样就完成了滚动中实时计算,效果如下:

![](https://github.com/949478479/Learning-Notes/blob/master/CircularCollectionView-screenshot/final-scrolling.gif)

接下来是性能优化部分,避免计算屏幕范围外的 cell 的布局属性.

示意图如下:

![](https://github.com/949478479/Learning-Notes/blob/master/CircularCollectionView-screenshot/Screenshot-2015-06-01-17.46.48-508x500.png)
![](https://github.com/949478479/Learning-Notes/blob/master/CircularCollectionView-screenshot/Screenshot-2015-06-01-18.23.05-465x500.png)

需要计算出屏幕范围的 cell 的索引:

```swift
// 对应图中 θ 角的弧度.
let θ = atan( (collectionView!.bounds.width / 2) /
    (radius + itemSize.height / 2 - collectionView!.bounds.height / 2) )

// 注意 currentAngle 是负数弧度, θ 是正数弧度.
// 轮子逆时针旋转弧度绝对值为 θ 时,此时第一个 cell 只有一小部分还在屏幕范围内,
// 因为 cell 间是有一定间距的,所以当一个 cell 逆时针旋转弧度绝对值为 θ 时, 它前面的 cell 肯定是在屏幕外的.
// -currentAngle - θ 为轮子逆时针旋转弧度超过 θ 的部分,除以 cell 间夹角,整数部分即是屏幕范围外的 cell 个数.
// 如果有小数部分,则说明有个 cell 只有部分还在屏幕范围.整数值也正好是该 cell 的索引.
let startIndex = (currentAngle < -θ) ? Int((-currentAngle - θ) / anglePerItem) : 0

// 屏幕右侧,未旋转时, θ / anglePerItem 的整数部分刚好表示最右侧且完全在屏幕范围的 cell 的索引,
// 如果有小数部分,则表示最右侧有个 cell 只有部分在屏幕范围,故屏幕范围内的 cell 最大索引要用 ceil(_:) 上舍入.
// 轮子旋转时,需把旋转弧度加上,即 (-currentAngle + θ) / anglePerItem. 
// min 是为了防止越界,例如旋转到最大旋转角度时,计算所得索引为 itemCount.
// 这么计算是没有考虑屏幕左边离屏的情况的,所以还需要配合 startIndex.
let endIndex = min(itemCount - 1, Int(ceil( (-currentAngle + θ) / anglePerItem )))
```

计算布局属性时,只需计算该索引范围内的即可:

```swift
layoutAttributes = (startIndex...endIndex).map {
    // 在这里创建并配置布局属性然后返回,最终全都存入布局属性数组.
}
```

最后实现下分页效果:

```swift
override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint,
    withScrollingVelocity velocity: CGPoint) -> CGPoint {

    var proposedContentOffset = proposedContentOffset

    // 每移动一点对应的旋转弧度,即 弧度/点.
    let factor = angleAtExtreme / (collectionViewContentSize().width - collectionView!.bounds.width)

    // 停止时的旋转弧度.
    let proposedAngle = proposedContentOffset.x * factor

    // 停止时的旋转弧度对应多少个 cell.
	let multiple = proposedAngle / anglePerItem

	// 根据滚动方向取整数.
	let integralMultiple: CGFloat

	if velocity.x > 0 {
    	integralMultiple = ceil(multiple)
	} else if velocity.x < 0 {
    	integralMultiple = floor(multiple)
	} else {
    	integralMultiple = round(multiple)
	}

	// "总弧度" ÷ "弧度/点" = "滚动距离".
	proposedContentOffset.x = (integralMultiple * anglePerItem) / factor

    return proposedContentOffset
}
```
