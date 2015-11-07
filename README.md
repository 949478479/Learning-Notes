## Swift Interview Questions and Answers

总结自`RayWenderlich`教程团队推出的这篇教程 [Swift Interview Questions and Answers](http://www.raywenderlich.com/110982/swift-interview-questions-answers)。

该篇教程讲解了一些`Swift`的面试题，分为两部分：

- [笔试问题](#Written Questions)（[初级](#Written Beginners) [中级](#Written Intermediate) [高级](#Written Advanced)）

- [面试问题](#Verbal Questions)（[初级](#Verbal Beginners) [中级](#Verbal Intermediate) [高级](#Verbal Advanced)）

<a name="Written Questions"></a>
## 笔试问题

<a name="Written Beginners"></a>
### 初级

#### 问题 #1 -- Swift 1.0 或更高版本

下面的 for 循环有更好的写法吗？

```swift
for var i = 0; i < 5; i++ {
    print("Hello!")
}
```

##### 解决方案：

```swift
for _ in 0...4 {
    print("Hello!")
}
```

`Swift`提供了`...`和`..<`两个操作符。

`...`表示闭区间范围，例如`0...4`表示从 0 到 4 的整数范围。

而`..<`表示前闭后开的区间范围，例如`0..<5`表示的是从 0 到 4 的整数范围，不包括 5。

#### 问题 #2 -- Swift 1.0 或更高版本 

分析下面代码：

```swift
struct Tutorial {
    var difficulty: Int = 1
}
 
var tutorial1 = Tutorial()
var tutorial2 = tutorial1
tutorial2.difficulty = 2
```

`tutorial1.difficulty`和`tutorial2.difficulty`的值各是什么？如果`Tutorial`是`class`类型呢？

##### 解决方案：

`tutorial1.difficulty`是 1，而`tutorial2.difficulty`是 2。

`Swift`中，`struct`是值类型，传递的是自身值的拷贝，而不是像`class`这种引用类型一样传递自身的引用。

下面的代码创建了`tutorial1`的副本赋值给`tutorial2`：

```swift
var tutorial2 = tutorial1
```

在这之后，对`tutorial2`的任何操作都不会影响`tutorial1`。

而如果`Tutorial`是`class`类型，`tutorial1.difficulty`和`tutorial2.difficulty`将都会是 2。

`class`类型在`Swift`中是引用类型，操作`tutorial1`即是操作`tutorial2`，反之亦然。

#### 问题 #3 -- Swift 1.0 或更高版本

`view1`声明为`var`，`view2`声明为`let`。这里有什么区别呢？最后一行能通过编译吗？

```swift
import UIKit
 
var view1 = UIView()
view1.alpha = 0.5
 
let view2 = UIView()
view2.alpha = 0.5 // 这一行能通过编译吗？
```

##### 解决方案：

`view1`是一个变量，可以被重新分配一个新的`UIView`实例。

而`let`是常量，只允许被赋值一次，所以下面的代码不能通过编译：

```swift
view2 = view1 // 错误，view2 不可变。
```

然而，`UIView`是`class`类型，是引用语义，所以可以改变`view2`的属性，也就是最后一行可以通过编译：

```swift
let view2 = UIView()
view2.alpha = 0.5 // 完全没问题~
```

#### 问题 #4 -- Swift 1.0 或更高版本

这段代码按照字母顺序排序数组，这看上去有些啰嗦，试着简化写法。

```swift
let animals = ["fish", "cat", "chicken", "dog"]
let sortedAnimals = animals.sort { (one: String, two: String) -> Bool in
    return one < two
}
```

##### 解决方案：

首先可以简化闭包的参数。由于类型推断，可以省略闭包的参数类型：

```swift
let sortedAnimals = animals.sort { (one, two) -> Bool in
    return one < two 
}
```

闭包的返回类型也可以推断出来，也可以省略：

```swift
let sortedAnimals = animals.sort { (one, two) in 
    return one < two 
}
```

使用`$0`，`$1`这种形式可以分别表示第一个和第二个参数，以此类推。因此参数和`in`关键字也可以省略：

```swift
let sortedAnimals = animals.sort { return $0 < $1 }
```

只有一句表达式的闭包可以省略`return`关键字，表达式的返回值会被推断为闭包的返回值：

```swift
let sortedAnimals = animals.sort { $0 < $1 }
```

最后，`String`类型实现了一个比较函数，声明如下：

```swift
func <(lhs: String, rhs: String) -> Bool
```

`<`表示的函数完全符合上述闭包的要求，因此可以直接传入作为`sort(_:)`的参数：

```swift
let sortedAnimals = animals.sort(<)
```

#### 问题 #5 -- Swift 1.0 或更高版本

下面这段代码创建了两个类，`Address`和`Person`，`Person`会创建两个实例表示`Ray`和`Brian`这俩人。

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

假设`Brian`搬到街对面的新房子去了，所以需要更新他的地址：

```swift
brian.address.fullAddress = "148 Tutorial Street"
```

这句代码会导致什么问题吗？

##### 解决方案：

`ray`也搬到了新房子！

`Address`是一个`class`，是引用语义。

因此从上述代码来看，访问两个人的`address`属性都是访问同一`Address`实例，即`headquarters`。

更好的做法是将`Address`定义为`struct`类型，值传递语义在这种情况下更科学。

<a name="Written Intermediate"></a>
### 中级

#### 问题 #1 -- Swift 2.0 或更高版本

思考下面代码：

```swift
var optional1: String? = nil
var optional2: String? = .None
```

这里的`nil`和`.None`有什么区别吗？`optional1`和`optional2`有什么不同吗？

##### 解决方案：

没有区别。

`Optional.None`是初始化一个可选类型的完整写法，而`nil`只是一种语法糖。

实际上，下面这个语句结果为`true`：

```swift
nil == .None // 在 Swift 1.x 版本这无法通过编译，需要写成 Optional<Int>.None 这种形式。
```

记住，`Optional`实际上是个枚举：

```swift
enum Optional<T> {
    case None
    case Some(T)
    // 省略其余代码...
}
```

#### 问题 #2 -- Swift 1.0 或更高版本

下面代码分别用`class`和`struct`表示温度计模型：

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

这段代码会编译失败。错误在哪里呢？为什么？

##### 解决方案：

错误出在最后一行。

方法`registerTemperature(_:)`会改变内部变量`temperature`，所以使用了`mutating`关键字进行声明。

但其实例`thermometerStruct`声明为`let`，是不可变的，所以不能调用`registerTemperature(_:)`方法。

对于`struct`，改变内部状态的方法必须标记为`mutating`，而不可变实例则不能调用这种方法。

#### 问题 #3 -- Swift 1.0 或更高版本

下面这段代码会打印出什么？为什么？

```swift
var thing = "cars"
 
let closure = { [thing] in
    print("I love \(thing)")
}
 
thing = "airplanes"
 
closure()
```

##### 解决方案：

会打印`I love cars`。

由于创建闭包时声明了捕获列表，闭包将创建变量`thing`的拷贝，所以之后对闭包外的变量`thing`重新赋值，并不会影响闭包内部的`thing`。

如果没有捕获列表，闭包将通过引用使用变量`thing`而不是使用拷贝来的副本。在这种情况下，改变闭包外部的变量`thing`会影响闭包内部的变量`thing`。

```swift
var thing = "cars"
 
let closure = {    
    print("I love \(thing)")
}
 
thing = "airplanes"
 
closure() // 打印 I love airplanes
```

#### 问题 #4 -- Swift 2.0 或更高版本

下面这个全局函数用来统计数组中每种元素出现的次数：

```swift
func countUniques<T: Comparable>(array: Array<T>) -> Int {
    let sorted = array.sort(<)
    let initial: (T?, Int) = (.None, 0)
    let reduced = sorted.reduce(initial) { ($1, $0.0 == $1 ? $0.1 : $0.1 + 1) }
    return reduced.1
}
```

由于要用`<`和`==`操作符作比较，因此`T`类型必须符合`Comparable`协议。

调用时是这样的：

```swift
countUniques([1, 2, 3, 3]) // 结果为 3。
```

现在要求将该函数改写为`Array`的扩展方法，像这样调用：

```swift
[1, 2, 3, 3].countUniques()
```

##### 解决方案：

在`Swift 2.0`中，泛型类型的扩展可以指定类型约束。如果其类型不满足约束条件，扩展是不可用的：

```swift
extension Array where Element: Comparable {
    public func countUniques() -> Int {
        let sorted = sort(<)
        let initial: (Element?, Int) = (.None, 0)
        let reduced = sorted.reduce(initial) { ($1, $0.0 == $1 ? $0.1 : $0.1 + 1) }
        return reduced.1
    }
}
```

注意，只有当元素实现了`Comparable`协议时，这个扩展才是可用的。

例如下面这种情况，编译器会报错指出`UIView`不符合`Comparable`协议：

```swift
let a = [UIView(), UIView()]
a.countUniques()
```
#### 问题 #5 -- Swift 2.0 或更高版本

下面这个函数使用两个给定的`Double`类型的值进行除法运算，有三个先决条件：

- 被除数不能为`nil`
- 除数不能为`nil`
- 除数不能为`0`

```swift
func divide(dividend: Double?, by divisor: Double?) -> Double? {
    if dividend == .None {
        return .None
    }

    if divisor == .None {
        return .None
    }

    if divisor == 0 {
        return .None
    }

    return dividend! / divisor!
}
```

这个函数符合要求，但是有些不足：

- 最好使用`guard`语句检查先决条件
- 最好避免使用强制解包

改进该函数，使用`guard`语句并避免使用强制解包。

##### 解决方案：

`Swift 2.0`新引入了`guard`语句，可提供不满足条件时的退出路径。这对于先决条件的检查十分有用，可以让开发者更清晰地表达先决条件，而不是像以前那样使用大量嵌套`if`语句。

例如可以像下面这样：

```swift
guard dividend != .None else { return .None }
```

`guard`还可用于可选绑定，在`guard`语句之后也可以使用解包后的可选值：

```swift
guard let dividend = dividend else { return .None }
```

因此，上面的除法函数可以改写为下面这样：

```swift
func divide(dividend: Double?, by divisor: Double?) -> Double? {
    guard let dividend = dividend else { return .None }
    guard let divisor = divisor else { return .None }
    guard divisor != 0 else { return .None }
    return dividend / divisor
}
```

函数最后没有使用强制解包，因为`dividend`和`divisor`在之前的`guard`语句中已经用可选绑定解包了。

另外，`guard`语句还可以连起来使用：

```swift
func divide(dividend: Double?, by divisor: Double?) -> Double? {
    guard let
        dividend = dividend,
        divisor  = divisor where divisor != 0
    else {
        return .None
    }
    
    return dividend / divisor
}
```

<a name="Written Advanced"></a>
### 高级

#### 问题 #1 -- Swift 1.0 或更高版本

分析下面这个表示温度计的结构：

```swift
public struct Thermometer {
    public var temperature: Double
    public init(temperature: Double) {
        self.temperature = temperature
    }
}
```

通常这样来创建一个实例：

```swift
var t = Thermometer(temperature: 233.3)
```

但如果能这么写就更省事了：

```swift
var t: Thermometer = 233.3
```

这样能做到吗？

##### 解决方案：

`Swift`定义了以下协议，允许通过字面量赋值初始化一种类型：

- NilLiteralConvertible
- BooleanLiteralConvertible
- IntegerLiteralConvertible
- FloatLiteralConvertible
- UnicodeScalarLiteralConvertible
- ExtendedGraphemeClusterLiteralConvertible
- StringLiteralConvertible
- ArrayLiteralConvertible
- DictionaryLiteralConvertible

让某种类型遵循相应的协议并提供一个公共构造器，就可以通过相应字面量初始化。

因此，让`Thermometer`实现`FloatLiteralConvertible`协议即可：

```swift
extension Thermometer: FloatLiteralConvertible {
    public init(floatLiteral value: Double) {
        self.init(temperature: value)
    }
}
```

#### 问题 #2 -- Swift 1.0 或更高版本

`Swift`预定义了一系列运算符用于执行各种运算，例如算术或者逻辑运算，还可以创建自定义的一元或者二元运算符。

定义并实现一个自定义的幂运算符`^^`，并遵循以下规则：

- 运算符接收两个`Int`参数
- 第一个参数作为底数，第二个参数作为指数，返回运算结果
- 可以不考虑潜在的溢出问题

##### 解决方案：

自定义运算符的过程分为声明和实现两步。

声明自定义运算符使用`operator`关键字，还需要指定是一元还是二元运算符，结合性以及优先级：

```swift
infix operator ^^ {
    associativity right
    precedence 155
}
```

上述代码声明`^^`为`inifx`即二元运算符，结合性为右结合，优先级为 155（乘除法为 150）。

运算符具体实现如下：

```swift
func ^^(lhs: Int, rhs: Int) -> Int {
    return Int(pow( Double(lhs), Double(rhs) ))
}
```

注意，这里并未考虑溢出的情况，如果运算结果大于`Int.max`，将会导致运行时错误。

#### 问题 #3 -- Swift 1.0 或更高版本

你能定义一个原始值为元组的枚举吗？

```swift
enum Edges: (Double, Double) {
    case TopLeft = (0.0, 0.0)
    case TopRight = (1.0, 0.0)
    case BottomLeft = (0.0, 1.0)
    case BottomRight = (1.0, 1.0)
}
```

##### 解决方案：

这个真不能。

枚举的原始值必须符合下列要求：

- 符合`Equatable`协议
- 可由字面量转换为下面类型：
    - Int
    - Double
    - String
    - Character

而元组类型并不能满足上面的要求。

#### 问题 #4 -- Swift 2.0 或更高版本

这里定义了一个`Pizza`结构，一个`Pizzeria`协议和包含`makeMargherita()`方法默认实现的协议扩展：

```swift
struct Pizza {
    let ingredients: [String]
}

protocol Pizzeria {
    func makePizza(ingredients: [String]) -> Pizza
    func makeMargherita() -> Pizza
}

extension Pizzeria {
    func makeMargherita() -> Pizza {
        return makePizza(["tomato", "mozzarella"])
    }
}
```

接着定义了一个餐厅结构`Lombardis`：

```swift
struct Lombardis: Pizzeria {
    func makePizza(ingredients: [String]) -> Pizza {
        return Pizza(ingredients: ingredients)
    }
    
    func makeMargherita() -> Pizza {
        return makePizza(["tomato", "basil", "mozzarella"])
    }
}
```

最后创建了两个`Lombardis`实例。那么哪一个餐厅会制作`basil`披萨呢？

```swift
let lombardis1: Pizzeria = Lombardis()
let lombardis2: Lombardis = Lombardis()
 
lombardis1.makeMargherita()
lombardis2.makeMargherita()
```

##### 解决方案：

都会做。

`Pizzeria`协议声明了`makeMargherita()`方法并利用协议扩展提供了默认实现，该默认实现会被采纳协议的`Lombardis`中提供的实现覆盖。由于`Pizzeria`协议声明了`makeMargherita()`方法，因此`lombardis1`和
`lombardis2`都会调用`Lombardis`重写的实现。

如果`Pizzeria`协议中未声明`makeMargherita()`方法，而只是在扩展中提供了默认实现：

```swift
protocol Pizzeria {
    func makePizza(ingredients: [String]) -> Pizza
}

extension Pizzeria {
    func makeMargherita() -> Pizza {
        return makePizza(["tomato", "mozzarella"])
    }
}
```

那么在这种情况下，只有`lombardis2`会做`basil`披萨，而`lombardis1`会去调用协议扩展中的方法。

#### 问题 #5 -- Swift 2.0 或更高版本

下面的代码编译出错，你能找出错误位置以及原因吗？

```swift
struct Kitten {
    // ...
}
 
func showKitten(kitten: Kitten?) {
    guard let k = kitten else {
        print("There is no kitten")
    }
    print(k)
}
```

提示：有三种方案可以解决这个问题。

##### 解决方案：

`guard`语句需要有退出路径，无论是使用`return`还是抛出错误或是调用`@noreturn`函数。

使用`return`的方案：

```swift
func showKitten(kitten: Kitten?) {
    guard let k = kitten else {
        print("There is no kitten")
        return
    }
    print(k)
}
```

抛出错误的方案：

```swift
enum KittenError: ErrorType {
    case NoKitten
}

func showKitten(kitten: Kitten?) throws {
    guard let k = kitten else {
        print("There is no kitten")
        throw KittenError.NoKitten
    }
    print(k)
}

try showKitten(nil)
```

通过调用`fatalError()`实现`@noreturn`的方案：

```swift
func showKitten(kitten: Kitten?) {
    guard let k = kitten else {
        print("There is no kitten")
        fatalError()
    }
    print(k)
}
```

<a name="Verbal Questions"></a>
## 面试问题

<a name="Verbal Beginners"></a>
### 初级

#### 问题 #1 -- Swift 1.0 或更高版本

什么是可选？它能解决什么问题？

##### 回答：

可选能让某种类型的变量更好地应对“没有值”的情况。

在`Objective-C`中，使用`nil`来表示一个引用类型的变量“没有值”。而对于值类型，例如`int`，`float`之类，则没办法表示。

`Swift`改善了这一问题，任何类型的可选形式的值都可以是有效值或者是`nil`。

#### 问题 #2 -- Swift 1.0 或更高版本

类和结构的使用时机和场合？

##### 回答：

这总是存在一定的争论。函数式编程倾向于值类型，而面向对象编程更热衷于类。

在`Swift`，类和结构非常相似，但也有一些重要区别：

- 类支持继承，而结构不可以
- 类是引用类型，结构是值类型

没有什么通用的规则来确定用哪个最好，使用最低手段完成目的就是好的。

比较好的经验法则是：尽量使用结构，除非你明确需要使用继承或是引用语义。

> 注意性能  
> 在运行时，结构的方法调用是静态绑定的，而类则是动态派发的。这或许是另一个使用结构而不是类的好理由。

#### 问题 #3 -- Swift 1.0 或更高版本

什么是泛型？泛型能解决什么问题？

##### 回答：

泛型能让一种算法安全地适用于不同类型。在`Swift`，泛型可以应用于函数，以及数据类型，例如类，结构，或者枚举。

泛型还能解决代码重复的问题。常见的情况是，一个方法只接收某种类型的参数，如果想让它接收其他类型的参数，就不得不复制这个方法的代码做出对应修改。

例如，下面代码的第二个函数是第一个函数的“克隆”，它仅仅是将参数类型改为了`String`而不再是`Int`：

```swift
func areIntEqual(x: Int, _ y: Int) -> Bool {
    return x == y
}
 
func areStringsEqual(x: String, _ y: String) -> Bool {
    return x == y
}
 
areStringsEqual("ray", "ray") // true
areIntEqual(1, 1) // true
```

一个`Objective-C`开发者可能会用`NSObject`解决这个问题：

```swift
func areTheyEqual(x: NSObject, _ y: NSObject) -> Bool {
    return x == y
}
 
areTheyEqual("ray", "ray") // true
areTheyEqual(1, 1) // true
```

上面这段代码可以正常工作，但是在编译时并不安全。它甚至允许比较字符串和整数，就像这样：

```swift
areTheyEqual(1, "ray")
```

虽然应用程序不会崩溃，但是这样的比较结果往往并不是所期待的结果。

采用泛型，就可以在合并这两个函数的同时保证类型安全：

```swift
func areTheyEqual<T: Equatable>(x: T, _ y: T) -> Bool {
    return x == y
}
 
areTheyEqual("ray", "ray")
areTheyEqual(1, 1)
```

因为需要测试等同性，所以对于任意类型的参数，必须符合`Equatable`协议。这个函数达到了预期目的，并防止了不同参数的传入。

#### 问题 #4 -- Swift 1.0 或更高版本

在什么情况下，你无法避免使用隐式解包可选？为什么？

##### 回答：

使用隐式解包可选最常见的理由：

1. 当一个属性不是`nil`，也不能在实例化时就初始化。一个典型的例子就是 Interface Builder 中的`@IBOutlet`，它们总是在所有者被初始化后才被初始化。假设在 Interface Builder 中配置正确，那么可以保证它们在使用时具有有效值。

2. 为了解决强引用循环问题。这常发生在两个实例互相引用对方，并要求引用为非`nil`值的情况下。在这种情况下，一方的属性标记为`unowned`，另一方的属性使用隐式解包可选。详情参看《The Swift Programming Language 中文版》中的 [解决实例之间的循环强引用](http://wiki.jikexueyuan.com/project/swift/chapter2/16_Automatic_Reference_Counting.html#resolving_strong_reference_cycles_between_class_instances) 中的“无主引用以及隐式解析可选属性”部分。

> 提示  
> 除非必要，不要使用隐式解包可选。使用不当会增加运行时崩溃的可能，虽然在某些情况下，可能会故意引发崩溃，但有更好的方式达到此效果，例如使用`fatalError()`。

#### 问题 #5 -- Swift 1.0 或更高版本

解包一个可选的方法都有什么？是否安全？

提示：至少有七种方式。

##### 回答：

- 使用`!`运算符强制解包，不安全。
- 使用隐式解包，不安全。
- 使用可选绑定，安全。
- 使用可选链接，安全。
- 使用`??`运算符，安全。
- 使用`guard`语句，安全。(`Swift 2.0`)
- 使用可选模式匹配，安全。(`Swift 2.0`)

<a name="Verbal Intermediate"></a>
### 中级

#### 问题 #1 -- Swift 1.0 或更高版本

`Swift`是一种面向对象语言还是函数式语言？

##### 回答：

`Swift`是一种混合语言，同时支持两种范式。

它体现了面向对象的三个基本准则：

- 封装
- 继承
- 多态

虽然`Swift`并不是严格意义上的函数式语言，但它具备函数式语言的一些基本特性。

#### 问题 #2 -- Swift 1.0 或更高版本

`Swift`包含下列哪些特性？

1. 泛型类
2. 泛型结构
3. 泛型协议

##### 回答：

1 和 2 都包括。泛型可以用在类，结构，枚举，函数和方法。

通过实现`typealias`，算是勉强包含 3。这不是泛型类型本身，只是一个占位名字。通常被称为`associated type`，在某一类型采纳协议时定义。

#### 问题 #3 -- Swift 1.0 或更高版本

在`Objective-C`中，一个常量可以这样声明：

```objective-c
const int number = 0;
```

在`Swift`中这样声明：

```swift
let number = 0
```

有什么区别吗？如果有，区别在哪里呢？

##### 回答：

常量是指在编译时被初始化的变量。

`Swift`中使用`let`创建一个不可变量，这可以在运行时完成。它也可被一个静态或者动态表达式初始化，但只能被赋值一次。

#### 问题 #4 -- Swift 1.0 或更高版本

`Swift`中使用`static`修饰符声明一个静态属性或函数。例如这个结构：

```swift
struct Sun {
    static func illuminate() {}
}
```

对于类，除了`static`，还可以使用`class`修饰符，都能实现相同的目的，但实际上是有区别的，区别在哪里呢？

##### 回答：

对于类，使用`static`声明的静态属性或者方法，是不能被子类重写的。而使用`class`声明，则允许子类进行重写。

当`static`应用于类，实际上是`class final`两个修饰符的别名。

例如，对于下面这段代码，编译器会报错提示无法重写一个`final`修饰的类方法：

```swift
class Star {
    class func spin() {}
    static func illuminate() {}
}

class Sun: Star {
    override class func spin() {
        super.spin()
    }

    override static func illuminate() { // error: class method overrides a 'final' class method
        super.illuminate()
    }
}
```

#### 问题 #5 -- Swift 1.0 或更高版本

可以通过扩展添加存储属性吗？

##### 回答：

不可以。

扩展可以用来添加新行为到现有类型，但不能改变类型本身或是接口。

如果添加一个存储属性，就需要额外的内存空间来存储新值，扩展无法完成这样的任务。

<a name="Verbal Advanced"></a>
### 高级

#### 问题 #1 -- Swift 1.2 

在`Swift 1.2`中，当枚举的关联值使用泛型时，会编译报错，例如像下面这样：

```swift
enum Either<T, V> {
    case Left(T)
    case Right(V)
}
```

这会导致神秘报错`unimplemented IR generation feature non-fixed multi-payload enum layout`。

能解释吗？

##### 回答：

问题在于枚举无法确定`T`类型占用的内存大小。

最常用的解决办法是将泛型类型用引用类型进行包装。如下所示：

```swift
class Box<T> {
    let value: T
    init(_ value: T) {
        self.value = value
    }
}
 
enum Either<T, V> {
    case Left(Box<T>)
    case Right(Box<V>)
}
```

这个问题只存在于`Swift 1.2`以及之前版本，`Swift 2.0`已解决此问题。

#### 问题 #2 -- Swift 1.0 或更高版本 

闭包是引用类型还是值类型？

##### 回答：

闭包是引用类型。如果一个闭包分配给某一变量，该变量又赋值给另一个变量，这两个变量均引用同一闭包。

#### 问题 #3 -- Swift 1.0 或更高版本

`UInt`用于存储无符号整数类型。它提供了这个构造器：

```swift
init(_ value: Int)
```

如果传入一个负数做参数，就会导致编译错误：

```swift
let myNegative = UInt(-1)
```

负数在内存中用补码形式表示，如何将一个负数`Int`转换为`UInt`并保持其在内存中的二进制形式呢？

##### 回答：

`UInt`提供了这个构造器：

```swift
UInt(bitPattern: Int)

let a = UInt(bitPattern: -1) // 18446744073709551615
let b = UInt.max             // 18446744073709551615
```

#### 问题 #4 -- Swift 1.0 或更高版本

描述下`Swift`中导致循环引用的原因，以及如何解决这个问题。

##### 回答：

当两个实例彼此强引用时，每个实例都没机会销毁，导致内存泄漏。

因为只要有强引用引用着实例，实例就无法释放。两个实例互相维持指向对方的强引用，谁也无法释放。

可将其中一个引用声明为`weak`或者是`unowned`来避免强引用循环。

#### 问题 #5 -- Swift 2.0 或更高版本

`Swift 2.0`引入一个新关键字用来标记递归枚举。例如下面这个递归枚举：

```swift
enum List<T> {
    case Node(T, List<T>)
}
```

这个关键字是什么？

##### 回答：

```swift 
indirect
```

该关键字用于标记递归枚举。例如：

```swift
enum List<T> {
    indirect case Node(T, List<T>)
}
```
