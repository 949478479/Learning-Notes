# ColorIntroduction

学习自 [iOS Animations by Emails](http://www.ios-animations-by-emails.com/)
七月的教程 [Fun with Gradients and Masks](http://ios-animations-by-emails.com/posts/2015-july#tutorial).

这一期讲解了`CAGradientLayer`和`mask`的简单使用.最终将实现这样的效果:

![](https://github.com/949478479/Animations-Study/blob/master/ColorIntroduction-screenshot/final-preview.png)

下面来一步步实现该效果.在开始前,可以先下载初始项目
[ColorIntroduction-Starter.zip]
(http://www.ios-animations-by-emails.com/assets/2015-july/ColorIntroduction-Starter.zip).

- *Main.storyboard* 包含一个视图控制器,它显示了一个全屏的文本标签。 
- *ViewController.swift* 文件顶部,有一个文本标签的 *@IBOutlet*, 叫做`label`.
- 还有个很长的字符串属性叫做`story`,讲述了一段关于一只青蛙的童话...

## 添加 CAGradientLayer

首先,创建一个`CAGradientLayer`实例,可以在`viewDidAppear()`方法中调用此方法:

```swift
private func addGradientLayer() {

    // 创建一个梯度图层.
    let gradient = CAGradientLayer()

    // 使其和控制器根视图一样大小.
    gradient.frame = view.bounds

    // 设置其梯度方向为 左上角 => 右下角.默认则是 顶边中点 => 底边中点.
    gradient.startPoint = CGPoint(x: 0, y: 0)
    gradient.endPoint   = CGPoint(x: 1, y: 1)
}
```

梯度方向效果如图:

![](https://github.com/949478479/Animations-Study/blob/master/ColorIntroduction-screenshot/gradient.png)

接下来,在`addGradientLayer()`方法中,设置梯度图层的渐变颜色并将其显示出来:

```swift
// 设置梯度图层的渐变颜色.
// 数组元素只有两个则分别表示起点和终点的颜色,当然也可以多来几个.
// 另外不指定 locations 数组的话,默认是均匀渐变的.
// 注意这里要求是 CGColor 类型.
gradient.colors = [
    UIColor(red: 0,     green: 1,    blue: 0.752, alpha: 1).CGColor,
    UIColor(red: 0.949, green: 0.03, blue: 0.913, alpha: 1).CGColor
]

// 将梯度图层添加到控制器根视图的图层上显示出来.
view.layer.addSublayer(gradient)
```

运行后效果如图:

![](https://github.com/949478479/Animations-Study/blob/master/ColorIntroduction-screenshot/sim-gradient.png)

最后依旧在`addGradientLayer()`方法中,为梯度图层添加`mask`:

```swift
// 将文本标签的图层用作梯度图层的 mask. 
// 由于 mask 的特点,只有文本标签不是完全透明的部分(也就是文字)才会露出背后的梯度图层.
gradient.mask = label.layer
```

## 文字输入动画

添加一个新方法,用于往文本标签上拼接字符,呈现文字输入的动画效果:

```swift
private func punchTextAtIndex(index: String.Index) {

    // 往文本标签上拼接一个字符.
    label.text?.append(story[index])

    // 拼接下一个字符,直到当前字符已经是最后一个字符.
    // 注意 endIndex 表示末尾索引的下一个索引, endIndex.predecessor() 才是末尾索引.
    if index < story.endIndex.predecessor() {
        // 每隔 0.04s 拼接下一个字符. 
        // delay(seconds:_:) 函数是 dispatch_after(_:_:_:) 函数的封装.
        delay(seconds: 0.04) {
            self.punchTextAtIndex(index.successor())
        }
    } else {
        // 故事讲完了...
    }
}
```

然后在调用`addGradientLayer()`方法后调用此方法:

```swift
// 去掉 storyboard 中文本标签的内容 "Text", 或者直接去 storyboard 中删掉,就不用写这句了.
label.text = ""
// 调用此方法往文本标签上拼接字符.
punchTextAtIndex(story.startIndex)
```

运行后效果如图:

![](https://github.com/949478479/Animations-Study/blob/master/ColorIntroduction-screenshot/text-animated.gif)

## 添加额外的动画

接下来在故事讲完时添加一个 button-like 动画来提示用户.

```swift
private func addButtonRing() {

    // 圆圈直径.
    let diameter: CGFloat = 60

    // 图层是个 CAShapeLayer 图层.
    let button = CAShapeLayer()

    // 设置图层路径为圆形路径.
    button.path = UIBezierPath(ovalInRect: 
        CGRect(x: 0, y: 0, width: diameter, height: diameter)).CGPath

    // 将图层置于文本标签底部往上 20 点且水平居中.
    // 由于圆形路径以该 position 为原点,所以 x 坐标需减去半径, y 坐标需减去直径方符合需求.
    button.position = CGPoint(x: label.bounds.midX - diameter / 2, 
                              y: label.bounds.maxY - diameter - 20)

    // 设置描边颜色,由于 mask 的特点,什么颜色不重要,只要不是完全透明的就行.
    button.strokeColor = UIColor.blackColor().CGColor

    // 清除填充颜色,否则由于 mask 的特点,背后的梯度图层会露出来.
    button.fillColor = nil

    // 为了好看,调整下透明度.
    button.opacity = 0.5

    // 将图层添加到文本标签上显示出来.
    label.layer.addSublayer(button)
}
```

然后在`punchTextAtIndex(_:)`方法中,故事讲完时,添加三个圆圈:

```swift
delay(seconds: 0.5, addButtonRing)
delay(seconds: 1.0, addButtonRing)
delay(seconds: 1.5, addButtonRing)
```

效果如图:

![](https://github.com/949478479/Animations-Study/blob/master/ColorIntroduction-screenshot/rings-same-position.png)

因为三个圆圈重合了,所以只能看到一个.接下来在`addButtonRing()`方法末尾,为圆圈添加图层动画:

```swift
let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
scaleAnimation.toValue = 0.67
scaleAnimation.duration = 2
scaleAnimation.repeatCount = Float.infinity // 无限重复次数.
scaleAnimation.autoreverses = true // 自动复原.
button.addAnimation(scaleAnimation, forKey: nil)
```

这样圆圈们就会动了:

![](https://github.com/949478479/Animations-Study/blob/master/ColorIntroduction-screenshot/rings-animated.gif)

最后为了符合故事情节,添加一只青蛙上去(青蛙图片在 *Images.xcassets* 里),可以在`addGradientLayer()`方法后调用:

```swift
private func addFrogImage() {
    let frogImageView = UIImageView(image: UIImage(named: "frog"))
    frogImageView.center.x = label.bounds.midX
    label.addSubview(frogImageView)
}
```

运行一下,最终的效果是这样的:

![](https://github.com/949478479/Animations-Study/blob/master/ColorIntroduction-screenshot/final-project.png)
