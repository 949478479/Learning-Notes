# ColorIntroduction

学习自 [iOS Animations by Emails](http://www.ios-animations-by-emails.com/)
七月的教程 [Fun with Gradients and Masks](http://ios-animations-by-emails.com/posts/2015-july#tutorial).

这一期讲解了`CAGradientLayer`和`mask`的简单使用.最终将实现这么个效果:

![](https://github.com/949478479/ColorIntroduction/blob/image/final-preview.png)

下面来看一看具体过程:

## 添加 CAGradientLayer

首先,创建一个`CAGradientLayer`实例,可以在`viewDidAppear()`方法中创建:

```swift
let gradient        = CAGradientLayer()
gradient.frame      = view.bounds
gradient.startPoint = CGPoint(x: 0, y: 0)
gradient.endPoint   = CGPoint(x: 1, y: 1)
```

上面代码创建了一个全屏尺寸的`CAGradientLayer`实例,并设置了梯度方向为左上角到右下角.如图:

![](https://github.com/949478479/ColorIntroduction/blob/image/gradient.png)
