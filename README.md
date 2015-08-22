# ColorIntroduction

学习自 [iOS Animations by Emails](http://www.ios-animations-by-emails.com/)
七月的教程 [Fun with Gradients and Masks](http://ios-animations-by-emails.com/posts/2015-july#tutorial).

这一期讲解了`CAGradientLayer`和`mask`的简单使用.最终将实现这么个效果:

![](https://github.com/949478479/ColorIntroduction/blob/image/final-preview.png)

下面来一步步实现该效果.在开始前,可以先下载初始项目
[ColorIntroduction-Starter.zip]
(http://www.ios-animations-by-emails.com/assets/2015-july/ColorIntroduction-Starter.zip).

- *Main.storyboard* 包含一个视图控制器,它显示了一个全屏的文本标签。 
- *ViewController.swift* 文件顶部,有一个文本标签的 *outlet*,叫做`label`.
- 还有个很长的字符串属性叫做`story`,讲述了一段格林童话...

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
// 设置梯度图层的渐变颜色.数组元素分别表示起点和终点的颜色.注意这里要求是`CGColor`.
gradient.colors = [
    UIColor(red: 0, green: 1, blue: 0.752, alpha: 1).CGColor,
    UIColor(red: 0.949, green: 0.03, blue: 0.913, alpha: 1).CGColor
]

// 将梯度图层添加到控制器根视图的图层上显示出来.
view.layer.addSublayer(gradient)
```

运行后效果如图:

![](https://github.com/949478479/ColorIntroduction/blob/image/sim-gradient.png)

接下来为梯度图层添加`mask`:

```swift
// 将文本标签的图层用作梯度图层的 mask. 
// 由于 mask 的特点,只有文本标签不透明的部分(也就是文字)才会露出背后的梯度图层.
gradient.mask = label.layer
```
