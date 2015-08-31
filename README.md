## Ultravisual

学习自`RayWenderlich`的教程 [Swift Expanding Cells in iOS Collection Views]
(http://www.raywenderlich.com/99087/swift-expanding-cells-ios-collection-views)

该教程讲解了如何实现类似`Ultravisual`的视差效果,这里整理下重点.

![](https://github.com/949478479/Learning-Notes/blob/master/Ultravisual-screenshot/Finalstep.gif)

##### 关键的常量和属性:

```swift
// 该结构体定义了 standardCell 和 featuredCell 的高度.
struct UltravisualLayoutConstants {
    struct Cell {
        static let standardHeight: CGFloat = 100
        static let featuredHeight: CGFloat = 280
    }
}
```

```swift
// standardCell 过渡到 featuredCell 的拖动距离.
let dragOffset: CGFloat = UltravisualLayoutConstants.Cell.featuredHeight -
                          UltravisualLayoutConstants.Cell.standardHeight
```

```swift
// 当前 featuredCell 的索引,即 dragOffset 的整数倍.
// 用 max(_:_:) 限制向上拖动时 yOffset 为负数的情况.
private var featuredItemIndex: Int {
    return max(0, Int(yOffset / dragOffset))
}
```

```swift
// standardCell 过渡到 featuredCell 的百分比,同样用 max(_:_:) 限制 yOffset 为负数的情况.
private var nextItemPercentageOffset: CGFloat {
    return max(0, modf(yOffset / dragOffset).1)
}
```

##### 布局计算部分:

```swift
override func prepareLayout() {

    let width             = self.width // collectionView 宽度, height 则为高度.
    let featuredItemIndex = self.featuredItemIndex
    let standardHeight    = UltravisualLayoutConstants.Cell.standardHeight
    let featuredHeight    = UltravisualLayoutConstants.Cell.featuredHeight

    /* Int(ceil( (height - featuredHeight) / standardHeight )) 为开始拖动时当前屏幕显示的
    standardCell 的数量.由于拖动中 featuredItemIndex 不会增长,直到一个 standardCell
    完全过渡到 featuredCell .所以需要 +1 将新滚入屏幕的 standardCell 算进去.向下拖动时, 
    featuredItemIndex 会立即 -1 ,这样和先前向上拖动时的索引区间是一样的,不会多计算一个. */
    let endIndex = min(
        Int(ceil( (height - featuredHeight) / standardHeight )) + 1 + featuredItemIndex,
        numberOfItems - 1
    )

    var y: CGFloat = 0

    cache = (featuredItemIndex...endIndex).map {

        let indexPath  = NSIndexPath(forItem: $0, inSection: 0)
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)

        let height: CGFloat

        if indexPath.item == featuredItemIndex {

            // 只要还是 featuredCell 就令高度保持为 featuredCellHeight .
            height = featuredHeight

            // 每拖动一个 dragOffset ,下面的 standardCell 都上升一格.
            y = self.yOffset - standardHeight * self.nextItemPercentageOffset

        } else if indexPath.item == featuredItemIndex + 1 {

            // 每次拖动距离达到 dragOffset , 一个 standardCell 高度增长到 featuredHeight.
            height = standardHeight + self.dragOffset * self.nextItemPercentageOffset

            /* 先求得作为 standardCell 时底边 y 坐标,再减去此时实际高度作为实时 y 坐标.过渡时,
            底边 y 坐标不会额外改变,从而让后面的 standardCell 都能正常移动. */
            y = (y + standardHeight) - height

        } else {
        
            height = standardHeight
        }

        attributes.zIndex = $0
        attributes.frame  = CGRect(x: 0, y: y, width: width, height: height)

        y += height // 更新 y 坐标.

        return attributes
    }
}
```

```swift
// 至少要能拖动 numberOfItems 个 dragOffset .
// 最后一个 featuredCell 显示在顶部时需凑足一页的范围,所以加上 height - dragOffset .
override func collectionViewContentSize() -> CGSize {
    let contentHeight = (CGFloat(numberOfItems) * dragOffset) + (height - dragOffset)
    return CGSize(width: width, height: contentHeight)
}
```

```swift
// 自动分页.
// 每拖动一个 dragOffset 对应一个 standardCell => featuredCell ,四舍五入求得整数个 dragOffset . 
override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint,
    withScrollingVelocity velocity: CGPoint) -> CGPoint {
    return CGPoint(x: 0, y: round(proposedContentOffset.y / dragOffset) * dragOffset)
}
```

##### 在自定义的`UICollectionViewCell`子类中做些处理:

```swift
override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {

    let standardHeight = UltravisualLayoutConstants.Cell.standardHeight
    let featuredHeight = UltravisualLayoutConstants.Cell.featuredHeight

    // 蒙版透明度.
    let minAlpha: CGFloat = 0.3
    let maxAlpha: CGFloat = 0.75

    // cell 高度由 standardHeight => featuredHeight 时, delta 范围由 0 => 1 .
    let delta = 1 - (featuredHeight - bounds.height) / (featuredHeight - standardHeight)

    // alpha 由 0.75 => 0.3 .
    imageCoverView.alpha = maxAlpha - delta * (maxAlpha - minAlpha)

    // alpha 由 0 => 1 .
    timeAndRoomLabel.alpha = delta
    speakerLabel.alpha     = delta

    // 文本标签 scale 由 0.5 => 1 ,即 standardCell 的缩小显示, featuredCell 的放大到正常显示.
    let scale = max(0.5, delta)
    titleLabel.transform = CGAffineTransformMakeScale(scale, scale)
}
```
