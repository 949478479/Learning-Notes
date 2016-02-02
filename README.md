# NSProgress 简单使用

苹果在 `iOS 7` 引入了 `NSProgress`，目标是建立一个标准的机制来报告长时间运行的任务的进度。网上搜了下，在 `CocoaChina` 找到一篇翻译自老外博客的中文资料 [NSProgress](http://www.cocoachina.com/industry/20140522/8518.html)。参考文档并结合苹果的示例代码 `PhotoProgress: Using NSProgress`，勉强算是理解了这个类的用法，自己写了个更为简洁直接的 `demo`，并在这里做些总结记录。

如前所述，`NSProgress` 是用来报告任务进度的，这主要体现在如下三个属性上：

```swift
var totalUnitCount: Int64 // 任务总数
var completedUnitCount: Int64 // 任务完成数
var fractionCompleted: Double { get } // 任务进度，可以简单理解为 completedUnitCount/totalUnitCount
```

实际使用中，可以通过 `KVO` 来监听 `fractionCompleted` 属性，实时获取任务进度。下面举个简单的例子：

```swift
class Foo {
	private let queue = dispatch_queue_create("com.cjyh.NSProgressDemo",
	    DISPATCH_QUEUE_SERIAL)
	    
	func asyncDoSomeThing() {
		let totalUnitCount: Int64 = 666
		let progress = NSProgress(totalUnitCount: totalUnitCount)
		dispatch_async(queue) {
			for i in 0..<totalUnitCount {
				progress.completedUnitCount = i + 1
			}
		}
	}
}
```

想象一下上面的代码片段是某个异步执行的长时任务，指定任务总量为 `666`，每次循环 `completedUnitCount` 都会增加，那么 `completedUnitCount/totalUnitCount` 的比值也会不断增加，观察者就可以通过 `fractionCompleted` 属性的变化来获悉任务进度。

可以看到 `Foo` 并未将 `NSProgress` 对象暴露出来，那该如何注册 `KVO` 呢？这就是 `NSProgress` 的神奇之处了，若要监听 `Foo` 执行该方法的实时进度，可以像如下这样：

```swift
// 观察者创建一个 NSProgress 对象，这里指定任务数量为 1
let progress = NSProgress(totalUnitCount: 1)
// 观察者监听自己创建的 NSProgress 对象的进度
progress.addObserver(self, forKeyPath: "fractionCompleted", options: [], 
    context: &contextForKVO)
// 在 becomeCurrentWithPendingUnitCount(_:) 和 resignCurrent() 调用之间让 Foo 执行任务
progress.becomeCurrentWithPendingUnitCount(1)
Foo().asyncDoSomeThing()
progress.resignCurrent()
```

按照如上方式，观察者就可以通过 `KVO` 监听到 `Foo` 对象执行 `asyncDoSomeThing()` 方法时的任务进度了。下面解释下原因，回忆下 `Foo` 是如何创建 `NSProgress` 的：

```swift
let progress = NSProgress(totalUnitCount: 666)
```

这相当于如下代码：

```swift
let progress = NSProgress(parent: NSProgress.currentProgress(), userInfo: nil)
progress.totalUnitCount = 666
```

关键在于 `NSProgress.currentProgress()`，这会获取到当前线程调用 `becomeCurrentWithPendingUnitCount(_:)` 方法的 `NSProgress` 对象。再看下观察者是如何调用 `Foo` 的 `asyncDoSomeThing()` 方法的：

```swift
progress.becomeCurrentWithPendingUnitCount(1)
Foo().asyncDoSomeThing()
progress.resignCurrent() 
// 注意 becomeCurrentWithPendingUnitCount(_:) 和 resignCurrent() 要配对调用
```

这意味着，观察者自己创建的 `NSProgress` 对象会成为 `Foo` 的 `NSProgress` 对象的父 `NSProgress`。`NSProgress` 的强大之处在于，相互间可以形成父子关系，父任务的进度取决于子任务的进度。可以看到，观察者创建 `NSProgress` 对象时指定了任务数量为 `1`，调用 `becomeCurrentWithPendingUnitCount(_:)` 方法时也指定的 `1`，二者相同：

```swift
let progress = NSProgress(totalUnitCount: 1)
progress.becomeCurrentWithPendingUnitCount(1)
```

这意味着，子任务占父任务的全部比重，子任务完成时，父任务也全部完成。根据上面的例子，`Foo` 的 `asyncDoSomeThing()` 方法完成时，观察者的 `progress.completedUnitCount` 会由 `0` 变为 `1`。换言之，`becomeCurrentWithPendingUnitCount(_:)` 指定的值决定了对应子任务完成时，父任务的 `completedUnitCount` 会增加多少。

需要注意的时，在没有子任务时，`fractionCompleted` 可以简单地理解为 `completedUnitCount/totalUnitCount`，拥有子任务时，`fractionCompleted` 的值还取决于子任务的进度。在上述例子中，每次循环 `progress.completedUnitCount` 都会递增，因此父任务的 `fractionCompleted` 属性会平滑变化，而不是像 `completedUnitCount` 一样由 `0` 直接跳至 `1`。

当存在多个子任务时，可以分配各个子任务所占比重。例如，任务是先下载图片，然后进行滤镜处理。总任务由两个子任务组成，下载比较耗时，可以占八成，滤镜占剩余两成：

```swift
let progress = NSProgress(totalUnitCount: 10)
progress.becomeCurrentWithPendingUnitCount(8)
// 下载图片。。。
progress.resignCurrent()
progress.becomeCurrentWithPendingUnitCount(2)
// 滤镜处理。。。
progress.resignCurrent()
```

在下载完成后，总任务进度为 `8/10`，滤镜处理完成后，总任务进度为 `10/10`，即全部完成。若上面的任务总数设置为 `12`，那么子任务完成时，父任务的 `completedUnitCount` 为 `10`，总任务进度为 `10/12`，父任务还可以自己搞点什么事情，完成后手动将 `completedUnitCount` 加到 `12`。

此外，类似滤镜处理这种任务，无法确定任务的实时进度，可以像如下方式处理，其效果就是下载完成后进入滤镜处理阶段后，任务进度不再变化，而在滤镜任务完成后直接跳至完成：

```swift
// 指定为负数，NSProgress 的 indeterminate 属性会为 true，表示该任务进度无法确定
let progress = NSProgress(totalUnitCount: -1)
// 滤镜处理
// 完成后将 totalUnitCount 和 completedUnitCount 设置为相同的数，从而比值为 1
progress.totalUnitCount = 1
progress.completedUnitCount = 1
```

可以看到，使用 `NSProgress` 来报告进度耦合度很低，而添加对 `NSProgress` 的支持也并不复杂，当任务支持 `NSProgress` 时，就可以非常方便地观察多个子任务的进度，并汇总到总任务进度中呈现给用户。事实上，`NSProgress` 还支持暂停、恢复、取消的功能，并可以设置相应的闭包来处理这些事件。当对父任务执行这些操作时，子任务相应的闭包就会被调用，从而进行相应的处理。
