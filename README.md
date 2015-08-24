# AnimationsWithCAReplicatorLayer

学习自 [iOS Animations by Emails](http://www.ios-animations-by-emails.com/)
三月的教程 [Creating animations with CAReplicatorLayer]
(http://www.ios-animations-by-emails.com/posts/2015-march#tutorial).

这一期讲解了`CAReplicatorLayer`的简单使用.最终将实现下面三个动画效果:

![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/music-app-playing.gif)
![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/activity-final.gif)
![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/rw-logo.gif)

## 基本的复制器动画

`CAReplicatorLayer`是一个容器层,它会复制你添加到其中的内容.如果你添加一个图层上去,它可以将其复制并显示出来.

你可以指定复制出的一系列图层间的几何偏移量,颜色和透明度变化量等等.这使你能创建一些酷炫的效果和动画.

首先来实现下面这个效果:

![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/music-app-playing.gif)

这个动画有一个上下移动的红色小条,另外两个小条是它的两个副本,它们三个之间存在位置和时间的偏移.

创建一个新的 Xcode 项目并选择单一视图模板(Single View Application). 来到 **ViewController.swift** 文件,添加一个新方法:

```swift
private func animation1() {
  // ...
}
```

在该方法中,创建并添加`CAReplicatorLayer`:

```swift
let replicator             = CAReplicatorLayer()
replicator.position        = view.center
replicator.bounds.size     = CGSize(width: 60, height: 60)
replicator.backgroundColor = UIColor.lightGrayColor().CGColor

view.layer.addSublayer(replicator)
```

上面代码创建了一个`CAReplicatorLayer`并添加到控制器视图的图层上居中显示,为了调试,给它设置了灰色的背景色.

然后在`viewDidLoad()`方法中调用`animation1()`方法,运行一下,效果大概这样:

![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/gray-view.png)

接下来创建第一个红色小条,继续在该方法中添加以下代码:

```swift
let bar             = CALayer()
bar.cornerRadius    = 2
bar.bounds.size     = CGSize(width: 8, height: 40)
bar.position        = CGPoint(x: 10, y: 75)
bar.backgroundColor = UIColor.redColor().CGColor

replicator.addSublayer(bar)
```

上面代码创建了一个带圆角的红色小条,并添加为`CAReplicatorLayer`的子图层.运行效果如下:

![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/red-bar.png)

红色小条出现在灰色图层底部,因为接下来要为其添加动画让它向上动起来.继续在该方法中添加以下代码:

```swift
let move          = CABasicAnimation(keyPath: "position.y")
move.toValue      = bar.position.y - 35
move.duration     = 0.5
move.autoreverses = true
move.repeatCount  = Float.infinity

bar.addAnimation(move, forKey: nil)
```

上面这段代码只是简单地为红色小条添加了向上移动的动画并无限重复.

接下来将引入`CAReplicatorLayer`的特性.继续添加下面代码:

```swift
replicator.instanceCount = 3
```

`CAReplicatorLayer`会将其子图层,也就是红色小条复制两份,连同本体,最终一共会有三个红色小条.

如果现在运行程序,依旧看不到什么改变,因为三个小条重合在一起且动画是同步的.

添加下面代码,为小条间添加偏移量:

```swift
replicator.instanceTransform = CATransform3DMakeTranslation(20, 0, 0)
```

每个红色小条相对于上一个都会在水平方向上向右偏移 20 点距离.运行效果大致如下:

![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/3-red-bars.png)

三个红色小条整齐地上下运动着,所以还需要给小条的动画加点时间差,添加下面代码:

```swift
replicator.instanceDelay = 0.33
```

每个红色小条的动画开始时间相对于前一个会延迟 0.33 秒.

运行程序,可以看到三个小条可以正确地动画了.

最后,为了美观,去掉之前设置`CAReplicatorLayer`的背景色的代码,并添加以下代码:

```swift
replicator.masksToBounds = true
```

这样,红色小条就只有运动到原先的灰色方块内部才可见了.最终效果如下:

![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/red-bars-final.gif)

## 活动指示器动画

新建一个方法`animation2()`,首先,依旧创建并添加`CAReplicatorLayer`:

```swift
let replicator             = CAReplicatorLayer()
replicator.cornerRadius    = 10
replicator.position        = view.center
replicator.bounds.size     = CGSize(width: 200, height: 200)
replicator.backgroundColor = UIColor(white: 0, alpha: 0.75).CGColor

view.layer.addSublayer(replicator)
```

上面代码创建了一个带圆角的灰色大方块样子的`CAReplicatorLayer`,并添加到控制器视图的图层上居中显示.

接下来添加一个白色小方块图层:

```swift
let dot             = CALayer()
dot.borderWidth     = 1
dot.cornerRadius    = 2
dot.borderColor     = UIColor.whiteColor().CGColor
dot.position        = CGPoint(x: 100, y: 40)
dot.bounds.size     = CGSize(width: 14, height: 14)
dot.backgroundColor = UIColor(white: 0.8, alpha: 1).CGColor

replicator.addSublayer(dot)
```

为了好看,为小方块设置了圆角,边框等效果,然后添加为`CAReplicatorLayer`的子图层.

运行效果如下(记得在`viewDidLoad()`方法中调用`animation2()`方法):

![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/gray-rect.png)

接下来设置`CAReplicatorLayer`属性,总共显示 15 个小方块,每个小方块间偏移一定角度,均匀排布一圈:

```swift
let nrDots = 15
replicator.instanceCount     = nrDots
replicator.instanceTransform = CATransform3DMakeRotation(CGFloat(2 * M_PI) / CGFloat(nrDots), 0, 0, 1)
```

运行程序,效果如下:

![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/activity-1.png)

如果调整`nrDots`的值,效果可能会是这样,这样,以及这样:

![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/variations.png)

下面为小方块添加无限重复的缩小动画:

```swift
let duration: NSTimeInterval = 1.5

let shrink         = CABasicAnimation(keyPath: "transform.scale")
shrink.fromValue   = 1
shrink.toValue     = 0.1
shrink.duration    = duration
shrink.repeatCount = Float.infinity

dot.addAnimation(shrink, forKey: nil)
```

同样,为小方块间加上动画时间差:

```swift
replicator.instanceDelay = duration / Double(nrDots)
```

如果此时运行程序,会发现第一次动画开始前所有的小方块都是正常尺寸,非常难看.

为了修复这个问题,在创建小方块时加上这句代码,使小方块一开始就小到看不见:

```swift
dot.transform = CATransform3DMakeScale(0.01, 0.01, 0.01)
```

运行程序,最终效果如下:

![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/activity-final.gif)

## 跟随动画

一如既往,添加个新方法`animation3()`,并在`viewDidLoad()`方法中调用它.

首先在`animation3()`方法中定义个闭包,用于生成`RayWenderlich`网站 logo 的图案路径:

```swift
let rw = { () -> CGPath in

    var bezierPath = UIBezierPath()

    bezierPath.moveToPoint(CGPointMake(31.5, 71.5))
    bezierPath.addLineToPoint(CGPointMake(31.5, 23.5))
    bezierPath.addCurveToPoint(CGPointMake(58.5, 38.5),
        controlPoint1: CGPointMake(31.5, 23.5), controlPoint2: CGPointMake(62.46, 18.69))
    bezierPath.addCurveToPoint(CGPointMake(53.5, 45.5),
        controlPoint1: CGPointMake(57.5, 43.5), controlPoint2: CGPointMake(53.5, 45.5))
    bezierPath.addLineToPoint(CGPointMake(43.5, 48.5))
    bezierPath.addLineToPoint(CGPointMake(53.5, 66.5))
    bezierPath.addLineToPoint(CGPointMake(62.5, 51.5))
    bezierPath.addLineToPoint(CGPointMake(70.5, 66.5))
    bezierPath.addLineToPoint(CGPointMake(86.5, 23.5))
    bezierPath.addLineToPoint(CGPointMake(86.5, 78.5))
    bezierPath.addLineToPoint(CGPointMake(31.5, 78.5))
    bezierPath.addLineToPoint(CGPointMake(31.5, 71.5))

    bezierPath.closePath()

    bezierPath.applyTransform(CGAffineTransformMakeScale(3, 3)) // 放大点好看.

    return bezierPath.CGPath
}
```

接着还是先创建并添加`CAReplicatorLayer`,只不过这一次设置为全屏了:

```swift
let replicator = CAReplicatorLayer()
replicator.frame = view.bounds
replicator.backgroundColor = UIColor(white: 0, alpha: 0.75).CGColor

view.layer.addSublayer(replicator)
```

然后创建白色小方块图层,并设置圆角为边长一半,从而变成一个小圆:

```swift
let dot             = CALayer()
dot.cornerRadius    = 5
dot.borderWidth     = 1
dot.borderColor     = UIColor.whiteColor().CGColor
dot.bounds.size     = CGSize(width: 10, height: 10)
dot.backgroundColor = UIColor(white: 0.8, alpha: 1).CGColor

replicator.addSublayer(dot)
```

如果此时运行程序,会看到屏幕左上角有个很小的白色小圆.

接下来为小圆添加按照给定路径运动的帧动画:

```swift
let move         = CAKeyframeAnimation(keyPath: "position")
move.path        = rw()
move.duration    = 4
move.repeatCount = Float.infinity

dot.addAnimation(move, forKey: nil)
```

如果此时运行程序,只会看到一个白色小圆到处疯跑.因为还没有设置`CAReplicatorLayer`的图层数量和时间差:

```swift
replicator.instanceCount = 20
replicator.instanceDelay = 0.1
```

运行程序,效果已经很好了:

![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/rw-1.gif)

为了更像`RayWenderlich`网站的 logo, 添加下面代码修改小圆为绿色(当然也可以选择直接改动原始小圆的颜色):

```swift
replicator.instanceColor = UIColor.greenColor().CGColor
```

`CAReplicatorLayer`还有几个设置颜色偏移量的属性,例如`instanceGreenOffset`:

```swift
replicator.instanceGreenOffset = -0.03
```

这将导致每个小圆相对于上一个会减少 0.03 的绿色成分.最后动画看起来是这样的:

![](https://github.com/949478479/Animations-Study/blob/master/AnimationsWithCAReplicatorLayer-image/rw-logo.gif)
