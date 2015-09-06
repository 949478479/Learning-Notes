# Pinterest

学习自`RayWenderlich`的教程 
[UICollectionView Custom Layout Tutorial: Pinterest]
(http://www.raywenderlich.com/107439/uicollectionview-custom-layout-tutorial-pinterest)

好像是他们开会的照片 (⊙_⊙).

![](https://github.com/949478479/Learning-Notes/blob/master/Pinterest-screenshot/QQ20150827-1%402x.png)

这里总结下一些收获理解:

初始项目里有这么个`UIImage`的扩展,应该是用绘制到上下文的方式预解压图片.

然而却是在主线程调用的,所以应该没啥意义吧.

```swift
extension UIImage {
    var decompressedImage: UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        drawAtPoint(CGPointZero)
        let decompressedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return decompressedImage
    }
}
```

`Photo`模型类有这么个计算文本高度的方法,这里注意下文档建议用`ceil`进行像素向上取整.

```swift
func heightForComment(font: UIFont, width: CGFloat) -> CGFloat {

    let rect = comment.boundingRectWithSize(CGSize(width: width, height: CGFloat.max),
        options: .UsesLineFragmentOrigin, 
        attributes: [NSFontAttributeName: font], 
        context: nil)

    return ceil(rect.height) 
}
```

`AVMakeRectWithAspectRatioInsideRect(_:_:)`函数用来算 fit 模式的图片矩形范围真的是很好用,省去手动计算了~

```swift
func collectionView(collectionView: UICollectionView,
    heightForPhotoAtIndexPath indexPath: NSIndexPath, 
    withWidth width: CGFloat) -> CGFloat {

    let aspectRatio  = photos[indexPath.item].image.size
    let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat.max)

    // 分别传入图片实际 size, 和期望显示的 rect.
    return AVMakeRectWithAspectRatioInsideRect(aspectRatio, boundingRect).height 
}
```

教程中讲解了子类化`UICollectionViewLayoutAttributes`,主要是为了拿到图片高度来更新约束.

```swift
class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {

    var photoHeight: CGFloat = 0

    // 继承 UICollectionViewLayoutAttributes 有两个硬性要求:
    // 1.覆盖 copyWithZone(_:) 方法,对增加的属性进行 copy.
    // 2.覆盖 isEqual(_:) 方法,在父类基础上加上对新增属性的判断.
    // 此外,布局类需要实现 layoutAttributesClass() 类方法, cell 需实现 applyLayoutAttributes(_:) 方法.
    override func copyWithZone(zone: NSZone) -> AnyObject {

        let copy = super.copyWithZone(zone) as! PinterestLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }

    override func isEqual(object: AnyObject?) -> Bool {

        if photoHeight == (object as? PinterestLayoutAttributes)?.photoHeight {
            return super.isEqual(object)
        }

        return false
    }
}

// 布局类中实现此方法返回自定义的子类.
override class func layoutAttributesClass() -> AnyClass {
    return PinterestLayoutAttributes.self
}

// UICollectionReusableView 子类(往往都是 UICollectionViewCell 子类)需实现此方法.
override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {

    // 作者指出需要调用超类实现使得 UICollectionViewLayoutAttributes的原有属性得以应用.
    // 文档没明确这点,试了下貌似不写也行 (⊙_⊙).
    super.applyLayoutAttributes(layoutAttributes) 

    imageViewHeightLayoutConstraint.constant = 
      (layoutAttributes as! PinterestLayoutAttributes).photoHeight
}
```
