## Swift Interview Questions and Answers

总结自`RayWenderlich`教程团队推出的这篇教程 [Swift Interview Questions and Answers](http://www.raywenderlich.com/110982/swift-interview-questions-answers).

该篇教程讲解了一些`Swift`的面试题,分为两部分:

- 笔试问题
- 面试问题 

每个部分又被分为三个层次:

- 初级
- 中级
- 高级

## 笔试问题

### 初级

#### 问题 #1 -- Swift 1.0 或更高版本

下面的 for 循环有更好的写法吗?

```swift
for var i = 0; i < 5; i++ {
    print("Hello!")
}
```

##### 解决方案:

```swift
for _ in 0...4 {
    print("Hello!")
}
```

`Swift`提供了`...`和`..<`两个操作符.

`...`表示闭区间范围,例如`0...4`表示从0到4的整数范围.

而`..<`表示前闭后开的区间范围,例如`0..<5`表示的是从0到4的整数范围,不包括5.

#### 问题 #2 -- Swift 1.0 或更高版本 

分析下面代码:

```swift
struct Tutorial {
    var difficulty: Int = 1
}
 
var tutorial1 = Tutorial()
var tutorial2 = tutorial1
tutorial2.difficulty = 2
```

最终`tutorial1.difficulty`和`tutorial2.difficulty`的值各是什么?如果`Tutorial`是`class`类型呢?

##### 解决方案:

`tutorial1.difficulty`是 1 ,而`tutorial2.difficulty`是 2.

`Swift`中,`struct`是值类型,传递的是自身值的拷贝,而不是像`class`这种引用类型一样传递自身的引用.

下面的代码创建了`tutorial1`的副本赋值给`tutorial2`:

```swift
var tutorial2 = tutorial1
```

在这之后,对`tutorial2`的任何操作都不会影响`tutorial1`.

而如果`Tutorial`是`class`类型,`tutorial1.difficulty`和`tutorial2.difficulty`将都会是 2.

`class`类型在`Swift`中是引用类型,操作`tutorial1`即是操作`tutorial2`,反之亦然.

#### 问题 #3 -- Swift 1.0 或更高版本

`view1`声明为`var`,`view2`声明为`let`.这里有什么区别呢?最后一行能通过编译吗?

```swift
import UIKit
 
var view1 = UIView()
view1.alpha = 0.5
 
let view2 = UIView()
view2.alpha = 0.5 // 这一行能通过编译吗?
```

##### 解决方案:

`view1`是一个变量,可以被重新分配一个新的`UIView`实例.

而`let`是常量,只允许被赋值一次,所以下面的代码不能通过编译:

```swift
view2 = view1 // 错误, view2 不可变.
```

然而,`UIView`是`class`类型,是引用语义,所以可以改变`view2`的属性,也就是最后一行可以通过编译:

```swift
let view2 = UIView()
view2.alpha = 0.5 // 完全没问题~
```

#### 问题 #4 -- Swift 1.0 或更高版本

这段代码按照字母顺序排序数组,这看上去有些啰嗦,试着简化写法.

```swift
let animals = ["fish", "cat", "chicken", "dog"]
let sortedAnimals = animals.sorted { (one: String, two: String) -> Bool in
    return one < two
}
```

##### 解决方案:

首先可以简化闭包的参数.由于类型推断,可以省略闭包的参数类型:

```swift
let sortedAnimals = animals.sorted { (one, two) -> Bool in
    return one < two 
}
```

闭包的返回类型也可以推断出来,也可以省略:

```swift
let sortedAnimals = animals.sorted { (one, two) in 
    return one < two 
}
```

使用`$0`,`$1`,`$2`这种形式可以分别表示第一个,第二个和第三个参数,以此类推.因此参数和`in`关键字也可以省略:

```swift
let sortedAnimals = animals.sorted { return $0 < $1 }
```

只有一句表达式的闭包可以省略`return`关键字,表达式的返回值会被推断为闭包的返回值:

```swift
let sortedAnimals = animals.sorted { $0 < $1 }
```

最后,对于`String`类型,其实现了一个比较函数,声明如下:

```swift
func <(lhs: String, rhs: String) -> Bool
```

`<`表示的函数完全符合上述闭包的要求,因此可以直接传入作为`sorted(_:)`的参数:

```swift
let sortedAnimals = animals.sorted(<)
```

#### 问题 #5 -- Swift 1.0 或更高版本

下面这段代码创建了两个类, `Address`和`Person`,`Person`会创建两个实例表示`Ray`和`Brian`这俩人。

```swift
class Address {
    var fullAddress: String
    var city: String
 
    init(fullAddress: String, city: String) {
        self.fullAddress = fullAddress
        self.city = city
    }
}
 
class Person {
    var name: String
    var address: Address
 
    init(name: String, address: Address) {
        self.name = name
        self.address = address
    }
}
 
var headquarters = Address(fullAddress: "123 Tutorial Street", city: "Appletown")
var ray = Person(name: "Ray", address: headquarters)
var brian = Person(name: "Brian", address: headquarters)
```

假设`Brian`搬到街对面的新房子去了,所以需要更新他的地址:

```swift
brian.address.fullAddress = "148 Tutorial Street"
```

这句代码会导致什么问题吗?

##### 解决方案:

`ray`也搬到了新房子!

`Address`是一个`class`,是引用语义,因此从上述代码来看,访问两个人的`address`属性都是访问同一`Address`实例,即`headquarters`.

更好的做法是将`Address`定义为`struct`类型,值传递语义在这种情况下更科学.

### 中级

#### 问题 #1 -- Swift 2.0 或更高版本

思考下面代码:

```swift
var optional1: String? = nil
var optional2: String? = .None
```

这里的`nil`和`.None`有什么区别吗?`optional1`和`optional2`有什么不同吗?

##### 解决方案:

没有区别.`Optional.None`是初始化一个可选类型的完整写法,而`nil`只是一种语法糖.

实际上,下面这个语句结果为`true`:

```swift
nil == .None // 在 Swift 1.x 版本这无法通过编译,需要写成 Optional<Int>.None 这种.
```

记住,`Optional`实际上是个枚举:

```swift
enum Optional<T> {
    case None
    case Some(T)
}
```

#### 问题 #2 -- Swift 1.0 或更高版本

下面代码分别用`class`和`struct`表示温度计模型:

```swift
public class ThermometerClass {
    private(set) var temperature: Double = 0.0
    public func registerTemperature(temperature: Double) {
        self.temperature = temperature
    }
}
 
let thermometerClass = ThermometerClass()
thermometerClass.registerTemperature(56.0)
 
public struct ThermometerStruct {
    private(set) var temperature: Double = 0.0
    public mutating func registerTemperature(temperature: Double) {
        self.temperature = temperature
    }
}
 
let thermometerStruct = ThermometerStruct()
thermometerStruct.registerTemperature(56.0)
```

这段代码会编译失败.错误在哪里呢?为什么?

解决方案:

错误出在最后一行.

`ThermometerStruct`正确地将会改变内部变量`temperature`的方法`registerTemperature(_:)`用`mutating`关键字声明.但其实例`thermometerStruct`声明为`let`,是不可变的,所以不能调用会改变内部状态的`registerTemperature(_:)`方法.

对于`struct`,改变内部状态的方法必须标记为`mutating`,不可变实例不能调用这种方法.

#### 问题 #3 -- Swift 1.0 或更高版本

下面这段代码会打印出什么?为什么?

```swift
var thing = "cars"
 
let closure = { [thing] in
    print("I love \(thing)")
}
 
thing = "airplanes"
 
closure()
```

解决方案:

会打印`I love cars`.

由于创建闭包时声明了捕获列表,闭包将创建变量`thing`的拷贝,所以之后对闭包外的变量`thing`重新赋值,并不会影响闭包内部的`thing`.

如果省略捕获列表,闭包将使用变量`thing`的引用而不是拷贝来的副本.这种情况下,改变闭包外部的变量`thing`会影响闭包内部的变量`thing`.

```swift
var thing = "cars"
 
let closure = {    
    print("I love \(thing)")
}
 
thing = "airplanes"
 
closure() // 打印 "I love airplanes"
```

#### 问题 #4 -- Swift 2.0 或更高版本

暂略...系统太旧用不了 Xcode 7 beta ...等出正式版了不行就升级系统- -

#### 问题 #5 -- Swift 2.0 或更高版本

暂略...
