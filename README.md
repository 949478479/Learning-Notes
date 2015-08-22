# ColorIntroduction

学习自 [iOS Animations by Emails](http://www.ios-animations-by-emails.com/)
七月的教程 [Fun with Gradients and Masks](http://ios-animations-by-emails.com/posts/2015-july#tutorial).

这一期讲解了`CAGradientLayer`和`mask`的简单使用.最终将实现这么个效果:

![](https://github.com/949478479/ColorIntroduction/blob/image/final-preview.png)

下面来一步步实现该效果.在开始前,可以先下载初始项目
[ColorIntroduction-Starter.zip]
(http://www.ios-animations-by-emails.com/assets/2015-july/ColorIntroduction-Starter.zip).

## 添加 CAGradientLayer

首先,创建一个`CAGradientLayer`实例,可以在`viewDidAppear()`方法中创建:

```swift
// 创建一个梯度图层.
let gradient = CAGradientLayer()

// 使其和控制器根视图一样大小.
gradient.frame = view.bounds

// 设置其梯度方向为 左上角 => 右下角.默认则是 顶边中点 => 底边中点.
gradient.startPoint = CGPoint(x: 0, y: 0)
gradient.endPoint   = CGPoint(x: 1, y: 1)
```

梯度方向效果如图:

![](https://github.com/949478479/ColorIntroduction/blob/image/gradient.png)

接下来,设置梯度图层的渐变颜色并将其显示出来:

```swift
// 设置梯度图层的渐变颜色.数组元素分别表示起点和终点的颜色.
gradient.colors = [
    UIColor(red: 0, green: 1, blue: 0.752, alpha: 1).CGColor,
    UIColor(red: 0.949, green: 0.03, blue: 0.913, alpha: 1).CGColor
]

// 将梯度图层添加到控制器根视图的图层上显示出来.
view.layer.addSublayer(gradient)
```

运行后效果如图:

![](https://github.com/949478479/ColorIntroduction/blob/image/sim-gradient.png)
