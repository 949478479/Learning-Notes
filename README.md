# WritingAnimation

![](Screenshot/demo.gif)

学习来自这篇博客 [Animating the Drawing of a CGPath With CAShapeLayer](http://oleb.net/blog/2010/12/animating-drawing-of-cgpath-with-cashapelayer/)，思路是根据文字生成 `CGPath`，然后设置为 `CAShapeLayer` 的 `path`，再利用核心动画不断改变 `CAShapeLayer` 的 `strokeEnd`：

```objective-c
CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
pathAnimation.duration = 10.0;
pathAnimation.fromValue = @0;
pathAnimation.toValue = @1;
[self.pathLayer addAnimation:pathAnimation forKey:nil];
```

```objective-c
CAKeyframeAnimation *penAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
penAnimation.duration = 10.0;
penAnimation.path = self.pathLayer.path;
penAnimation.calculationMode = kCAAnimationPaced;
[self.penLayer addAnimation:penAnimation forKey:@"penAnimation"];
```