# ColorIntroduction

## 添加 CAGradientLayer

首先,创建一个`CAGradientLayer`实例,可以在`viewDidAppear()`方法中创建:

```swift
let gradient        = CAGradientLayer()
gradient.frame      = view.bounds
gradient.startPoint = CGPoint(x: 0, y: 0)
gradient.endPoint   = CGPoint(x: 1, y: 1)
```
