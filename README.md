出自`RayWenderlich`的教程 [Programming Challenge: Are You a Swift Ninja? ](http://www.raywenderlich.com/76349/swift-ninja-part-1)

觉得挺好玩的,记录一下.未完待续...

## 巧用`元组`交换两个值

```swift

func mySwap<T>(inout a: T, inout b:T) {
    (a, b) = (b, a)
}

var a = "123", b = "321"

mySwap(&a, &b) // a = "321", b = "123"

```
当然,直接使用系统库自带的`swap`函数最省事.

## 编写一个函数`flexStrings`符合下列条件:

    1. 函数可以接受0、1或2个字符串参数.
    2. 将函数参数连接为`String`返回.
    3. 如果没有参数,函数返回`"none"`.

例如下面这样:

```swift

flexStrings() //--> "none"  
flexStrings(s1: "One") //--> "One"  
flexStrings(s1: "One", s2: "Two") //--> "OneTwo"

```

这体现了`Swift`中函数`默认参数`的特性.如果不指定参数,则使用默认参数.

```swift

func flexStrings(s1: String = "", s2: String = "") -> String {
    return s1 + s2 == "" ? "none" : s1 + s2
}

flexStrings()
flexStrings(s1: "One")
flexStrings(s1: "One", s2: "Two")

```

## 编写一个函数`sumAny`,可以接收任何类型的零个或多个参数.函数应满足以下要求: 

    1. 函数将参数求和后以`String`类型返回,并符合后面的要求.
    2. 如果参数是空的`String`或者值为`0`的`Int`,则结果要`-10`.
    3. 如果参数是一个表示正数的`String`,例如`"10"`,而不是`"-5"`,则累加到结果中.
    4. 如果参数是`Int`,则累加到结果中.
    5. 此外任何情况均不计入结果中.

例如下面这样:

```swift

let result0 = sumAny() //--> "0"
let result1 = sumAny(Double(), 10, "-10", 2) //--> "12"
let result2 = sumAny("Marin Todorov", 2, 22, "-3", "10", "", 0, 33, -5) //--> "42"

```

这体现了`Swift`中`可变参数函数`的特性.

```swift

/// Any 表示任意类型,而...则表示参数个数任意,即接收任意数量的任意类型的参数.
/// 所有参数会作为一个数组传入,像下面这样,该字符串将表示传入参数的个数.
func sumAny(anys: Any...) -> String {
    return "\(anys.count)"
}

```

映射数组可以使用`map`函数,而求和可以使用`reduce`函数:

```swift

// 使用 map 函数来遍历数组.每次遍历的返回值最终组成一个新数组返回.
[Any]().map { item -> Int in

    switch item {

    // 匹配空字符串或者Int类型的0.
    case "" as String, 0 as Int:
        return -10

    // 字符串能转为Int且大于0,返回转换后的值.
    case let s as String where s.toInt() > 0:
        return s.toInt()!

    // 匹配到Int,直接返回.
    case is Int:
        return item as! Int

    // 其他情况返回0,等于没累加.
    default:
        return 0
    }
}
// 使用 reduce 函数遍历数组,将每次的返回值累加到第一个参数上,这里就是这个0.
// 遍历结束后将该参数的值作为函数返回值.
// $0 表示闭包第1个参数, $1 表示闭包第2个参数,以此类推.
// 由于未用到参数列表,因此可以省略闭包参数和 in 关键字.
// 又由于只有一句表达式,还可以省略 return 关键字.
.reduce(0) {
    $0 + $1
}

```

最后将求得的和转为`String`即可.

## 递归

这个和`Swift`没啥太大关系. - -!

```swift

func countFrom(from: Int, #to: Int) {
    print(from)
    if from < to {
        countFrom(from + 1, to: to)
    }
}

countFrom(1, to: 5) // 12345

```
