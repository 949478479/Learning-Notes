# 如何用 Swift 创建一个复杂的 loading 动画

学习自`RayWenderlich`出品的教程 [How to Create a Complex Loading Animation in Swift]
(http://www.raywenderlich.com/102590/how-to-create-a-complex-loading-animation-in-swift)

附上`CocoaChina`翻译版[【实例教程】你会用swift创建复杂的加载动画吗](www.cocoachina.com/swift/20150906/13327.html)

![](https://github.com/949478479/Learning-Notes/blob/master/SBLoader-screenshot/SBLoader.gif)

基本上就是各种形状的`CAShapeLayer`配合`CABasicAnimation`和`CAKeyframeAnimation`,麻烦在绘制`path`.

#### 小球的弹性动画

改变矩形宽高来压缩小球成椭圆,利用`CAKeyframeAnimation`在不同压缩状态的`path`间做动画.

```swift
let wobbleAnimation = CAKeyframeAnimation(keyPath: "path")
wobbleAnimation.duration = duration
wobbleAnimation.values = [
    largePath,
    squishVerticalPath,
    squishHorizontalPath,
    squishVerticalPath,
    largePath
]
addAnimation(wobbleAnimation, forKey: nil)
```
#### 伸出尖角动画

先画个在圆内的小三角形,然后调整各顶点位置伸出各个角.

```swift
let animation = CAKeyframeAnimation(keyPath: "path")
animation.duration = duration
animation.values = [
    trianglePathSmall,
    trianglePathLeftExtension,
    trianglePathRightExtension,
    trianglePathTopExtension
]
addAnimation(animation, forKey: nil)
path = trianglePathTopExtension
```
        
#### 描线动画

对`strokeEnd`属性做动画即可:

```swift
let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
strokeAnimation.fromValue = 0
strokeAnimation.toValue   = 1
strokeAnimation.duration  = duration
addAnimation(strokeAnimation, forKey: nil)
```

#### 灌水动画

用`addCurveToPoint(_:controlPoint1:controlPoint2:)`方法画出波浪线,再拼接一个矩形.然后不同路径间改变波浪起伏和矩形高度,利用`CAKeyframeAnimation`进行动画.

```swift
let waveAnimation = CAKeyframeAnimation(keyPath: "path")
waveAnimation.duration = duration
waveAnimation.values = [
    wavePathPre,
    wavePathStarting,
    wavePathLow,
    wavePathMid,
    wavePathHigh,
    wavePathComplete
]
addAnimation(waveAnimation, forKey: nil)
path = wavePathComplete
```

#### Apple logo 动画

把`LoaderView`动画放大到屏幕大小,结束后添加一个等大的`UILabel`,字体设置的很大,让`UILabel`由缩小状态恢复到正常大小,配合弹性动画即可.
